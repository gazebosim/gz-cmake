# Ignition CMake : CMake Modules for Ignition Projects

**Maintainer:** grey AT openrobotics.org

[![GitHub open issues](https://img.shields.io/github/issues-raw/ignitionrobotics/ign-cmake.svg)](https://github.com/ignitionrobotics/ign-cmake/issues)
[![GitHub open pull requests](https://img.shields.io/github/issues-pr-raw/ignitionrobotics/ign-cmake.svg)](https://github.com/ignitionrobotics/ign-cmake/pulls)
[![Discourse topics](https://img.shields.io/discourse/https/community.gazebosim.org/topics.svg)](https://community.gazebosim.org)
[![Hex.pm](https://img.shields.io/hexpm/l/plug.svg)](https://www.apache.org/licenses/LICENSE-2.0)

Build | Status
-- | --
Test coverage | [![codecov](https://codecov.io/gh/ignitionrobotics/ign-cmake/branch/master/graph/badge.svg)](https://codecov.io/gh/ignitionrobotics/ign-cmake)  
Ubuntu Bionic | [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=ignition_cmake-ci-master-bionic-amd64)](https://build.osrfoundation.org/job/ignition_cmake-ci-master-bionic-amd64)  
Homebrew      | [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=ignition_cmake-ci-master-homebrew-amd64)](https://build.osrfoundation.org/job/ignition_cmake-ci-master-homebrew-amd64)  
Windows       | [![Build Status](https://build.osrfoundation.org/buildStatus/icon?job=ignition_cmake-ci-master-windows7-amd64)](https://build.osrfoundation.org/job/ignition_cmake-ci-master-windows7-amd64)

# Table of Contents

[Features](#features)

[Installation](#install)

* [Binary Installation](#binary-install)

* [Source Installation](#source-install)

    * [Prerequisites](#prerequisites)
  
    * [Building from Source](#building-from-source)

[Usage](#usage)

[Documentation](#documentation)

[Testing](#testing)

[Folder Structure](#folder-structure)

[Code of Conduct](#code-of-conduct)

[Contributing](#code-of-contributing)

[Versioning](#versioning)

[License](#license)

# Features

ignition-cmake provides a set of cmake modules that are used by the C++-based ignition projects. These modules help to control the quality and consistency of the ignition projects' build systems.

These modules are tailored to the ignition projects, so their use for non-ignition projects might be limited, but they may serve as a useful reference for setting up a modern cmake build system using good practices.

# Install

We recommend following the [Binary Installation](#binary-install) instructions to get up and running as quickly and painlessly as possible.

The [Source Installation](#source-install) instructions should be used if you need the very latest software improvements, you need to modify the code, or you plan to make a contribution.

## Binary Installation

On Ubuntu systems, `apt-get` can be used to install `ignition-cmake`:

```
$ sudo apt install libignition-cmake<#>-dev
```

Be sure to replace `<#>` with a number value, such as `1` or `2`, depending on which version you need.

## Source Installation

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

This library is used internally by the ignition projects. See other ignition projects for examples of how this gets used.

# Documentation

API documentation and tutorials can be accessed at
[https://ignitionrobotics.org/libs/cmake](https://ignitionrobotics.org/libs/cmake)

You can also generate the documentation from a clone of this repository by following these steps.

1. You will need [Doxygen](http://www.doxygen.org/). On Ubuntu Doxygen can be installed using

        sudo apt-get install doxygen

2. Clone the repository

        git clone https://github.com/ignitionrobotics/ign-cmake

3. Configure and build the documentation.

        cd ign-cmake
        mkdir build
        cd build
        cmake ..
        make doc

4. View the documentation by running the following command from the `build` directory.

        firefox doxygen/html/index.html

**Note** Alternatively, documentation for `ignition-cmake` can be found within the source code, and also in the [MIGRATION.md guide](https://github.com/ignitionrobotics/ign-cmake/blob/master/MIGRATION.md).

# Testing

Follow these steps to run tests and static code analysis in your clone of this repository.

1. Follow the [source install instruction](#source-install).

2. Run tests.

        make test

3. Static code checker.

        make codecheck

Additionally, a fuller suite of tests in the `examples` directory can be enabled by building with `BUILDSYSTEM_TESTING` enabled.
Tests can be run by building the `test` target. From your build directory you can run:

```
$ cmake .. -DBUILDSYSTEM_TESTING=1
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
[CONTRIBUTING.md](https://ignitionrobotics.org/docs/all/contributing).

# Code of Conduct

Please see
[CODE_OF_CONDUCT.md](https://github.com/ignitionrobotics/ign-gazebo/blob/master/CODE_OF_CONDUCT.md).

# Versioning

This library uses [Semantic Versioning](https://semver.org/). Additionally, this library is part of the [Ignition Robotics project](https://ignitionrobotics.org) which periodically releases a versioned set of compatible and complementary libraries. See the [Ignition Robotics website](https://ignitionrobotics.org) for version and release information.

# License

This library is licensed under [Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0). See also the [LICENSE](https://github.com/ignitionrobotics/ign-cmake/blob/master/LICENSE) file.
