#===============================================================================
# Copyright (C) 2018 Open Source Robotics Foundation
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
# Find yaml.

include(IgnPkgConfig)
ign_pkg_check_modules(YAML yaml-0.1)

# If that failed, then fall back to manual detection.
if(NOT YAML_FOUND)

  if(NOT YAML_FIND_QUIETLY)
    message(STATUS "Attempting manual search for yaml")
  endif()

  find_path(YAML_INCLUDE_DIRS yaml.h ${YAML_INCLUDE_DIRS} ENV CPATH)
  find_library(YAML_LIBRARIES NAMES yaml)
  set(YAML_FOUND true)

  if(NOT YAML_INCLUDE_DIRS)
    if(NOT YAML_FIND_QUIETLY)
      message(STATUS "Looking for yaml headers - not found")
    endif()
    set(YAML_FOUND false)
  endif()

  if(NOT YAML_LIBRARIES)
    if(NOT YAML_FIND_QUIETLY)
      message (STATUS "Looking for yaml library - not found")
    endif()
    set(YAML_FOUND false)
  endif()

  if(YAML_FOUND)
    include(IgnImportTarget)
    ign_import_target(YAML)
  endif()

  include(FindPackageHandleStandardArgs)
  find_package_handle_standard_args(
    YAML
    REQUIRED_VARS YAML_FOUND)

endif()