#.rst
# IgnConfigureProject
# -------------------
#
# ign_configure_project([VERSION_SUFFIX <pre|alpha|beta|etc>])
#
# Sets up an ignition library project.
#
# NO_IGNITION_PREFIX: Optional. Don't use ignition as prefix in
#     cmake project name.
# REPLACE_IGNITION_INCLUDE_PATH: Optional. Specify include folder
#     names to replace the default value of
#     ignition/${GZ_DESIGNATION}
# VERSION_SUFFIX: Optional. Specify a prerelease version suffix.
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
# Initialize the ignition project
macro(ign_configure_project)

  #------------------------------------
  # Define the expected arguments
  set(options NO_IGNITION_PREFIX)
  set(oneValueArgs REPLACE_IGNITION_INCLUDE_PATH VERSION_SUFFIX)
  set(multiValueArgs) # We are not using multiValueArgs yet

  #------------------------------------
  # Parse the arguments
  _ign_cmake_parse_arguments(ign_configure_project "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  # Note: The following are automatically defined by project(~) in cmake v3:
  # PROJECT_NAME
  # PROJECT_VERSION_MAJOR
  # PROJECT_VERSION_MINOR
  # PROJECT_VERSION_PATCH

  if(ign_configure_project_VERSION_SUFFIX)
    set(PROJECT_VERSION_SUFFIX ${ign_configure_project_VERSION_SUFFIX})
  endif()

  #============================================================================
  # Extract the designation
  #============================================================================
  set(GZ_DESIGNATION ${PROJECT_NAME})
  # Remove the leading "ignition-"
  string(REGEX REPLACE "ignition-" "" GZ_DESIGNATION ${GZ_DESIGNATION})
  # Remove the trailing version number
  string(REGEX REPLACE "[0-9]+" "" GZ_DESIGNATION ${GZ_DESIGNATION})

  #============================================================================
  # Set project variables
  #============================================================================

  if(ign_configure_project_NO_IGNITION_PREFIX)
    set(PROJECT_NAME_NO_VERSION ${GZ_DESIGNATION})
  else()
    set(PROJECT_NAME_NO_VERSION "ignition-${GZ_DESIGNATION}")
  endif()
  string(TOLOWER ${PROJECT_NAME_NO_VERSION} PROJECT_NAME_NO_VERSION_LOWER)
  string(TOUPPER ${PROJECT_NAME_NO_VERSION} PROJECT_NAME_NO_VERSION_UPPER)
  string(TOLOWER ${PROJECT_NAME} PROJECT_NAME_LOWER)
  string(TOUPPER ${PROJECT_NAME} PROJECT_NAME_UPPER)
  string(TOLOWER ${GZ_DESIGNATION} GZ_DESIGNATION_LOWER)
  string(TOUPPER ${GZ_DESIGNATION} GZ_DESIGNATION_UPPER)

  string(SUBSTRING ${GZ_DESIGNATION} 0 1 GZ_DESIGNATION_FIRST_LETTER)
  string(TOUPPER ${GZ_DESIGNATION_FIRST_LETTER} GZ_DESIGNATION_FIRST_LETTER)
  string(REGEX REPLACE "^.(.*)" "${GZ_DESIGNATION_FIRST_LETTER}\\1"
         GZ_DESIGNATION_CAP "${GZ_DESIGNATION}")

  set(IGN_DESIGNATION ${GZ_DESIGNATION})  # TODO(CH3): Deprecated. Remove on tock.
  set(IGN_DESIGNATION_LOWER ${GZ_DESIGNATION_LOWER})  # TODO(CH3): Deprecated. Remove on tock.
  set(IGN_DESIGNATION_UPPER ${GZ_DESIGNATION_UPPER})  # TODO(CH3): Deprecated. Remove on tock.
  set(IGN_DESIGNATION_FIRST_LETTER ${GZ_DESIGNATION_FIRST_LETTER})  # TODO(CH3): Deprecated. Remove on tock.
  set(IGN_DESIGNATION_CAP ${GZ_DESIGNATION_CAP})  # TODO(CH3): Deprecated. Remove on tock.

  set(PROJECT_EXPORT_NAME ${PROJECT_NAME_LOWER})
  set(PROJECT_LIBRARY_TARGET_NAME ${PROJECT_NAME_LOWER})

  if(ign_configure_project_REPLACE_IGNITION_INCLUDE_PATH)
    set(PROJECT_INCLUDE_DIR ${ign_configure_project_REPLACE_IGNITION_INCLUDE_PATH})
  else()
    set(PROJECT_INCLUDE_DIR ignition/${GZ_DESIGNATION})
  endif()

  # version <major>.<minor>
  set(PROJECT_VERSION ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR})

  # version <major>.<minor>.<patch>
  set(PROJECT_VERSION_FULL
    ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH})

  # The full version of the project, but without any prerelease suffix
  set(PROJECT_VERSION_FULL_NO_SUFFIX ${PROJECT_VERSION_FULL})

  if(PROJECT_VERSION_SUFFIX)
    # Append the prerelease suffix to PROJECT_VERSION_FULL if this has a suffix
    # version <major>.<minor>.<patch>~<suffix>
    set(PROJECT_VERSION_FULL ${PROJECT_VERSION_FULL}~${PROJECT_VERSION_SUFFIX})
  endif()

  set(PKG_NAME ${PROJECT_NAME_LOWER})

  message(STATUS "${PROJECT_NAME} version ${PROJECT_VERSION_FULL}")

  #============================================================================
  # Identify the operating system
  ign_check_os()

  #============================================================================
  # Create package information
  ign_setup_packages()

  #============================================================================
  # Initialize build errors/warnings
  # NOTE: We no longer use CACHE for these variables because it was set to
  # "INTERNAL", making it unnecessary to cache them. As long as this macro is
  # called from the top-level scope, these variables will effectively be global,
  # even without putting them in the cache. If this macro is not being called
  # from the top-level scope, then it is being used incorrectly.
  set(build_errors "")
  set(build_warnings "")


  #============================================================================
  # Initialize the list of <PROJECT_NAME>-config.cmake dependencies
  set(PROJECT_CMAKE_DEPENDENCIES)

  # Initialize the list of <PROJECT_NAME>.pc Requires
  set(PROJECT_PKGCONFIG_REQUIRES)

  # Initialize the list of <PROJECT_NAME>.pc Requires.private
  set(PROJECT_PKGCONFIG_REQUIRES_PRIVATE)

  # Initialize the list of <PROJECT_NAME>.pc Libs
  set(PROJECT_PKGCONFIG_LIBS)

  # Initialize the list of <PROJECT_NAME>.pc Libs.private
  set(PROJECT_PKGCONFIG_LIBS_PRIVATE)


  #============================================================================
  # We turn off extensions because (1) we do not ever want to use non-standard
  # compiler extensions, and (2) this variable is on by default, causing cmake
  # to choose the flag -std=gnu++14 instead of -std=c++14 when the C++14
  # features are requested. Explicitly turning this flag off will force cmake to
  # choose -std=c++14.
  set(CMAKE_CXX_EXTENSIONS off)

  #============================================================================
  # Put all runtime objects (executables and DLLs) into a single directory.
  # This helps executables (e.g. tests) to run from the build directory on
  # Windows. The DLLs that we build for this library needs to be available to
  # the executables that depend on them.
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

  # Put all libraries (.so, static .lib) into a single directory. This is just
  # for convenience.
  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

  # Put all archive libraries (export .lib) into the lib directory. This is
  # just for convenience.
  set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

