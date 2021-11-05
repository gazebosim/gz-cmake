# no\_ignition\_prefix

This package uses the `NO_IGNITION_PREFIX` option to `ign_configure_project`
to allow a cmake package name without the `ignition-` prefix.
To confirm, build this package and then observe that the tarball,
pkg-config `.pc` file, and cmake config files omit the `ignition-` prefix:

~~~
mkdir build
cd build
cmake ..
make
make package_source
~~~

* `no_ignition_prefix-0.1.0.tar.bz2`
* `cmake/no_ignition_prefix-config.cmake`
* `cmake/pkgconfig/no_ignition_prefix.pc`
