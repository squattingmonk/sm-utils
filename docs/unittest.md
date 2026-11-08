# Unit Tests

`util_i_unittest.nss` provides functions for reporting the results of unit
tests. See the header of that file for the variable conventions and a worked
example. `util_c_unittest.nss` controls colors, output handling, and which
scripts the test runner picks up.

## Writing tests

A test script is an ordinary script with a `main()` that calls `AssertGroup()`
and `Assert()`. Put sm-utils tests in `tests/` and name them `util_t_*.nss`.
Other systems can follow the same convention (e.g., `core_t_*.nss`); the
runner finds anything matching `*_t_*` by default, so there is no list to
update.

When combining results, use bitwise `&` instead of `&&`:

```nwscript
int b = (b1 = r1 == e1) &
        (b2 = r2 == e2);
```

`&&` short-circuits at the first false result, so the remaining `bN`
assignments never run and those cases cannot report their result.

## Running tests

`util_e_unittest.nss` is the test runner. It:

1. finds every compiled script whose name matches a glob pattern in
   `UNITTEST_SCRIPT_PATTERNS` (default `*_t_*`; see [Choosing which tests to
   run](#choosing-which-tests-to-run) to override it),
2. runs each script on the module, one at a time,
3. writes a summary line to the server log:

   ```
   [UNITTEST] DONE scripts=1 groups_passed=1 groups_failed=6 tests_passed=19 tests_failed=18 failed_scripts=util_t_csvlists
   ```

### Headless (Docker)

`tests/run.sh` builds the `test` target, a minimal module whose OnModuleLoad
script is `util_e_unittest`. It runs the module on a headless nwserver in
Docker, prints the test output, and exits non-zero if anything failed:

```bash
tests/run.sh
```

Options: `-t TARGET` builds a different nasher target, `-C DIR` runs from
another nasher project, `-i IMAGE` selects the nwserver image (default
`urothis/nwserver:stable`), `-T SECONDS` sets the timeout, `-n` skips the build,
and `-v` prints the full server log. Run `tests/run.sh -h` for details.

Another project can reuse the script by defining its own nasher target that
includes its tests, the sm-utils sources, and a module that runs
`util_e_unittest` on load, then running:

```bash
lib/sm-utils/tests/run.sh -t test
```

### In game

Include the test scripts and `util_e_unittest` in your module. You can then run
the tests from the NWScript window in the debug panel by setting `OBJECT_SELF`
to the module (the **Mod** button), entering `util_e_unittest` in the **Run
Script** field, and clicking **Execute**. You can also run
`dm_runscript util_e_unittest` from the console. Output goes to the server log.

### Choosing which tests to run

The pattern list can be overridden in two ways. The runner first checks for a
script parameter named `UNITTEST_SCRIPT_PATTERNS`, then for a local string of
the same name on the module, then falls back to the `UNITTEST_SCRIPT_PATTERNS`
constant in `util_c_unittest.nss`.

**For a single run**, pass the patterns as a script parameter. In the NWScript
window, you could run the following:

```nwscript
void main()
{
    SetScriptParam("UNITTEST_SCRIPT_PATTERNS", "util_t_*, core_t_*");
    ExecuteScript("util_e_unittest", GetModule());
}
```

**For every run**, set a local string with the same name on the module. You can
do this in the module's variables (for example, in a test module's
`module.ifo`), from a script, or from the console:

```
dm_setmodulevarstring UNITTEST_SCRIPT_PATTERNS util_t_csvlists
```

Separate multiple patterns with commas (e.g., `util_t_*,core_t_*`). In the
console, leave out spaces so it reads the patterns as a single value.

### Showing results in game

Test output always goes to the server log. To also show it in game, set
`UNITTEST_DISPLAY` to a bitmask of `DEBUG_LOG_*` destinations from
`util_i_debug.nss` (for example, `DEBUG_LOG_PC` for the first PC or
`DEBUG_LOG_DM` for all DMs). Like the pattern list, it can be set for a single
run with a script parameter, for every run with a local int on the module, or
by changing the `UNITTEST_DISPLAY` constant in `util_c_unittest.nss`
(default: `DEBUG_LOG_NONE`).

```nwscript
#include "util_i_debug"
void main()
{
    SetScriptParam("UNITTEST_DISPLAY", IntToString(DEBUG_LOG_PC));
    ExecuteScript("util_e_unittest", GetModule());
}
```

Script parameters are strings, so convert the value with `IntToString()`. To
set both the patterns and the display for one run, call `SetScriptParam()` once
for each before `ExecuteScript()`.

While the tests run, the module's debug level is raised to `DEBUG_LEVEL_NOTICE`
so the results can reach these destinations. Other notices from the module may
also show up during that time. The original settings are restored when the
tests finish.
