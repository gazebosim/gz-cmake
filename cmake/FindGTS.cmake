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
#
########################################
# Find GNU Triangulation Surface Library

if (NOT WIN32)
  # Configuration using pkg-config modules
  include(IgnPkgConfig)
  ign_pkg_check_modules(GTS gts)
else()
  # true by default, change to false when a failure appears
  set(GTS_FOUND true)

  # 1. look for GTS headers
  find_path(GTS_INCLUDE_DIRS
    names 
      gts.h gtsconfig.h
    hints
      ${CMAKE_FIND_ROOT_PATH}
    paths
      ${CMAKE_FIND_ROOT_PATH}
    doc "GTS header include dir"
    path_suffixes
      include
  )

  if (GTS_INCLUDE_DIRS)
    if(NOT GTS_FIND_QUIETLY)
      message(STATUS "Looking for gts.h gtsconfig.h - found")
    endif()
  else()
    if(NOT GTS_FIND_QUIETLY)
      message(STATUS "Looking for gts.h gtsconfig.h - not found")
    endif()

    set(GTS_FOUND false)
  endif()
  mark_as_advanced(GTS_INCLUDE_DIRS)

  # 2. look for GTS libraries
  find_library(GTS_LIBRARY_RELEASE
    names
      gts
    hints
      ${CMAKE_FIND_ROOT_PATH}
    paths
      ${CMAKE_FIND_ROOT_PATH}
    path_suffixes
      "lib"
      "local/lib"
  ) 

  find_library(GTS_LIBRARY_DEBUG
    names
      gts
    hints
      ${CMAKE_FIND_ROOT_PATH}
    paths
      ${CMAKE_FIND_ROOT_PATH}
    path_suffixes
      "debug/lib"
      "lib"
      "local/lib"
  )

  #fix debug/release libraries mismatch for vcpkg
  if(DEFINED VCPKG_TARGET_TRIPLET)
    set(GTS_LIBRARY_RELEASE ${GTS_LIBRARY_DEBUG}/../../../lib/libgsl.lib)
    get_filename_component(GTS_LIBRARY_RELEASE ${GTS_LIBRARY_RELEASE} REALPATH)
  endif()

  include(SelectLibraryConfigurations)
  select_library_configurations(GTS)

  if (GTS_LIBRARIES)
    if(NOT GTS_FIND_QUIETLY)
      message(STATUS "Looking for gts library - found")
    endif()
  else()
    if(NOT GTS_FIND_QUIETLY)
      message(STATUS "Looking for gts library - not found")
    endif()

    set (GTS_FOUND false)
  endif()

  # 2.1 Need glib library
  find_library(GLIB_LIBRARY_RELEASE
    names
      glib-2.0
    hints
      ${CMAKE_FIND_ROOT_PATH}
    paths
      ${CMAKE_FIND_ROOT_PATH}
    path_suffixes
      "lib"
      "local/lib"
  ) 

  find_library(GLIB_LIBRARY_DEBUG
    names
      glib-2.0
    hints
      ${CMAKE_FIND_ROOT_PATH}
    paths
      ${CMAKE_FIND_ROOT_PATH}
    path_suffixes
      "debug/lib"
      "lib"
      "local/lib"
  )

  #fix debug/release libraries mismatch for vcpkg
  if(DEFINED VCPKG_TARGET_TRIPLET)
    set(GLIB_LIBRARY_RELEASE ${GLIB_LIBRARY_DEBUG}/../../../lib/glib-2.0.lib)
    get_filename_component(GLIB_LIBRARY_RELEASE ${GLIB_LIBRARY_RELEASE} REALPATH)
  endif()

  include(SelectLibraryConfigurations)
  select_library_configurations(GLIB)

  list(APPEND GTS_LIBRARIES "${GLIB_LIBRARIES}")
  mark_as_advanced(GTS_LIBRARIES)

  message(STATUS "GTS_LIBRARIES=${GTS_LIBRARIES}")
  message(STATUS "GTS_LIBRARY=${GTS_LIBRARY}")
  message(STATUS "GLIB_LIBRARIES=${GLIB_LIBRARY}")
  message(STATUS "CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}")
  message(STATUS "CMAKE_FIND_ROOT_PATH=${CMAKE_FIND_ROOT_PATH}")

  if (GTS_FOUND)
    include(IgnPkgConfig)
    ign_pkg_check_modules(GTS "gts")
    include(IgnImportTarget)
    ign_import_target(GTS)
  endif()
endif()
