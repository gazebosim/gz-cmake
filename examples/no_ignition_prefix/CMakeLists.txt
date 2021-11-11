cmake_minimum_required(VERSION 3.10.2 FATAL_ERROR)
project(no_ignition_prefix VERSION 0.1.0)
find_package(ignition-cmake2 REQUIRED)
ign_configure_project(
  NO_IGNITION_PREFIX
  REPLACE_IGNITION_INCLUDE_PATH no_ign)
ign_configure_build(QUIT_IF_BUILD_ERRORS)
ign_create_packages()
ign_create_docs()
