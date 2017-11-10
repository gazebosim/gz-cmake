#===============================================================================
# Base Io build system
# Written by there.exists.teslos<there.exists.teslos.gmail.com>
# Modified by Open Source Robotics Foundation
#
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
# Find ODE Open Dynamics Engine

find_path(ODE_INCLUDE_DIR ode/ode.h
  /usr/include
  /usr/local/include
)

set(ODE_NAMES ${ODE_NAMES} ode libode)
find_library(ODE_LIBRARIES NAMES ${ODE_NAMES} PATH)

if(ODE_INCLUDE_DIR)
  message(STATUS "Found ODE include dir: ${ODE_INCLUDE_DIR}")
else(ODE_INCLUDE_DIR)
  message(STATUS "Couldn't find ODE include dir: ${ODE_INCLUDE_DIR}")
endif(ODE_INCLUDE_DIR)

if(ODE_LIBRARIES)
  message(STATUS "Found ODE library: ${ODE_LIBRARIES}")
else(ODE_LIBRARIES)
  message(STATUS "Couldn't find ODE library: ${ODE_LIBRARIES}")
endif(ODE_LIBRARIES)

if(ODE_INCLUDE_DIR AND ODE_LIBRARIES)
  set(ODE_FOUND true)
endif(ODE_INCLUDE_DIR AND ODE_LIBRARIES)

if(ODE_FOUND)
  message(STATUS "Looking for Open Dynamics Engine - found")
  set(CMAKE_C_FLAGS "-DdSINGLE")
  set(HAVE_ODE true)
  include(IgnImportTarget)
  ign_import_target(ODE)
  if(NOT ODE_FIND_QUIETLY)
    message(STATUS "Found ODE: ${ODE_LIBRARIES}")
  endif(NOT ODE_FIND_QUIETLY)
else(ODE_FOUND)
  if(ODE_FIND_REQUIRED)
    message(FATAL_ERROR "Could not find ODE")
  endif(ODE_FIND_REQUIRED)
endif(ODE_FOUND)
