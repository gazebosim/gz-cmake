# Note on deprecations
A tick-tock release cycle allows easy migration to new software versions.
Obsolete code is marked as deprecated for one major release.
Deprecated code produces compile-time warnings. These warning serve as
notification to users that their code should be upgraded. The next major
release will remove the deprecated code.

## Ignition CMake 2.X to 3.X

1. **Deprecated**: include/ignition/utilities/SuppressWarning.hh
   **Replacement**: include/ignition/utils/SuppressWarning.hh
1. **Deprecated**: include/ignition/utilities/ExtraTestMacros.hh
   **Replacement**: include/ignition/utils/ExtraTestMacros.hh
1. **Deprecated**: CMake functions and macros starting with `ign_`
   **Replacement**: CMake functions and macros starting with `gz_`
