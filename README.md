# Ignition CMake : CMake Modules for Ignition Projects

**Maintainer:** grey AT openrobotics.org

[![GitHub open issues](https://img.shields.io/github/issues-raw/ignitionrobotics/ign-cmake.svg)](https://github.com/ignitionrobotics/ign-cmake/issues)
[![GitHub open pull requests](https://img.shields.io/github/issues-pr-raw/ignitionrobotics/ign-cmake.svg)](https://github.com/ignitionrobotics/ign-cmake/pulls)
[![Discourse topics](https://img.shields.io/discourse/https/community.gazebosim.org/topics.svg)](https://community.gazebosim.org)
[![Hex.pm](https://img.shields.io/hexpm/l/plug.svg)](https://www.apache.org/licenses/LICENSE-2.0)

Build | Status
-- | --
Test coverage | [![codecov](https://codecov.io/bb/ignitionrobotics/ign-cmake/branch/default/graph/badge.svg)](https://codecov.io/bb/ignitionrobotics/ign-cmake)
Ubuntu Bionic | [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=ignition_cmake-ci-default-bionic-amd64)](https://build.osrfoundation.org/job/ignition_cmake-ci-default-bionic-amd64)
Homebrew      | [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=ignition_cmake-ci-default-homebrew-amd64)](https://build.osrfoundation.org/job/ignition_cmake-ci-default-homebrew-amd64)
Windows       | [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=ignition_cmake-ci-default-windows7-amd64)](https://build.osrfoundation.org/job/ignition_cmake-ci-default-windows7-amd64)

# Table of Contents

[Features](#markdown-header-features)

[Install](#markdown-header-install)

* [Binary Install](#markdown-header-binary-install)

* [Source Install](#markdown-header-source-install)

    * [Prerequisites](#markdown-header-prerequisites)

    * [Building from Source](#markdown-header-building-from-source)

[Usage](#markdown-header-usage)

[Documentation](#markdown-header-documentation)

[Testing](#markdown-header-testing)

[Folder Structure](#markdown-header-folder-structure)

[Code of Conduct](#markdown-header-code-of-conduct)

[Contributing](#markdown-header-code-of-contributing)

[Versioning](#markdown-header-versioning)

[License](#markdown-header-license)

# Features

ignition-cmake provides a set of cmake modules that are used by the C++-based ignition projects. These modules help to control the quality and consistency of the ignition projects' build systems.

These modules are tailored to the ignition projects, so their use for non-ignition projects might be limited, but they may serve as a useful reference for setting up a modern cmake build system using good practices.

# Install

We recommend following the [Binary Install](#markdown-header-binary-install) instructions to get up and running as quickly and painlessly as possible.

The [Source Install](#markdown-header-source-install) instructions should be used if you need the very latest software improvements, you need to modify the code, or you plan to make a contribution.

## Binary Install

On Ubuntu systems, `apt-get` can be used to install `ignition-cmake`:

```
$ sudo apt install libignition-cmake<#>-dev
```

Be sure to replace `<#>` with a number value, such as `1` or `2`, depending on which version you need.

## Source Install

### Prerequisites

The only prerequisite of `ignition-cmake` is `cmake`. Ubuntu users can install cmake with the package manager:

```
$ sudo apt install cmake
```

### Building from source

To build and install from source, you can clone the repo and use cmake to install the modules as though this is a regular cmake project:

```
$ git clone https://github.com/ignitionrobotics/ign-cmake
$ cd ign-cmake
$ mkdir build
$ cd build
$ cmake .. -DCMAKE_INSTALL_PREFIX=/path/to/install/dir
$ make -j8
$ make install
```

Replace `/path/to/install/dir` to whatever directory you want to install this package to.

# Usage

This library is used internally by the ignition projects. See other ignition projects for examples of how this gets used.

# Documentation

Documentation for `ignition-cmake` can be found within the source code, and also in the [MIGRATION.md guide](https://github.com/ignitionrobotics/ign-cmake/blob/master/MIGRATION.md).

# Testing

Tests can be run by building the `test` target. From your build directory you can run:

```
$ make test
```

# Folder Structure

* `cmake`: cmake modules that get installed by this package
* `codecheck`: code linting and static analyzing utilities that get installed by this package
* `config`: template files for producing the config-files of `ignition-cmake`; these are only used internally
* `doc`: template files to help ignition projects generate their own documentation
* `examples`: fake projects that are used to test `ignition-cmake`
* `include`: C++ utility header files that get installed with `ignition-cmake`
* `test`: a directory of tests for the C++ utility component of `ignition-cmake`
* `tools`: scripts for continuous integration testing

# Contributing

Please see
[CONTRIBUTING.md](https://github.com/ignitionrobotics/ign-gazebo/blob/master/CONTRIBUTING.md).

# Code of Conduct

Please see
[CODE_OF_CONDUCT.md](https://github.com/ignitionrobotics/ign-gazebo/blob/master/CODE_OF_CONDUCT.md).

# Versioning

This library uses [Semantic Versioning](https://semver.org/). Additionally, this library is part of the [Ignition Robotics project](https://ignitionrobotics.org) which periodically releases a versioned set of compatible and complementary libraries. See the [Ignition Robotics website](https://ignitionrobotics.org) for version and release information.

# License

This library is licensed under [Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0). See also the [LICENSE](https://github.com/ignitionrobotics/ign-cmake/blob/master/LICENSE) file.
