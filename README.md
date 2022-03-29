# Ignition CMake : CMake Modules for Ignition Projects

**Maintainer:** grey AT openrobotics.org

[![GitHub open issues](https://img.shields.io/github/issues-raw/ignitionrobotics/ign-cmake.svg)](https://github.com/ignitionrobotics/ign-cmake/issues)
[![GitHub open pull requests](https://img.shields.io/github/issues-pr-raw/ignitionrobotics/ign-cmake.svg)](https://github.com/ignitionrobotics/ign-cmake/pulls)
[![Discourse topics](https://img.shields.io/discourse/https/community.gazebosim.org/topics.svg)](https://community.gazebosim.org)
[![Hex.pm](https://img.shields.io/hexpm/l/plug.svg)](https://www.apache.org/licenses/LICENSE-2.0)

Build | Status
-- | --
Ubuntu Bionic | [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=ignition_cmake-ci-ign-cmake2-bionic-amd64)](https://build.osrfoundation.org/job/ignition_cmake-ci-ign-cmake2-bionic-amd64)
Homebrew      | [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=ignition_cmake-ci-ign-cmake2-homebrew-amd64)](https://build.osrfoundation.org/job/ignition_cmake-ci-ign-cmake2-homebrew-amd64)
Windows       | [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=ignition_cmake-ci-ign-cmake2-windows7-amd64)](https://build.osrfoundation.org/job/ignition_cmake-ci-ign-cmake2-windows7-amd64)

# Table of Contents

[Features](#features)

[Installation](#install)

* [Binary Install](#binary-install)

* [Source Install](#source-install)

    * [Prerequisites](#prerequisites)

    * [Building from Source](#building-from-source)

[Usage](#usage)

[Folder Structure](#folder-structure)

[Code of Conduct](#code-of-conduct)

[Contributing](#contributing)

[Versioning](#versioning)

[License](#license)

# Features

ignition-cmake provides a set of cmake modules that are used by the C++-based ignition projects. These modules help to control the quality and consistency of the ignition projects' build systems.

These modules are tailored to the ignition projects, so their use for non-ignition projects might be limited, but they may serve as a useful reference for setting up a modern cmake build system using good practices.

# Install

We recommend following the [Binary Install](#binary-install) instructions to get up and running as quickly and painlessly as possible.

The [Source Install](#source-install) instructions should be used if you need the very latest software improvements, you need to modify the code, or you plan to make a contribution.

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

### Building from Source

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

Documentation can be accessed at https://ignitionrobotics.org/libs/cmake
[Examples](examples/) are available in this repository.
[Tutorials](tutorials/) are also available in this repository.

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
[CONTRIBUTING.md](https://ignitionrobotics.org/docs/all/contributing).

# Code of Conduct

Please see
[CODE_OF_CONDUCT.md](https://github.com/ignitionrobotics/ign-gazebo/blob/main/CODE_OF_CONDUCT.md).

# Versioning

This library uses [Semantic Versioning](https://semver.org/). Additionally, this library is part of the [Ignition Robotics project](https://ignitionrobotics.org) which periodically releases a versioned set of compatible and complementary libraries. See the [Ignition Robotics website](https://ignitionrobotics.org) for version and release information.

# License

This library is licensed under [Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0). See also the [LICENSE](https://github.com/ignitionrobotics/ign-cmake/blob/main/LICENSE) file.
