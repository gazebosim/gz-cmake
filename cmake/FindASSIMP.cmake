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

include(IgnPkgConfig)

if(ASSIMP_FIND_VERSION)
  gz_pkg_check_modules_quiet(ASSIMP "assimp >= ${ASSIMP_FIND_VERSION}")
else()
  gz_pkg_check_modules_quiet(ASSIMP "assimp")
endif()

if(NOT ASSIMP_FOUND)
  include(IgnManualSearch)
  gz_manual_search(ASSIMP
                   HEADER_NAMES "assimp/scene.h"
                   LIBRARY_NAMES "assimp")
endif()


include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
  ASSIMP
  REQUIRED_VARS ASSIMP_FOUND)
