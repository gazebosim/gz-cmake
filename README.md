# Ignition CMake

** CMake modules to be used by the Ignition projects. **

This package is required to build ignition projects, as well as to link your own
projects against them. It provides modules that are used to find dependencies
of ignition projects and generate cmake targets for consumers of ignition projects
to link against.

## Installation

Standard installation can be performed in UNIX systems using the following
steps:

 - mkdir build/
 - cd build/
 - cmake ..
 - sudo make install

### Contribution guidelines ###

* Writing tests
* Code review
* Other guidelines

## Uninstallation

To uninstall the software installed with the previous steps:

 - cd build/
 - sudo make uninstall
