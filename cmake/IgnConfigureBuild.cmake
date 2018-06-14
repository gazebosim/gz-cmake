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
  set(oneValueArgs)
  set(multiValueArgs COMPONENTS)
  cmake_parse_arguments(ign_configure_build "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  #============================================================================
  # Examine the build type. If we do not recognize the type, we will generate
  # an error, so this must come before the error handling.
  ign_parse_build_type()

  #============================================================================
  # Ask whether we should make a shared or static library.
  option(BUILD_SHARED_LIBS "Set this to true to generate shared libraries (recommended), or false for static libraries" ON)

  #============================================================================
  # Print warnings and errors
  if(build_warnings)
    message("-- BUILD WARNINGS")
    foreach (msg ${build_warnings})
      message("-- ${msg}")
    endforeach ()
    message("-- END BUILD WARNINGS\n")
  endif (build_warnings)

  if(build_errors)
    message("-- BUILD ERRORS: These must be resolved before compiling.")
    foreach(msg ${build_errors})
      message("-- ${msg}")
    endforeach()
    message("-- END BUILD ERRORS\n")

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
    # Create the "all" meta-target
    ign_create_all_target()


    #--------------------------------------
    # Add the source code directories of the core library
    add_subdirectory(src)
    _ign_find_include_script()
    add_subdirectory(test)

    #--------------------------------------
    # Add the source, include, and test directories to the cppcheck dirs.
    # CPPCHECK_DIRS is used in IgnCodeCheck. The variable specifies the
    # directories static code analyzers should check. Additional directories
    # are added for each component.
    set (CPPCHECK_DIRS)
    set (potential_cppcheck_dirs 
      ${CMAKE_SOURCE_DIR}/src
      ${CMAKE_SOURCE_DIR}/include
      ${CMAKE_SOURCE_DIR}/test/integration
      ${CMAKE_SOURCE_DIR}/test/regression
      ${CMAKE_SOURCE_DIR}/test/performance)
    foreach (dir ${potential_cppcheck_dirs})
      if (EXISTS ${dir})
        list (APPEND CPPCHECK_DIRS ${dir})
      endif()
    endforeach()

    # Includes for cppcheck. This sets include paths for cppcheck. Additional
    # directories are added for each component.
    set (CPPCHECK_INCLUDE_DIRS)
    set (potential_cppcheck_include_dirs
      ${CMAKE_BINARY_DIR}
      ${CMAKE_SOURCE_DIR}/include/ignition/${IGN_DESIGNATION}
      ${CMAKE_SOURCE_DIR}/test/integration
      ${CMAKE_SOURCE_DIR}/test/regression
      ${CMAKE_SOURCE_DIR}/test/performance)
    foreach (dir ${potential_cppcheck_include_dirs})
      if (EXISTS ${dir})
        list (APPEND CPPCHECK_INCLUDE_DIRS ${dir})
      endif()
    endforeach()

    #--------------------------------------
    # Initialize the list of header directories that should be parsed by doxygen
    set(ign_doxygen_component_input_dirs "${CMAKE_SOURCE_DIR}/include")

    #--------------------------------------
    # Add the source code directories of each component if they exist
    foreach(component ${ign_configure_build_COMPONENTS})

      if(NOT SKIP_${component})

        # Append the component's include directory to both CPPCHECK_DIRS and
        # CPPCHECK_INCLUDE_DIRS
        list(APPEND CPPCHECK_DIRS ${CMAKE_CURRENT_LIST_DIR}/${component}/include)
        list(APPEND CPPCHECK_INCLUDE_DIRS
          ${CMAKE_CURRENT_LIST_DIR}/${component}/include)

        # Note: It seems we need to give the delimiter exactly this many
        # backslashes in order to get a \ plus a newline. This might be
        # dependent on the implementation of ign_string_append, so be careful
        # when changing the implementation of that function.
        ign_string_append(ign_doxygen_component_input_dirs
          "${CMAKE_CURRENT_LIST_DIR}/${component}/include"
          DELIM " \\\\\\\\\n  ")

        # Append the component's source directory to CPPCHECK_DIRS.
        if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/${component}/src")
          list(APPEND CPPCHECK_DIRS ${CMAKE_CURRENT_LIST_DIR}/${component}/src)
        endif()

        if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/${component}/CMakeLists.txt")

          # If the component's directory has a top-level CMakeLists.txt, use
          # that.
          add_subdirectory(${component})

        else()

          # If the component's directory does not have a top-level
          # CMakeLists.txt, try to call the expected set of subdirectories
          # individually. This saves us from needing to create very redundant
          # CMakeLists.txt files that do nothing but redirect us to these
          # subdirectories.

          # Add the source files
          if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/${component}/src/CMakeLists.txt")
            add_subdirectory(${component}/src)
          endif()

          _ign_find_include_script(COMPONENT ${component})

          # Add the tests
          if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/${component}/test/CMakeLists.txt")
            add_subdirectory(${component}/test)
          endif()
        endif()

      else()

        set(skip_msg "Skipping the component [${component}]")
        if(${component}_MISSING_DEPS)
          ign_string_append(skip_msg "because the following packages are missing: ${${component}_MISSING_DEPS}")
        endif()

        message(STATUS "${skip_msg}")

      endif()

    endforeach()

    #--------------------------------------
    # Export the "all" meta-target
    ign_export_target_all()

    #--------------------------------------
    # Create codecheck target
    include(IgnCodeCheck)
    ign_setup_target_for_codecheck()

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
    ${IGN_CXX_11_FEATURES}
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

function(_ign_find_include_script)

  #------------------------------------
  # Define the expected arguments
  set(options) # Unused
  set(oneValueArgs COMPONENT)
  set(multiValueArgs) # Unused

  #------------------------------------
  # Parse the arguments
  cmake_parse_arguments(_ign_find_include_script "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  #------------------------------------
  # Set the starting point
  set(include_start "${CMAKE_CURRENT_LIST_DIR}")

  if(_ign_find_include_script_COMPONENT)
    ign_string_append(include_start ${_ign_find_include_script_COMPONENT} DELIM "/")
  endif()

  # Check each level of depth to find the first CMakeLists.txt. This allows us
  # to have custom behavior for each include directory structure while also
  # allowing us to just have one leaf CMakeLists.txt file if a project doesn't
  # need any custom configuration in its include directories.
  if(EXISTS "${include_start}/include/CMakeLists.txt")
    add_subdirectory("${include_start}/include")
  elseif(EXISTS "${include_start}/include/ignition/CMakeLists.txt")
    add_subdirectory("${include_start}/include/ignition")
  elseif(EXISTS "${include_start}/include/ignition/${IGN_DESIGNATION}/CMakeLists.txt")
    add_subdirectory("${include_start}/include/ignition/${IGN_DESIGNATION}")
  else()
    # TODO: Should we print a warning or a status message here to indicate that
    # no script was found for the include directory? Perhaps not all projects
    # will have one.
  endif()

endfunction()

macro(ign_parse_build_type)

  #============================================================================
  # If a build type is not specified, set it to RelWithDebInfo by default
  if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "RelWithDebInfo")
  endif()

  # Handle NONE in MSVC as blank and default to RelWithDebInfo
  if (MSVC AND CMAKE_BUILD_TYPE_UPPERCASE STREQUAL "NONE")
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
  set(BUILD_TYPE_NONE FALSE)
  set(BUILD_TYPE_DEBUG FALSE)

  if("${CMAKE_BUILD_TYPE_UPPERCASE}" STREQUAL "DEBUG")
    set(BUILD_TYPE_DEBUG TRUE)
  elseif("${CMAKE_BUILD_TYPE_UPPERCASE}" STREQUAL "RELEASE")
    set(BUILD_TYPE_RELEASE TRUE)
  elseif("${CMAKE_BUILD_TYPE_UPPERCASE}" STREQUAL "RELWITHDEBINFO")
    set(BUILD_TYPE_RELWITHDEBINFO TRUE)
  elseif("${CMAKE_BUILD_TYPE_UPPERCASE}" STREQUAL "MINSIZEREL")
    set(BUILD_TYPE_MINSIZEREL TRUE)
  elseif("${CMAKE_BUILD_TYPE_UPPERCASE}" STREQUAL "NONE")
    set(BUILD_TYPE_NONE TRUE)
  elseif("${CMAKE_BUILD_TYPE_UPPERCASE}" STREQUAL "COVERAGE")
    include(IgnCodeCoverage)
    set(BUILD_TYPE_DEBUG TRUE)
    ign_setup_target_for_coverage(
      OUTPUT_NAME coverage
      TARGET_NAME coverage
      TEST_RUNNER ctest)
    ign_setup_target_for_coverage(
      BRANCH_COVERAGE
      OUTPUT_NAME coverage-branch
      TARGET_NAME coverage-branch
      TEST_RUNNER ctest)
  elseif("${CMAKE_BUILD_TYPE_UPPERCASE}" STREQUAL "PROFILE")
    set(BUILD_TYPE_PROFILE TRUE)
  else()
    ign_build_error("CMAKE_BUILD_TYPE [${CMAKE_BUILD_TYPE}] unknown. Valid options are: Debug Release RelWithDebInfo MinSizeRel Profile Check")
  endif()

endmacro()
