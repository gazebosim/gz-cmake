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
  # Examine the build type. If we do not recognize the type, we will generate
  # an error, so this must come before the error handling.
  ign_parse_build_type()

  #============================================================================
  # Ask whether we should make a shared or static library
  option(BUILD_SHARED_LIBS "Set this to true to generate a shared library (recommended), or false for a static library" ON)

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
    include(CTest)
    enable_testing()


    #--------------------------------------
    # Set up the compiler flags
    ign_set_compiler_flags()


    #--------------------------------------
    # Set up the compiler feature flags to help us choose our standard
    ign_set_cxx_feature_flags()


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
    add_subdirectory(src)
    add_subdirectory(include)
    add_subdirectory(test)


    #--------------------------------------
    # If we made it this far, the configuration was successful
    message(STATUS "Build configuration successful")

  endif()

endmacro()

macro(ign_set_cxx_feature_flags)

  set(IGN_KNOWN_CXX_STANDARDS 11 14)

  set(IGN_CXX_11_FEATURES
    cxx_alias_templates
    cxx_alignas
    cxx_alignof
    cxx_attributes
    cxx_auto_type
    cxx_constexpr
#    cxx_decltype_incomplete_return_types # Not yet supported in MSVC (as of 2017)
    cxx_decltype
    cxx_default_function_template_args
    cxx_defaulted_functions
    cxx_defaulted_move_initializers
    cxx_delegating_constructors
    cxx_deleted_functions
    cxx_enum_forward_declarations
    cxx_explicit_conversions
    cxx_extended_friend_declarations
    cxx_extern_templates
    cxx_final
    cxx_func_identifier
    cxx_generalized_initializers
    cxx_inheriting_constructors
    cxx_inline_namespaces
    cxx_lambdas
    cxx_local_type_template_args
    cxx_long_long_type
    cxx_noexcept
    cxx_nonstatic_member_init
    cxx_nullptr
    cxx_override
    cxx_range_for
    cxx_raw_string_literals
    cxx_reference_qualified_functions
    cxx_right_angle_brackets
    cxx_rvalue_references
    cxx_sizeof_member
    cxx_static_assert
    cxx_strong_enums
    cxx_thread_local
    cxx_trailing_return_types
    cxx_unicode_literals
    cxx_unrestricted_unions
    cxx_user_literals
    cxx_variadic_macros
    cxx_variadic_templates)

  set(IGN_CXX_14_FEATURES
    cxx_attribute_deprecated
    cxx_binary_literals
    cxx_contextual_conversions
    cxx_decltype_auto
    cxx_digit_separators
    cxx_generic_lambdas
    cxx_lambda_init_captures
#    cxx_relaxed_constexpr # Not yet supported in MSVC (as of 2017)
    cxx_return_type_deduction
    cxx_variable_templates)


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
