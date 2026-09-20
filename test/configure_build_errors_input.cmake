cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)

if(NOT DEFINED GZ_CMAKE_MODULE_DIR)
  message(FATAL_ERROR "GZ_CMAKE_MODULE_DIR must point to the gz-cmake modules")
endif()

list(APPEND CMAKE_MODULE_PATH "${GZ_CMAKE_MODULE_DIR}")
include(GzCMake)

set(build_errors
  "First synthetic build error"
  "Second synthetic build error"
)

if(QUIT_IF_BUILD_ERRORS)
  gz_configure_build(QUIT_IF_BUILD_ERRORS)
else()
  gz_configure_build()
endif()

message(STATUS "continued after gz_configure_build")
