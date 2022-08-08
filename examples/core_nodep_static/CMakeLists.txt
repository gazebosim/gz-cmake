cmake_minimum_required(VERSION 3.10.2 FATAL_ERROR)
project(gz-core_no_deps_static VERSION 0.1.0)
find_package(gz-cmake4 REQUIRED)
gz_configure_project(
  REPLACE_INCLUDE_PATH gz/core_no_deps_static
)
OPTION(BUILD_SHARED_LIBS OFF)
gz_configure_build(QUIT_IF_BUILD_ERRORS)
gz_create_packages()
gz_create_docs()
