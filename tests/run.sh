#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# run.sh: build a nasher target and run its unit tests on a headless nwserver.
#
# The target must build a module whose OnModuleLoad runs util_e_unittest (or
# otherwise executes it). This script packs the module, starts nwserver in
# Docker, waits for the runner's `[UNITTEST] DONE` line, prints the test output,
# and stops the server.
#
# Usage: tests/run.sh [options]
#   -C DIR      nasher project directory (default: current directory)
#   -t TARGET   nasher target to build (default: test)
#   -i IMAGE    nwserver Docker image (default: $NWSERVER_IMAGE or
#               urothis/nwserver:stable)
#   -T SECONDS  seconds to wait for the tests to finish (default: 120)
#   -n          do not build; use the existing packed module
#   -v          print the full server log instead of only test output
#
# Exit status: 0 if all tests passed, 1 if any test failed or a test script
# raised a runtime error, 2 if the run did not complete.
# ------------------------------------------------------------------------------
set -euo pipefail

project_dir=.
target="test"
image=${NWSERVER_IMAGE:-urothis/nwserver:stable}
timeout=120
build=1
verbose=0

usage() {
  sed -n '/^# Usage:/,/^# ---/{/^# ---/d;p}' "$0" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

while getopts "C:t:i:T:nvh" opt; do
  case $opt in
  C) project_dir=$OPTARG ;;
  t) target=$OPTARG ;;
  i) image=$OPTARG ;;
  T) timeout=$OPTARG ;;
  n) build=0 ;;
  v) verbose=1 ;;
  h) usage 0 ;;
  *) usage 2 ;;
  esac
done

cd "$project_dir"

mod_file=$(nasher list "$target" 2>/dev/null | awk '/^File:/ { print $2; exit }')
if [[ -z $mod_file || $mod_file != *.mod ]]; then
  echo "error: target '$target' does not build a .mod file" >&2
  exit 2
fi
mod_name=${mod_file%.mod}

if ((build)); then
  echo "==> Packing $target"
  nasher pack "$target" --yes
fi

if [[ ! -f $mod_file ]]; then
  echo "error: $mod_file not found" >&2
  exit 2
fi

container="nwn-unittest-$$"
log=$(mktemp)
logs_pid=

# shellcheck disable=SC2317  # called via trap
cleanup() {
  if [[ -n $logs_pid ]]; then
    kill "$logs_pid" 2>/dev/null || true
  fi
  docker rm -f -v "$container" >/dev/null 2>&1 || true
  rm -f "$log"
}
trap cleanup EXIT

echo "==> Starting nwserver ($image) with module $mod_name"
docker create -i --name "$container" \
  -e NWN_MODULE="$mod_name" \
  -e NWN_TAIL_LOGS=y \
  -e NWN_PUBLICSERVER=0 \
  -e NWN_SERVERNAME="$container" \
  "$image" >/dev/null

# Copy the module in rather than bind-mounting a directory; this avoids leaving
# root-owned files behind on the host.
staging=$(mktemp -d)
mkdir -p "$staging/modules"
cp "$mod_file" "$staging/modules/"
docker cp -q "$staging/." "$container:/nwn/home"
rm -rf "$staging"

docker start "$container" >/dev/null
docker logs -f "$container" >"$log" 2>&1 &
logs_pid=$!

echo "==> Waiting for tests (timeout ${timeout}s)"
deadline=$((SECONDS + timeout))
status=
until grep -q '\[UNITTEST\] DONE' "$log"; do
  if [[ $(docker inspect -f '{{.State.Running}}' "$container" 2>/dev/null) != true ]]; then
    status=exited
    break
  fi
  if ((SECONDS >= deadline)); then
    status=timeout
    break
  fi
  sleep 0.5
done

docker stop -t 2 "$container" >/dev/null 2>&1 || true

if [[ -n $status ]]; then
  echo "error: tests did not complete ($status). Last log lines:" >&2
  tail -n 40 "$log" >&2
  exit 2
fi

# Strip nwserver's "[Day Mon DD HH:MM:SS] " timestamp prefix.
strip_ts() { sed -E 's/^\[[A-Z][a-z]{2} [A-Z][a-z]{2} +[0-9]+ [0-9:]+\] //'; }

echo
if ((verbose)); then
  strip_ts <"$log"
else
  # Test output is everything from the runner's FOUND line to its DONE line.
  awk '/\[UNITTEST\] FOUND/ { p = 1 } p { print } /\[UNITTEST\] DONE/ { exit }' "$log" | strip_ts
fi
echo

script_errors=$(grep -iE 'script .*error' "$log" || true)
if [[ -n $script_errors ]]; then
  echo "==> Script errors:"
  echo "$script_errors" | strip_ts
  echo
fi

summary=$(grep -m1 '\[UNITTEST\] DONE' "$log")
field() { tr ' ' '\n' <<<"$summary" | awk -F= -v k="$1" '$1 == k { print $2 }'; }
groups_failed=$(field groups_failed)
tests_failed=$(field tests_failed)

printf '==> %s scripts | groups: %s passed, %s failed | tests: %s passed, %s failed\n' \
  "$(field scripts)" "$(field groups_passed)" "$groups_failed" \
  "$(field tests_passed)" "$tests_failed"

failed_scripts=$(field failed_scripts)
[[ -n $failed_scripts ]] && echo "==> Failed: ${failed_scripts//,/, }"

if ((groups_failed > 0 || tests_failed > 0)) || [[ -n $script_errors ]]; then
  exit 1
fi
exit 0
