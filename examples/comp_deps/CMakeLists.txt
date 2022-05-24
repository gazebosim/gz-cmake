cmake_minimum_required(VERSION 3.10.2 FATAL_ERROR)
project(ignition-component_deps VERSION 0.1.0)
find_package(ignition-cmake3 REQUIRED)
gz_configure_project()
gz_configure_build(QUIT_IF_BUILD_ERRORS
  COMPONENTS child parent)
gz_create_packages()
gz_create_docs()
