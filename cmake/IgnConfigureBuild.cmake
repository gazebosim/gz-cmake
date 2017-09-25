#.rst
# IgnBuildProject
# -------------------
#
# ign_configure_build()
#
# Configures the build rules of an ignition library project.
#
#===============================================================================
# Copyright (C) 2017 Open Source Robotics Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#################################################
# Configure the build of the ignition project
# Pass the argument QUIT_IF_BUILD_ERRORS to have this macro quit cmake when the
# build_errors
macro(ign_configure_build)

  #============================================================================
  # Parse the arguments that are passed in
  set(options QUIT_IF_BUILD_ERRORS)
  cmake_parse_arguments(ign_configure_build "${options}" "" "" ${ARGN})


  #============================================================================
  # Check if the user wants to build tests
  option(DISABLE_TEST_CONFIGURATION "Do not configure any of the tests" OFF)
  # TODO(MXG): Consider replacing this variable with DISABLE_TEST_CONFIGURATION,
  #            because it would be a more accurate name and a more natural
  #            "option" to pass in. We're keeping ENABLE_TESTS_COMPILATION for
  #            now to support backwards compatibility.
  # If ENABLE_TESTS_COMPILATION is defined, it will take precedence over
  # DISABLE_TEST_CONFIGURATION. It can be defined from the command line when
  # invoking cmake using -DENABLE_TESTS_COMPILATION=val
  if(NOT DEFINED ENABLE_TESTS_COMPILATION)
    if(DISABLE_TEST_CONFIGURATION)
      set(ENABLE_TEST_COMPILATION false)
    else()
      set(ENABLE_TEST_COMPILATION true)
    endif()
  endif()

  #--------------------------------------
  # Examine the build type. If we do not recognize the type, we will generate
  # an error, so this must come before the error handling.
  ign_parse_build_type()

  #============================================================================
  # Print warnings and errors
  if(build_warnings)
    message(STATUS "BUILD WARNINGS")
    foreach (msg ${build_warnings})
      message(STATUS ${msg})
    endforeach ()
    message(STATUS "END BUILD WARNINGS\n")
  endif (build_warnings)

  if(build_errors)
    message(STATUS "BUILD ERRORS: These must be resolved before compiling.")
    foreach(msg ${build_errors})
      message(STATUS ${msg})
    endforeach()
    message(STATUS " END BUILD ERRORS\n")

    set(error_str "Errors encountered in build. Please see BUILD ERRORS above.")

    if(ign_configure_build_QUIT_IF_BUILD_ERRORS)
      message(FATAL_ERROR "${error_str}")
    else()
      message(WARNING "${error_str}")
    endif()

  endif()


  #============================================================================
  # If there are no build errors, try building
  if(NOT build_errors)

    #--------------------------------------
    # Turn on testing
    enable_testing()


    #--------------------------------------
    # Set up the compiler flags
    ign_set_compiler_flags()


    #--------------------------------------
    # We want to include both the include directory from the source tree and
    # also the include directory that's generated in the build folder,
    # ${PROJECT_BINARY_DIR}, so that headers which are generated via cmake will
    # be visible to the compiler.
    include_directories(
      ${PROJECT_SOURCE_DIR}/include
      ${PROJECT_BINARY_DIR}/include)


    #--------------------------------------
    # Clear the test results directory
    execute_process(COMMAND cmake -E remove_directory ${CMAKE_BINARY_DIR}/test_results)
    execute_process(COMMAND cmake -E make_directory ${CMAKE_BINARY_DIR}/test_results)


    #--------------------------------------
    # Add all the source code directories
    set(TEST_TYPE "UNIT")
    add_subdirectory(src)
    add_subdirectory(include)
    add_subdirectory(test)


    #--------------------------------------
    # If we made it this far, the configuration was successful
    message(STATUS "Build configuration successful")

  endif()

endmacro()

macro(ign_parse_build_type)

  #============================================================================
  # If a build type is not specified, set it to RelWithDebInfo by default
  if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "RelWithDebInfo")
  endif()

  # Convert to uppercase in order to support arbitrary capitalization
  string(TOUPPER "${CMAKE_BUILD_TYPE}" CMAKE_BUILD_TYPE_UPPERCASE)

  #============================================================================
  # Set variables based on the build type
  set(BUILD_TYPE_PROFILE FALSE)
  set(BUILD_TYPE_RELEASE FALSE)
  set(BUILD_TYPE_RELWITHDEBINFO FALSE)
  set(BUILD_TYPE_MINSIZEREL FALSE)
  set(BUILD_TYPE_DEBUG FALSE)

  if("${CMAKE_BUILD_TYPE_UPPERCASE}" STREQUAL "DEBUG")
    set(BUILD_TYPE_DEBUG TRUE)
  elseif("${CMAKE_BUILD_TYPE_UPPERCASE}" STREQUAL "RELEASE")
    set(BUILD_TYPE_RELEASE TRUE)
  elseif("${CMAKE_BUILD_TYPE_UPPERCASE}" STREQUAL "RELWITHDEBINFO")
    set(BUILD_TYPE_RELWITHDEBINFO TRUE)
  elseif("${CMAKE_BUILD_TYPE_UPPERCASE}" STREQUAL "MINSIZEREL")
    set(BUILD_TYPE_MINSIZEREL TRUE)
  elseif("${CMAKE_BUILD_TYPE_UPPERCASE}" STREQUAL "COVERAGE")
    include(IgnCodeCoverage)
    set(BUILD_TYPE_DEBUG TRUE)
    ign_setup_target_for_coverage(coverage ctest coverage)
  elseif("${CMAKE_BUILD_TYPE_UPPERCASE}" STREQUAL "PROFILE")
    set(BUILD_TYPE_PROFILE TRUE)
  else()
    ign_build_error("CMAKE_BUILD_TYPE [${CMAKE_BUILD_TYPE}] unknown. Valid options are: Debug Release RelWithDebInfo MinSizeRel Profile Check")
  endif()

endmacro()
