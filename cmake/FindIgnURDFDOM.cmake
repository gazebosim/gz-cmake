#
# Copyright (C) 2021 Open Source Robotics Foundation
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

if (IgnURDFDOM_FIND_VERSION)
  set(find_version VERSION ${IgnURDFDOM_FIND_VERSION})
else()
  set(find_version "")
endif()
# NOTE: urdfdom cmake does not support version checking
ign_find_package(urdfdom ${find_version} QUIET)

if (urdfdom_FOUND)
  add_library(IgnURDFDOM::IgnURDFDOM INTERFACE IMPORTED)
  target_include_directories(IgnURDFDOM::IgnURDFDOM INTERFACE ${urdfdom_INCLUDE_DIRS})
  target_link_libraries(IgnURDFDOM::IgnURDFDOM INTERFACE ${urdfdom_LIBRARIES})
  include(FindPackageHandleStandardArgs)
  find_package_handle_standard_args(IgnURDFDOM DEFAULT_MSG)
else()
  message(VERBOSE "unable to find urdf cmake package, trying pkgconfig...")
  include(IgnPkgConfig)
  if (IgnURDFDOM_FIND_VERSION)
    set(signature "urdfdom >= ${IgnURDFDOM_FIND_VERSION}")
  else()
    set(signature "urdfdom")
  endif()
  ign_pkg_check_modules(IgnURDFDOM "${signature}")
endif()
