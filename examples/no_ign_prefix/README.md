# no\_ignition\_prefix example

## Configuring project name

This package uses the `NO_IGNITION_PREFIX` option in `ign_configure_project`
to allow a cmake package name without the `ignition-` prefix.
To confirm, configure this package and
`package_source` and then observe that the tarball,
pkg-config `.pc` file, and cmake config files omit the `ignition-` prefix:

~~~
mkdir build
cd build
cmake ..
make package_source
~~~

* `no_ignition_prefix-0.1.0.tar.bz2`
* `cmake/no_ignition_prefix-config.cmake`
* `cmake/pkgconfig/no_ignition_prefix.pc`

## Configuring include directory names

This package uses the `REPLACE_IGNITION_INCLUDE_PATH` option in `ign_configure_project`
to allow a custom include path of `no_ign`, which doesn't start with `ignition/`.
To confirm, build the package and observe that `AlmostEmpty.cc`
compiles successfully while including `no_ign/Export.hh`:

~~~
mkdir build
cd build
cmake ..
make
~~~
