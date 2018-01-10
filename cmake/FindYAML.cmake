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

set(yaml_quiet_arg)
if(YAML_FIND_QUIETLY)
  set(yaml_quiet_arg QUIET)
endif()

find_package(yaml CONFIG ${yaml_quiet_arg})

include(IgnPkgConfig)
ign_pkg_config_entry(YAML "yaml >= ${YAML_FIND_VERSION}")
