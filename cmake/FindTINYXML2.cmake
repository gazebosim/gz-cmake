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
# Find tinyxml2. Only debian distributions package tinyxml with a pkg-config.

include(IgnPkgConfig)

# Use pkg_check_modules to start
ign_pkg_check_modules_quiet(TINYXML2 tinyxml2)

# If that failed, then fall back to manual detection (necessary for MacOS)
if(NOT TINYXML2_FOUND)

  message(STATUS "Attempting manual search for tinyxml2")

  find_path(TINYXML2_INCLUDE_DIRS tinyxml2.h ${TINYXML2_INCLUDE_DIRS} ENV CPATH)
  find_library(TINYXML2_LIBRARIES NAMES tinyxml2)
  set(TINYXML2_FOUND true)

  if(NOT TINYXML2_INCLUDE_DIRS)
    message(STATUS "Looking for tinyxml2 headers - not found")
    set(TINYXML2_FOUND false)
  endif()

  if(NOT TINYXML2_LIBRARIES)
    message (STATUS "Looking for tinyxml2 library - not found")
    set(TINYXML2_FOUND false)
  endif()

  if(TINYXML2_FOUND)
    ign_create_imported_target(TINYXML2)
  endif()

  include(FindPackageHandleStandardArgs)
  find_package_handle_standard_args(
    TINYXML2
    REQUIRED_VARS TINYXML2_FOUND)

endif()
