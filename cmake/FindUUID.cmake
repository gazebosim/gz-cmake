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
# Find uuid
if (UNIX)
  include(IgnPkgConfig)
  ign_pkg_check_modules_quiet(UUID uuid)

  if(NOT UUID_FOUND)
    include(IgnManualSearch)
    ign_manual_search(UUID
                      HEADER_NAMES "uuid/uuid.h"
                      LIBRARY_NAMES "uuid libuuid")
  endif()

  include(FindPackageHandleStandardArgs)
  find_package_handle_standard_args(
    UUID
    REQUIRED_VARS UUID_FOUND)
endif()
