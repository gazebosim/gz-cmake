#===============================================================================
# Copyright (C) 2020 Open Source Robotics Foundation
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
#
########################################
# ign_manual_search(<package> [INTERFACE]
#     [HEADER_NAMES <header_names>]
#     [LIBRARY_NAMES <library_names>]
#     [TARGET_NAME <target_name>]
#     [PATH_SUFFIXES <path_suffixes>]])
#
# This macro will find a library based on the name of one of its headers,
# and the library name.
# It is used inside Find***.cmake scripts, typicall as fallback for a
# ign_pkg_check_modules_quiet call.
# It will create an imported target for the  library
#
# INTERFACE: Optional. Use INTERFACE when the target does not actually provide
#            a library that needs to be linked against (e.g. it is a header-only
#            library, or the target is just used to specify compiler flags).
#
# HEADER_NAMES: Optional. Explicitly specify the header names to search with find_path.
#              Default is <package>.h.
#
# LIBRARY_NAMES: Optional. Explicitly specify the names of the library to search with find_library.
#              Default is <package>.
#
# TARGET_NAME: Optional. Explicitly specify the desired imported target name.
#              Default is <package>::<package>.
#
# PATH_SUFFIXES: Optional. Parameter forwarded to the find_path and find_library calls.
#
macro(ign_manual_search package)

  #------------------------------------
  # Define the expected arguments
  set(options INTERFACE)
  set(oneValueArgs "TARGET_NAME")
  set(multiValueArgs "HEADER_NAMES" "LIBRARY_NAMES" "PATH_SUFFIXES")

  #------------------------------------
  # Parse the arguments
  _ign_cmake_parse_arguments(ign_manual_search "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if(ign_manual_search_INTERFACE)
    set(_ign_manual_search_interface_option INTERFACE)
  else()
    set(_ign_manual_search_interface_option) # Intentionally blank
  endif()

  if(NOT ign_manual_search_HEADER_NAMES)
    set(ign_manual_search_HEADER_NAMES "${package}.h")
  endif()

  if(NOT ign_manual_search_LIBRARY_NAMES)
    set(ign_manual_search_LIBRARY_NAMES "${package}")
  endif()

  if(NOT ign_manual_search_TARGET_NAME)
    set(ign_manual_search_TARGET_NAME "${package}::${package}")
  endif()

  find_path(${package}_INCLUDE_DIRS
            NAMES ${ign_manual_search_HEADER_NAMES}
            PATH_SUFFIXES ${ign_manual_search_PATH_SUFFIXES})
  find_library(${package}_LIBRARIES
               NAMES ${ign_manual_search_LIBRARY_NAMES}
               PATH_SUFFIXES ${ign_manual_search_PATH_SUFFIXES})

  mark_as_advanced(${package}_INCLUDE_DIRS)
  mark_as_advanced(${package}_LIBRARIES)

  set(${package}_FOUND true)

  if(NOT ${package}_INCLUDE_DIRS)
    set(${package}_FOUND false)
  endif()

  if(NOT ${package}_LIBRARIES)
    set(${package}_FOUND false)
  endif()

  if(${package}_FOUND)
    include(IgnImportTarget)
    ign_import_target(${package} ${_ign_pkg_check_modules_interface_option}
      TARGET_NAME ${ign_pkg_check_modules_TARGET_NAME})
  endif()

endmacro()
