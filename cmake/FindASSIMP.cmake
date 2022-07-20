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

find_package(ASSIMP ${ASSIMP_FIND_VERSION} CONFIG)

if(ASSIMP_FOUND)
  gz_import_target(Assimp
    TARGET_NAME Assimp::Assimp
    LIB_VAR ASSIMP_LIBRARIES
    INCLUDE_VAR ASSIMP_INCLUDE_DIRS
  )
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
  ASSIMP
  REQUIRED_VARS ASSIMP_FOUND)
