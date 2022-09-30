# Squatting Monk's NWN Utilities
This package contains various utility scripts used by my other [Neverwinter
Nights](http://neverwinternights.info) scripts.

## Prerequisites
This package does not require any other code. However, the install script
requires the following:

- [nwnsc](https://gitlab.com/glorwinger/nwnsc)
- [neverwinter.nim](https://github.com/niv/neverwinter.nim)
- [nasher](https://github.com/squattingmonk/nasher)

## Installation
Get the code:
```
git clone https://github.com/squattingmonk/sm-utils.git
```

Build it:
```
cd sm-utils
nasher install
```

The `sm_utils.erf` file will be installed into the `erf` folder in your NWN
installation directory. Import this file into your module.

Alternatively, you can simply copy all files from `sm-utils/src` into your
module's working directory.

This package contains the following resources:

| Resource               | Function                                      |
| ---------------------- | --------------------------------------------- |
| `util_c_color.nss`     | Configuration file for `util_i_color.nss`     |
| `util_i_color.nss`     | RGB, HSV, and hex color utilities             |
| `util_i_constants.nss` | Constant value retrieval functions            |
| `util_i_csvlists.nss`  | CSV list utilities                            |
| `util_i_datapoint.nss` | System-specific data object creation utility  |
| `util_c_debug.nss`     | Configuration file for `util_i_debug.nss`     |
| `util_i_debug.nss`     | Debugging utilities                           |
| `util_i_libraries.nss` | Library script utilities                      |
| `util_i_library.nss`   | Library dispatcher boilerplate                |
| `util_i_lists.nss`     | CSV and local variable lists master include   |
| `util_i_matching.nss`  | Functions for glob-matching strings           |
| `util_i_math.nss`      | Common math utilities                         |
| `util_i_nss.nss`       | Functions for building executable scripts     |
| `util_i_sqlite.nss`    | Functions for interfacing with sqlite dbs     |
| `util_c_strftime.nss`  | Configuration file for `util_i_strftime.nss`  |
| `util_i_strftime.nss`  | Formatting functions for dates and times      |
| `util_i_strings.nss`   | String manipulation utilities                 |
| `util_c_targeting.nss` | Configuration file for `util_i_targeting.nss` |
| `util_i_targeting.nss` | Functions for hooking OnPlayerTarget          |
| `util_i_timers.nss`    | Functions for running scripts on an interval  |
| `util_i_times.nss`     | Time, date, and duration functions            |
| `util_c_unittest.nss`  | Configuration file for `util_i_unittest.nss`  |
| `util_i_unittest.nss`  | Functions for testing other scripts           |
| `util_c_variables.nss` | Configuration file for `util_i_variables.nss` |
| `util_i_variables.nss` | Functions for handling sqlite-based variables |
| `util_i_varlists.nss`  | Local variable list utilities                 |

Note: `sm-utils` relies on script extensions added by
[nwnsc](https://github.com/nwneetools/nwnsc). This prevents error messages when
compiling with `nwnsc`, but prevents compilation in the Toolset. If you want to
compile the scripts in the toolset instead, you can comment out the lines
beginning with `#pragma` near the bottom of the script `util_i_library.nss`.
Note that `util_i_library.nss` will still not compile on its own, since it's
meant to be included in other scripts that implement its functions.

## Usage
- Utilities
  - [Debugging](docs/debugging.md)
  - [Datapoints](docs/datapoints.md)
  - [Lists](docs/lists.md)
  - [Libraries](docs/libraries.md)
  - [Times](docs/times.md)
  - [Timers](docs/timers.md)

## Acknowledgements
- Thanks to tinygiant98 for his continued contributions and testing.
- `util_i_libraries.nss` adapted from
  [MemeticAI](https://sourceforge.net/projects/memeticai/).
