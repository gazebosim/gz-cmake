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
# Find jsoncpp.
#
# Usage of this module as follows:
#
#     find_package(JSONCPP)
#
# Variables defined by this module:
#
#  JSONCPP_FOUND              System has JSONCPP libs/headers
#  JSONCPP_INCLUDE_DIRS       The location of JSONCPP headers
#  JSONCPP_LIBRARIES          The JSONCPP libraries
#  JSONCPP_VERSION            The library version

set(jsoncpp_quiet_arg)
if(JSONCPP_FIND_QUIETLY)
  set(jsoncpp_quiet_arg QUIET)
endif()

find_package(jsoncpp ${JSONCPP_VERSION} CONFIG ${jsoncpp_quiet_arg})

include(IgnPkgConfig)
ign_pkg_config_entry(JSONCPP "jsoncpp = ${JSONCPP_VERSION}")