endmacro()

#################################################
# Check the OS type.
macro(ign_check_os)

  # CMake does not distinguish Linux from other Unices.
  string(REGEX MATCH "Linux" PLAYER_OS_LINUX ${CMAKE_SYSTEM_NAME})
  # Nor *BSD
  string(REGEX MATCH "BSD" PLAYER_OS_BSD ${CMAKE_SYSTEM_NAME})
  # Or Solaris. I'm seeing a trend, here
  string(REGEX MATCH "SunOS" PLAYER_OS_SOLARIS ${CMAKE_SYSTEM_NAME})

  # Windows is easy (for once)
  if(WIN32)
    set(PLAYER_OS_WIN TRUE BOOL INTERNAL)
  endif()

  # Check if it's an Apple OS
  if(APPLE)
    # Check if it's OS X or another MacOS (that's got to be pretty unlikely)
    string(REGEX MATCH "Darwin" PLAYER_OS_OSX ${CMAKE_SYSTEM_NAME})
    if(NOT PLAYER_OS_OSX)
      set(PLAYER_OS_MACOS TRUE BOOL INTERNAL)
    endif()
  endif()

  # QNX
  if(QNXNTO)
    set(PLAYER_OS_QNX TRUE BOOL INTERNAL)
  endif()

  if(PLAYER_OS_LINUX)
    message(STATUS "Operating system is Linux")
  elseif(PLAYER_OS_BSD)
    message(STATUS "Operating system is BSD")
  elseif(PLAYER_OS_WIN)
    message(STATUS "Operating system is Windows")
  elseif(PLAYER_OS_OSX)
    message(STATUS "Operating system is Apple MacOS X")
  elseif(PLAYER_OS_MACOS)
    message(STATUS "Operating system is Apple MacOS (not OS X)")
  elseif(PLAYER_OS_QNX)
    message(STATUS "Operating system is QNX")
  elseif(PLAYER_OS_SOLARIS)
    message(STATUS "Operating system is Solaris")
  else(PLAYER_OS_LINUX)
    message(STATUS "Operating system is generic Unix")
  endif()

  #################################################
  # Check for non-case-sensitive filesystems
  execute_process(COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/tools/case_sensitive_filesystem
                  RESULT_VARIABLE FILESYSTEM_CASE_SENSITIVE_RETURN)
  if (${FILESYSTEM_CASE_SENSITIVE_RETURN} EQUAL 0)
    set(FILESYSTEM_CASE_SENSITIVE TRUE)
  else()
    set(FILESYSTEM_CASE_SENSITIVE FALSE)
  endif()

endmacro()
