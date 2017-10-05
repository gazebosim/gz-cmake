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
# Find cppzmq

# If we cannot find the header or the library, we will switch this to false
set(CPPZMQ_FOUND true)

# Search for the header
find_path(CPPZMQ_INCLUDE_DIRS zmq.hpp
          PATHS
            ${zmq_INCLUDE_DIRS}
            ${CPPZMQ_HEADER_PATH})
if(CPPZMQ_INCLUDE_DIRS)
  message(STATUS "Looking for zmq.hpp - found")
else(CPPZMQ_INCLUDE_DIRS)
  message(STATUS "Looking for zmq.hpp - not found")
  set(CPPZMQ_FOUND false)
endif()

if(CPPZMQ_FOUND)
  include(IgnImportTarget)
  ign_import_target(ZPPZMQ)
endif()
