#===============================================================================
# Copyright (C) 2022 Open Source Robotics Foundation
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
# Find Assimp

include(GzPkgConfig)

message("Looking for assimp")

#if(GzAssimp_FIND_VERSION)
#  gz_pkg_check_modules_quiet(GzAssimp "assimp >= ${GzAssimp_FIND_VERSION}")
#else()
#  gz_pkg_check_modules_quiet(GzAssimp "assimp")
#endif()

#if(NOT GzAssimp_FOUND)
if(WIN32)
#  message("Doing manual search")
#  include(GzManualSearch)
#  gz_manual_search(GzAssimp
#                   HEADER_NAMES "assimp/scene.h"
#                   LIBRARY_NAMES "assimp"
#		   TARGET_NAME "GzAssimp::GzAssimp")
#  find_library(TMP_ASSIMP_LIB "assimp-vc-141-mt")
#  message("TMP ASSIMP LIB IS ${TMP_ASSIMP_LIB}")
#
#   gz_pkg_config_entry(GzAssimp "assimp")
endif()
find_package(assimp CONFIG QUIET)

message("GzAssimp found ${GzAssimp_FOUND}")
message("GzAssimp libs ${GzAssimp_LIBRARIES}")
message("GzAssimp include dirs ${GzAssimp_INCLUDE_DIRS}")
message("GzAssimp version ${GzAssimp_VERSION}")

message("Assimp found ${assimp_FOUND}")
message("Assimp libs ${ASSIMP_LIBRARIES}")
message("Assimp include dirs ${ASSIMP_INCLUDE_DIRS}")
message("Assimp version ${assimp_VERSION}")

set(GzAssimp_FOUND ${assimp_FOUND})
set(GzAssimp_LIBRARIES ${ASSIMP_LIBRARIES})
set(GzAssimp_INCLUDE_DIRS ${ASSIMP_INCLUDE_DIRS})
set(GzAssimp_INCLUDE_DIRS ${ASSIMP_INCLUDE_DIRS})
set(GzAssimp_VERSION ${assimp_VERSION})

gz_pkg_config_entry(GzAssimp "assimp")
#mark_as_advanced(GzAssimp_LIBRARY_assimp)
#set(GzAssimp_LIBRARY_assimp ${GzAssimp_LIBRARIES})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
  GzAssimp
  REQUIRED_VARS GzAssimp_FOUND)
