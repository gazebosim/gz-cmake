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

if (WIN32)
  set(GTS_POSSIBLE_ROOT_DIRS
    ${_VCPKG_INSTALLED_DIR} # vcpkg support
    ${GTS_ROOT_DIR}
    $ENV{GTS_ROOT_DIR}
    ${GTS_DIR}
    ${GTS_HOME}
    $ENV{GTS_DIR}
    $ENV{GTS_HOME}
    $ENV{EXTERN_LIBS_DIR}/gts
    $ENV{EXTRA}
    )

  # true by default, change to false when a failure appears
  set(GTS_FOUND true)

  # 1. look for GTS headers
  find_path(GTS_INCLUDE_DIR
    names gts.h gtsconfig.h
    paths ${GTS_POSSIBLE_ROOT_DIRS}
    PATH_SUFFIXES include
    doc "GTS header include dir")

  if (GTS_INCLUDE_DIR)
    if(NOT GTS_FIND_QUIETLY)
      message(STATUS "Looking for gts.h gtsconfig.h - found")
    endif()
  else()
    if(NOT GTS_FIND_QUIETLY)
      message(STATUS "Looking for gts.h gtsconfig.h - not found")
    endif()

    set(GTS_FOUND false)
  endif()
  mark_as_advanced(GTS_INCLUDE_DIR)

  # 2. look for GTS library
  find_library(GTS_GTS_LIBRARY
    names gts libgts
    paths ${GTS_POSSIBLE_ROOT_DIRS}
    PATH_SUFFIXES lib
    DOC "GTS library dir" )

  if (GTS_GTS_LIBRARY)
    if(NOT GTS_FIND_QUIETLY)
      message(STATUS "Looking for gts and libgts libraries - found")
    endif()
  else()
    if(NOT GTS_FIND_QUIETLY)
      message(STATUS "Looking for gts and libgts libraries - not found")
    endif()

    set (GTS_FOUND false)
  endif()

  set(GTS_LIBRARIES ${GTS_GTS_LIBRARY})
  mark_as_advanced(GTS_LIBRARIES)

  MESSAGE("DBG\n"
      "GTS_INCLUDE_DIR=${GTS_INCLUDE_DIR}\n"
      "GTS_GTS_LIBRARY=${GTS_GTS_LIBRARY}\n"
      "GTS_LIBRARIES=${GTS_LIBRARIES}")
else()
  include(IgnPkgConfig)
  ign_pkg_check_modules(GTS gts)
endif()
