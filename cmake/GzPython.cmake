# Copyright 2020 Open Source Robotics Foundation, Inc.
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

if(${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.19")
  set(GZ_PYTHON_VERSION "" CACHE STRING
    "Specify specific Python3 version to use ('major.minor' or 'versionMin...[<]versionMax')")
  set(IGN_PYTHON_VERSION ${GZ_PYTHON_VERSION} CACHE STRING  # TODO(CH3): Deprecated. Remove on tock.
    "Deprecated. Use [GZ_PYTHON_VERSION] instead! Specify specific Python version to use ('major.minor' or 'major')")

  find_package(Python3 ${GZ_PYTHON_VERSION} QUIET)
elseif(${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.12")
  # no support for finding specific versions
  find_package(Python3 QUIET)
else()
  # TODO: remove this block as soon as the CMake version can safely be bumped to => 3.12
  set(GZ_PYTHON_VERSION "" CACHE STRING
    "Specify specific Python version to use ('major.minor' or 'major')")

  # if not specified otherwise use Python 3
  if(NOT GZ_PYTHON_VERSION)
    set(GZ_PYTHON_VERSION "3")
  endif()

  find_package(PythonInterp ${GZ_PYTHON_VERSION} QUIET)

  if(PYTHONINTERP_FOUND)
    set(Python3_Interpreter_FOUND ${PYTHONINTERP_FOUND})
    set(Python3_EXECUTABLE ${PYTHON_EXECUTABLE})
  endif()
endif()

# Tick-tock PYTHON_EXECUTABLE until Python3_EXECUTABLE is released
# TODO(jrivero) gz-cmake3: start the deprecation cycle of PYTHON_EXECUTABLE
if(Python3_EXECUTABLE AND NOT PYTHON_EXECUTABLE)
  set(PYTHON_EXECUTABLE ${Python3_EXECUTABLE})
endif()
