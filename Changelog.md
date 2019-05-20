## Ignition CMake 2.x

### Ignition CMake 2.x.x

### Ignition CMake 2.1.0 (2019-05-17)

1. Fixes for vcpkg ogre 1.11 version
    * [Pull request 152](https://bitbucket.org/ignitionrobotics/ign-cmake/pull-requests/152)

1. Add benchmark aggregation functionality
    * [Pull request 148](https://bitbucket.org/ignitionrobotics/ign-cmake/pull-requests/148)
    * [Pull request 149](https://bitbucket.org/ignitionrobotics/ign-cmake/pull-requests/149)

1. Use `PRIVATE_FOR` to skip cmake dependencies in addition to pkg-config
    * [Pull request 147](https://bitbucket.org/ignitionrobotics/ign-cmake/pull-requests/147)

1. `upload_doc.sh`: actually use dry-run, and allow the user to pass in a 'y' or 'n'
    * [Pull request 146](https://bitbucket.org/ignitionrobotics/ign-cmake/pull-requests/146)

1. Set favicon
    * [Pull request 145](https://bitbucket.org/ignitionrobotics/ign-cmake/pull-requests/145)

1. Fix tagfile generation by preventing the inclusion of tutorials
    * [Pull request 142](https://bitbucket.org/ignitionrobotics/ign-cmake/pull-requests/142)

1. Update datainstall dir
    * [Pull request 141](https://bitbucket.org/ignitionrobotics/ign-cmake/pull-requests/141)

1. Allow tests to build without automatic linking against project lib
    * [Pull request 140](https://bitbucket.org/ignitionrobotics/ign-cmake/pull-requests/140)

### Ignition CMake 2.0.0 (2019-01-31)

1. Require cmake 3.10.2, support `CXX_STANDARD` 17
    * [Pull request 68](https://bitbucket.org/ignitionrobotics/ign-cmake/pull-requests/68)

* [Full list of pull requests]( https://bitbucket.org/ignitionrobotics/ign-cmake/branches/compare/ignition-cmake2_2.0.0%0Dign-cmake1#pull-requests)

## Ignition CMake 1.x

1. Fix race condition in test for issue 48
    * [Pull request 136](https://bitbucket.org/ignitionrobotics/ign-cmake/pull-requests/136)
    * [Issue 48](https://bitbucket.org/ignitionrobotics/ign-cmake/issue/48)

1. Account for inter-component dependencies when importing targets
    * [Pull request 131](https://bitbucket.org/ignitionrobotics/ign-cmake/pull-requests/131)
    * [Issue 48](https://bitbucket.org/ignitionrobotics/ign-cmake/issue/48)

### Ignition CMake 1.1.0

* Initial version bumped to 1.1.0 since there was a 1.1.0 prerelease

### Ignition CMake 1.0.0

* [Full list of pull requests](https://bitbucket.org/ignitionrobotics/ign-cmake/branches/compare/ignition-cmake1_1.0.0%0Dign-cmake0#pull-requests)

## Ignition CMake 0.x

1. IgnConfigureProject.cmake: fix small typo PKCONFIG -> PKGCONFIG
    * [Pull request 118](https://bitbucket.org/ignitionrobotics/ign-cmake/pull-requests/118)

### Ignition CMake 0.6.1

1. Fix duplicated imported target error
    * [Pull request 110](https://bitbucket.org/ignitionrobotics/ign-cmake/pull-requests/110)
    * [Issue 47](https://bitbucket.org/ignitionrobotics/ign-cmake/issue/47)

### Ignition CMake 0.6.0

1. Properly mark internal CMake cache variables as advanced
    * [Pull request 68](https://bitbucket.org/ignitionrobotics/ign-cmake/pull-requests/68)

1. Make line coverage by default, add separate coverage-branch target
    * [Pull request 66](https://bitbucket.org/ignitionrobotics/ign-cmake/pull-requests/66)

1. Refactor variable names in example test junit templates
    * [Pull request 57](https://bitbucket.org/ignitionrobotics/ign-cmake/pull-requests/57)

1. Suport for `CMAKE_BUILD_TYPE` None
    * [Pull request 54](https://bitbucket.org/ignitionrobotics/ign-cmake/pull-requests/54)

### Ignition CMake 0.5.0

1. FindJSONCPP: fix target when pkg-config is successful
    * [Pull request 50](https://bitbucket.org/ignitionrobotics/ign-cmake/pull-requests/50)

1. Add branch coverage
    * [Pull request 46](https://bitbucket.org/ignitionrobotics/ign-cmake/pull-requests/46)

1. Add FindOptiX.cmake
    * [Pull request 34](https://bitbucket.org/ignitionrobotics/ign-cmake/pull-requests/34)

### Ignition CMake 0.4.1

* [Full list of pull requests](https://bitbucket.org/ignitionrobotics/ign-cmake/branches/compare/ignition-cmake_0.4.1%0Dignition-cmake_0.4.0#pull-requests)

### Ignition CMake 0.4.0

