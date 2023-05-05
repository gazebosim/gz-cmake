# Copyright (C) 2023 Open Source Robotics Foundation
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

include(GzFindPackage)
include(GzStringAppend)
include(GzInstallAllHeaders)
include(GzGetLibSourcesAndUnitTests)
include(GzGetSources)
include(GzCreateCoreLibrary)
include(GzAddComponent)
include(GzBuildExecutables)
include(GzBuildTests)
include(GzCmakeLogging)
include(GzCxxStandard)

#################################################
# Macro to turn a list into a string
# Internal to gz-cmake.
macro(_gz_list_to_string _output _input_list)

  set(${_output})
  foreach(_item ${${_input_list}})
    # Append each item, and forward any extra options to gz_string_append, such
    # as DELIM or PARENT_SCOPE
    gz_string_append(${_output} "${_item}" ${ARGN})
  endforeach(_item)

endmacro()

#################################################
# Creates the `all` target. This function is private to gz-cmake.
function(_gz_create_all_target)

  add_library(${PROJECT_LIBRARY_TARGET_NAME}-all INTERFACE)

  install(
    TARGETS ${PROJECT_LIBRARY_TARGET_NAME}-all
    EXPORT ${PROJECT_LIBRARY_TARGET_NAME}-all
    LIBRARY DESTINATION ${GZ_LIB_INSTALL_DIR}
    ARCHIVE DESTINATION ${GZ_LIB_INSTALL_DIR}
    RUNTIME DESTINATION ${GZ_BIN_INSTALL_DIR}
    COMPONENT libraries)

endfunction()

#################################################
# Exports the `all` target. This function is private to gz-cmake.
function(_gz_export_target_all)

  # find_all_pkg_components is used as a variable in gz-all-config.cmake.in
  set(find_all_pkg_components "")
  get_property(all_known_components TARGET ${PROJECT_LIBRARY_TARGET_NAME}-all
    PROPERTY INTERFACE_IGN_ALL_KNOWN_COMPONENTS)

  if(all_known_components)
    foreach(component ${all_known_components})
      gz_string_append(find_all_pkg_components "find_dependency(${component} ${PROJECT_VERSION_FULL_NO_SUFFIX} EXACT)" DELIM "\n")
    endforeach()
  endif()

  _gz_create_cmake_package(ALL)

endfunction()

#################################################
# Used internally by _gz_add_library_or_component to report argument errors
macro(_gz_add_library_or_component_arg_error missing_arg)

  message(FATAL_ERROR "gz-cmake developer error: Must specify "
                      "${missing_arg} to _gz_add_library_or_component!")

endmacro()

