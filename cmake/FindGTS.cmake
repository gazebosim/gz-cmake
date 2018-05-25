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
  SET(GTS_POSSIBLE_ROOT_DIRS
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

  FIND_PATH(GTS_INCLUDE_DIR
    NAMES gts.h gtsconfig.h
    PATHS ${GTS_POSSIBLE_ROOT_DIRS}
    PATH_SUFFIXES include
    DOC "GTS header include dir"
    )

  FIND_LIBRARY(GTS_GTS_LIBRARY
    NAMES gts libgts
    PATHS  ${GTS_POSSIBLE_ROOT_DIRS}
    PATH_SUFFIXES lib
    DOC "GTS library dir" )

  SET(GTS_LIBRARIES ${GTS_GTS_LIBRARY})

  MESSAGE("DBG\n"
      "GSL_GSL_LIBRARY=${GSL_GSL_LIBRARY}\n"
      "GSL_LIBRARIES=${GSL_LIBRARIES}")
else()
  include(IgnPkgConfig)
  ign_pkg_check_modules(GTS gts)
endif()
