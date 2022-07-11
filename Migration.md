# Note on deprecations
A tick-tock release cycle allows easy migration to new software versions.
Obsolete code is marked as deprecated for one major release.
Deprecated code produces compile-time warnings. These warning serve as
notification to users that their code should be upgraded. The next major
release will remove the deprecated code.

## Gazebo CMake 2.X to 3.X

1. **Deprecated**: include/ignition/utilities/SuppressWarning.hh
    **Replacement**: include/ignition/utils/SuppressWarning.hh
1. **Deprecated**: include/ignition/utilities/ExtraTestMacros.hh
    **Replacement**: include/ignition/utils/ExtraTestMacros.hh
1. **Deprecated**: CMake functions and macros starting with `ign_`
    **Replacement**: CMake functions and macros starting with `gz_`
1. **Deprecated**: `ignition` namespaces
    **Replacement**: `gz` namespaces
1. **Deprecated**: `Ign` prefixed CMake files
    **Replacement**: `Gz` prefixed CMake files
1. **Deprecated**: `Ign/IGNITION` prefixed CMake variables and options
    **Replacement**: `Gz` prefixed CMake variables and options
1. **Breaking**: The project name has been changed to use the `gz-` prefix, you **must** use the `gz` prefix!
  * This also means that any generated code that use the project name (e.g. CMake variables, in-source macros) would have to be migrated.
  * Some non-exhaustive examples of this include:
    * `GZ_<PROJECT>_<VISIBLE/HIDDEN>`
    * CMake `-config` files
    * Paths that depend on the project name
