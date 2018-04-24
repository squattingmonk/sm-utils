# Squatting Monk's NWN Utilities
This package contains various utility scripts used by my other [Neverwinter 
Nights](http://neverwinternights.info) scripts.

## Prerequisites
This package does not require any other code. However, the install script 
requires the following:

- [nwn-erf from nwn-lib](https://github.com/niv/nwn-lib)
- [ruby](htt[s://www.ruby-lang.org)

## Installation
Get the code:
```
git clone https://github.com/squattingmonk/sm-utils
```

Run the build script:
```
cd sm-utils
rake erf
```

The `sm_utils.erf` file will be created in the `sm-utils` directory. Import 
this file into your module.

Alternatively, you can simply copy all files from `sm-utils/src` into your 
module's working directory.

This package contains the following resources:

| Resource		         | Function              				        |
| ---------------------- | -------------------------------------------- |
| `util_i_lists.nss`	 | CSV and local variable lists master include  |
| `util_i_csvlists.nss`  | CSV list utilities                           |
| `util_i_varlists.nss`  | Local variable list utilities                |
| `util_i_debug.nss`     | Debugging utilities                          |
| `util_i_libraries.nss` | Library script utilities                     |
| `util_i_library.nss`   | Library dispatcher boilerplate               |
| `util_i_datapoint.nss` | System-specific data object creation utility |

## Acknowledgements
- `util_i_varlists.nss` and `util_i_libraries.nss` adapted from 
  [MemeticAI](https://sourceforge.net/projects/memeticai/).
