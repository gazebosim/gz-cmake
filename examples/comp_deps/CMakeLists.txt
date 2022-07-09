cmake_minimum_required(VERSION 3.10.2 FATAL_ERROR)
project(gz-component_deps VERSION 0.1.0)
find_package(gz-cmake3 REQUIRED)
gz_configure_project(
  REPLACE_GZ_INCLUDE_PATH gz/component_deps
)
gz_configure_build(QUIT_IF_BUILD_ERRORS
  COMPONENTS child parent)
gz_create_packages()
gz_create_docs()