#################################################
# This is only meant for internal use by gz-cmake. If you are a consumer
# of gz-cmake, please use gz_create_core_library(~) or
# gz_add_component(~) instead of this.
#
# _gz_add_library_or_component(LIB_NAME <lib_name>
#                               INCLUDE_DIR <dir_name>
#                               EXPORT_BASE <export_base>
#                               SOURCES <sources>)
#
macro(_gz_add_library_or_component)

  # NOTE: The following local variables are used in the Export.hh.in file, so if
  # you change their names here, you must also change their names there:
  # - include_dir
  # - export_base
  # - lib_name
  #
  # - _gz_export_base

  #------------------------------------
  # Define the expected arguments
  set(options INTERFACE)
  set(oneValueArgs LIB_NAME INCLUDE_DIR EXPORT_BASE)
  set(multiValueArgs SOURCES)

  #------------------------------------
  # Parse the arguments
  cmake_parse_arguments(_gz_add_library "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if(_gz_add_library_LIB_NAME)
    set(lib_name ${_gz_add_library_LIB_NAME})
  else()
    _gz_add_library_or_component_arg_error(LIB_NAME)
  endif()

  if(NOT _gz_add_library_INTERFACE)
    if(_gz_add_library_SOURCES)
      set(sources ${_gz_add_library_SOURCES})
    else()
      _gz_add_library_or_component_arg_error(SOURCES)
    endif()
  else()
    set(sources)
  endif()

  if(_gz_add_library_INCLUDE_DIR)
    set(include_dir ${_gz_add_library_INCLUDE_DIR})
  else()
    _gz_add_library_or_component_arg_error(INCLUDE_DIR)
  endif()

  if(_gz_add_library_EXPORT_BASE)
    set(export_base ${_gz_add_library_EXPORT_BASE})
  else()
    _gz_add_library_or_component_arg_error(EXPORT_BASE)
  endif()

  # check that export_base has no invalid symbols
  string(REPLACE "-" "_" export_base_replaced ${export_base})
  if(NOT ${export_base} STREQUAL ${export_base_replaced})
      message(FATAL_ERROR
        "export_base has a hyphen which is not"
        "supported by macros used for visibility")
  endif()

  #------------------------------------
  # Create the library target

  message(STATUS "Configuring library: ${lib_name}")

  if(_gz_add_library_INTERFACE)
    add_library(${lib_name} INTERFACE)
  else()
    add_library(${lib_name} ${sources})
  endif()

  #------------------------------------
  # Add fPIC if we are supposed to
  if(GZ_ADD_fPIC_TO_LIBRARIES AND NOT _gz_add_library_INTERFACE)
    target_compile_options(${lib_name} PRIVATE -fPIC)
  endif()

  if(NOT _gz_add_library_INTERFACE)

    #------------------------------------
    # Generate export macro headers
    # Note: INTERFACE libraries do not need the export header
    set(binary_include_dir
      "${CMAKE_BINARY_DIR}/include/${include_dir}")

    set(implementation_file_name "${binary_include_dir}/detail/Export.hh")

    include(GenerateExportHeader)
    # This macro will generate a header called detail/Export.hh which implements
    # some C-macros that are useful for exporting our libraries. The
    # implementation header does not provide any commentary or explanation for its
    # macros, so we tuck it away in the detail/ subdirectory, and then provide a
    # public-facing header that provides commentary for the macros.
    generate_export_header(${lib_name}
      BASE_NAME ${export_base}
      EXPORT_FILE_NAME ${implementation_file_name}
      EXPORT_MACRO_NAME DETAIL_${export_base}_VISIBLE
      NO_EXPORT_MACRO_NAME DETAIL_${export_base}_HIDDEN
      DEPRECATED_MACRO_NAME GZ_DEPRECATED_ALL_VERSIONS)

    set(install_include_dir
      "${GZ_INCLUDE_INSTALL_DIR_FULL}/${include_dir}")

    # Configure the installation of the automatically generated file.
    install(
      FILES "${implementation_file_name}"
      DESTINATION "${install_include_dir}/detail"
      COMPONENT headers)

    # Configure the public-facing header for exporting and deprecating. This
    # header provides commentary for the macros so that developers can know their
    # purpose.

    # TODO(CH3): Remove this on ticktock
    # This is to allow IGNITION_ prefixed export macros to generate in Export.hh
    # _using_gz_export_base is used in Export.hh.in's configuration!
    string(REGEX REPLACE "^GZ_" "IGNITION_" _gz_export_base ${export_base})

    configure_file(
      "${GZ_CMAKE_DIR}/Export.hh.in"
      "${binary_include_dir}/Export.hh")

    # Configure the installation of the public-facing header.
    install(
      FILES "${binary_include_dir}/Export.hh"
      DESTINATION "${install_include_dir}"
      COMPONENT headers)

    set_target_properties(
      ${lib_name}
      PROPERTIES
        SOVERSION ${PROJECT_VERSION_MAJOR}
        VERSION ${PROJECT_VERSION_FULL})

  endif()

  #------------------------------------
  # Configure the installation of the target

  install(
    TARGETS ${lib_name}
    EXPORT ${lib_name}
    LIBRARY DESTINATION ${GZ_LIB_INSTALL_DIR}
    ARCHIVE DESTINATION ${GZ_LIB_INSTALL_DIR}
    RUNTIME DESTINATION ${GZ_BIN_INSTALL_DIR}
    COMPONENT libraries)

endmacro()


#################################################
# _gz_cmake_parse_arguments(<prefix> <options> <oneValueArgs> <multiValueArgs> [ARGN])
#
# Set <prefix> to match the prefix that is given to cmake_parse_arguments(~).
# This should also match the name of the function or macro that called it.
#
# NOTE: This should only be used by functions inside of gz-cmake specifically.
# Other Gazebo projects should not use this macro.
#
macro(_gz_cmake_parse_arguments prefix options oneValueArgs multiValueArgs)

  cmake_parse_arguments(${prefix} "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if(${prefix}_UNPARSED_ARGUMENTS)

    # The user passed in some arguments that we don't currently recognize. We'll
    # emit a warning so they can check whether they're using the correct version
    # of gz-cmake.
    message(AUTHOR_WARNING
      "\nThe build script has specified some unrecognized arguments for ${prefix}(~):\n"
      "${${prefix}_UNPARSED_ARGUMENTS}\n"
      "Either the script has a typo, or it is using an unexpected version of gz-cmake. "
      "The version of gz-cmake currently being used is ${gz-cmake${GZ_CMAKE_VERSION_MAJOR}_VERSION}\n")

  endif()

endmacro()

#################################################
# gz_add_get_install_prefix_impl(GET_INSTALL_PREFIX_FUNCTION <get_install_prefix_function>
#                                GET_INSTALL_PREFIX_HEADER <get_install_prefix_function>
#                                OVERRIDE_INSTALL_PREFIX_ENV_VARIABLE <override_install_prefix_env_variable>)
#
# This macro adds to ${PROJECT_LIBRARY_TARGET_NAME} the implementation of
# of the function passed by GET_INSTALL_PREFIX_FUNCTION and declared in
# GET_INSTALL_PREFIX_HEADER .
#
# The defined functions implements a GET_INSTALL_PREFIX_FUNCTION that returns
# the installation directory of the package (CMAKE_INSTALL_PREFIX at build time)
# as following:
# * if the library is shared and GZ_ENABLE_RELOCATABLE_INSTALL is ON, by extracting the
#   location of the shared library via dladdr, and computing the corresponding
#   install prefix from it
# * if the library is static or GZ_ENABLE_RELOCATABLE_INSTALL is OFF, by using the exact
#   value of CMAKE_INSTALL_PREFIX that was hardcoded in the library at compilation time
#
# As in some cases it is important to have the ability to control and change the value returned by
# the GET_INSTALL_PREFIX_FUNCTION at runtime, in both cases the library returns the value of
# the OVERRIDE_INSTALL_PREFIX_ENV_VARIABLE if the environment variable is defined
#
# To use this macro, please add gz_find_package(DL)
# in the dependencies of your project
#
# Arguments are as follows:
#
# GET_INSTALL_PREFIX_FUNCTION: Required. The name (with namespace) of the function that returns
#          the install directory of the package. Example: gz::${GZ_DESIGNATION}::getInstallPrefix
#
# GET_INSTALL_PREFIX_HEADER: Required. The name (with full relative path) of the include that contains
#          the declaration of the ${GET_INSTALL_PREFIX_FUNCTION} function.
#          Example: gz/${GZ_DESIGNATION}/InstallationDirectories.hh
#
# OVERRIDE_INSTALL_PREFIX_ENV_VARIABLE: Required. The name of the environmental variable that can be
#          used to override the value returned by ${GET_INSTALL_PREFIX_FUNCTION} at runtime.
#          Example: GZ_${GZ_DESIGNATION_UPPER}_INSTALL_PREFIX

macro(gz_add_get_install_prefix_impl)
  set(_options)
  set(_oneValueArgs
    GET_INSTALL_PREFIX_FUNCTION
    GET_INSTALL_PREFIX_HEADER
    OVERRIDE_INSTALL_PREFIX_ENV_VARIABLE
  )
  set(_multiValueArgs )
  cmake_parse_arguments(gz_add_get_install_prefix_impl "${_options}" "${_oneValueArgs}" "${_multiValueArgs}" ${ARGN})

  if(NOT DEFINED gz_add_get_install_prefix_impl_GET_INSTALL_PREFIX_FUNCTION)
    message(FATAL_ERROR
      "gz_add_get_install_prefix_impl: missing parameter GET_INSTALL_PREFIX_FUNCTION")
  endif()

  if(NOT DEFINED gz_add_get_install_prefix_impl_GET_INSTALL_PREFIX_HEADER)
    message(FATAL_ERROR
      "gz_add_get_install_prefix_impl: missing parameter GET_INSTALL_PREFIX_HEADER")
  endif()

  if(NOT DEFINED gz_add_get_install_prefix_impl_OVERRIDE_INSTALL_PREFIX_ENV_VARIABLE)
    message(FATAL_ERROR
      "gz_add_get_install_prefix_impl: missing parameter OVERRIDE_INSTALL_PREFIX_ENV_VARIABLE")
  endif()


  if(NOT TARGET ${PROJECT_LIBRARY_TARGET_NAME})
    message(FATAL_ERROR
      "Target ${PROJECT_LIBRARY_TARGET_NAME} required by gz_add_get_install_prefix_impl\n"
      "does not exist.")
  endif()

  if(NOT TARGET ${DL_TARGET})
    message(FATAL_ERROR
      "gz_add_get_install_prefix_impl called without DL_TARGET defined,\n"
      "please add gz_find_package(DL) if you want to use gz_add_get_install_prefix_impl.")
  endif()

  get_target_property(target_type ${PROJECT_LIBRARY_TARGET_NAME} TYPE)
  if(NOT (target_type STREQUAL "STATIC_LIBRARY" OR target_type STREQUAL "MODULE_LIBRARY" OR target_type STREQUAL "SHARED_LIBRARY"))
    message(FATAL_ERROR "gz_add_get_install_prefix_impl: library ${_library} is of unsupported type ${target_type}")
  endif()


  set(gz_add_get_install_prefix_impl_GENERATED_CPP
        ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_LIBRARY_TARGET_NAME}_get_install_prefix_impl.cc)

  # Write cpp for shared or module library type
  option(GZ_ENABLE_RELOCATABLE_INSTALL "If ON, enable the feature of providing a relocatable install prefix in shared library." OFF)
  if ((target_type STREQUAL "MODULE_LIBRARY" OR target_type STREQUAL "SHARED_LIBRARY") AND GZ_ENABLE_RELOCATABLE_INSTALL)
    # We can't query the LOCATION property of the target due to https://cmake.org/cmake/help/v3.25/policy/CMP0026.html
    # We can only access the directory of the library at generation time via $<TARGET_FILE_DIR:tgt>
    file(GENERATE OUTPUT "${gz_add_get_install_prefix_impl_GENERATED_CPP}"
         CONTENT
"// This file is automatically generated by the gz_add_get_install_prefix_impl CMake macro.

#include <cstdlib>
#include <filesystem>
#include <string>
#include <system_error>

#include <dlfcn.h>

#include <${gz_add_get_install_prefix_impl_GET_INSTALL_PREFIX_HEADER}>

#ifdef _MSC_VER
  // Disable warnings related to the use of std::getenv
  // See https://stackoverflow.com/questions/66090389/c17-what-new-with-error-c4996-getenv-this-function-or-variable-may-be-un
  #pragma warning(disable: 4996)
#endif

std::string ${gz_add_get_install_prefix_impl_GET_INSTALL_PREFIX_FUNCTION}()
{
  if(const char* override_env_var = std::getenv(\"${gz_add_get_install_prefix_impl_OVERRIDE_INSTALL_PREFIX_ENV_VARIABLE}\"))
  {
    return std::string(override_env_var);
  }

  std::error_code fs_error;
  std::filesystem::path library_location;

  // Get location of the library
  Dl_info address_info;
  int res_val = dladdr(reinterpret_cast<void *>(&${gz_add_get_install_prefix_impl_GET_INSTALL_PREFIX_FUNCTION}), &address_info);
  if (address_info.dli_fname && res_val > 0)
  {
    library_location = address_info.dli_fname;
  }
  else
  {
    return \"${CMAKE_INSTALL_PREFIX}\";
  }

  const std::filesystem::path library_directory = library_location.parent_path();
  // Given the library_directory, return the install prefix via the relative path
#ifndef _WIN32
  const std::filesystem::path rel_path_from_install_prefix_to_lib = std::string(\"${CMAKE_INSTALL_LIBDIR}\");
#else
  const std::filesystem::path rel_path_from_install_prefix_to_lib = std::string(\"${CMAKE_INSTALL_BINDIR}\");
#endif
  const std::filesystem::path rel_path_from_lib_to_install_prefix =
    std::filesystem::relative(std::filesystem::current_path(), std::filesystem::current_path() / rel_path_from_install_prefix_to_lib, fs_error);

  if (fs_error)
  {
    return \"${CMAKE_INSTALL_PREFIX}\";
  }

  const std::filesystem::path install_prefix = library_directory / rel_path_from_lib_to_install_prefix;
  const std::filesystem::path install_prefix_canonical = std::filesystem::canonical(install_prefix, fs_error);

  if (fs_error)
  {
    return \"${CMAKE_INSTALL_PREFIX}\";
  }

  // Return install prefix
  return install_prefix_canonical.string();
}

#ifdef _MSC_VER
  #pragma warning(pop)
#endif
")
  else()
    # For static library, fallback to just provide return CMAKE_INSTALL_PREFIX
    file(GENERATE OUTPUT "${gz_add_get_install_prefix_impl_GENERATED_CPP}"
         CONTENT
"// This file is automatically generated by the gz_add_get_install_prefix_impl CMake macro.
#include <string>

#include <${gz_add_get_install_prefix_impl_GET_INSTALL_PREFIX_HEADER}>

#ifdef _MSC_VER
  #pragma warning(push)
  // Disable warnings related to the use of std::getenv
  // See https://stackoverflow.com/questions/66090389/c17-what-new-with-error-c4996-getenv-this-function-or-variable-may-be-un
  #pragma warning(disable: 4996)
#endif

std::string ${gz_add_get_install_prefix_impl_GET_INSTALL_PREFIX_FUNCTION}()
{
  if(const char* override_env_var = std::getenv(\"${gz_add_get_install_prefix_impl_OVERRIDE_INSTALL_PREFIX_ENV_VARIABLE}\"))
  {
    return std::string(override_env_var);
  }

  return \"${CMAKE_INSTALL_PREFIX}\";
}

#ifdef _MSC_VER
  #pragma warning(pop)
#endif
")
endif()

  # Add cpp to library
  target_sources(${PROJECT_LIBRARY_TARGET_NAME} PRIVATE ${gz_add_get_install_prefix_impl_GENERATED_CPP})

  # Link DL_TARGET that provides dladdr
  target_link_libraries(${PROJECT_LIBRARY_TARGET_NAME} PRIVATE ${DL_TARGET})

endmacro()
