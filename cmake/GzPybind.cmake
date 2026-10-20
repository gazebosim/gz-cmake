# Copyright 2024 Open Source Robotics Foundation, Inc.
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

#################################################
# Insert options required to control the include of pybind11
#
# Usage:
#
#     gz_add_pybind_project_settings()
#
# Variables defined by this macro:
#
#  SKIP_PYBIND11                                Skip generating of Python bindings if OFF
#  USE_SYSTEM_PATHS_FOR_PYTHON_INSTALLATION     Install modules in default system path if ON
#  USE_DIST_PACKAGES_FOR_PYTHON                 Use dist-package over site-package for module installation if ON
#
macro(gz_add_pybind_project_settings)
  set(skip_pybind11_default_value OFF)
  if (MSVC)
    # We're disabling pybind11 by default on Windows because they
    # don't have active CI on them for now.
    set(skip_pybind11_default_value ON)
  endif()

  option(SKIP_PYBIND11
        "Skip generating Python bindings via pybind11"
        ${skip_pybind11_default_value})

  include(CMakeDependentOption)

  cmake_dependent_option(USE_SYSTEM_PATHS_FOR_PYTHON_INSTALLATION
        "Install Python modules in standard system paths in the system"
        OFF "NOT SKIP_PYBIND11" OFF)

  cmake_dependent_option(USE_DIST_PACKAGES_FOR_PYTHON
        "Use dist-packages instead of site-package to install Python modules"
        OFF "NOT SKIP_PYBIND11" OFF)
endmacro()


#################################################
# Search for pybind11 and its dependencies if SKIP_PYBIND11 is not set
#
# Usage:
#
#     gz_add_pybind_project_settings() <- required!
#     gz_search_for_pybind()
#
# Variables defined by this macro:
#
#  Python3_*            Python result variables from FindPython3 module
#  pybind11_*           pybind11 result variables from pybind11 module
#
macro(gz_search_for_pybind)
  if (SKIP_PYBIND11)
    message(STATUS "SKIP_PYBIND11 set - disabling python bindings")
  else()
    if (NOT Python3_Development_FOUND)
      # wasn't already called and found in outer CMakeList yet, so search for it
      find_package(Python3 QUIET COMPONENTS Interpreter OPTIONAL_COMPONENTS Development)
    endif()

    if (NOT Python3_FOUND)
      GZ_BUILD_WARNING ("Python is missing: Python interfaces are disabled.")
      message (STATUS "Searching for Python - not found.")
    elseif (NOT Python3_Development_FOUND)
      GZ_BUILD_WARNING ("Python Development component is missing: Python interfaces are disabled.")
      message (STATUS "Searching for Python Development component - not found.")
    else()
      message (STATUS "Searching for Python - found version ${Python3_VERSION}.")

      set(PYBIND11_PYTHON_VERSION 3)
      find_package(pybind11 CONFIG QUIET)

      if (${pybind11_FOUND})
        message (STATUS "Searching for pybind11 - found version ${pybind11_VERSION}.")
      else()
        GZ_BUILD_WARNING ("pybind11 is missing: Python interfaces are disabled.")
        message (STATUS "Searching for pybind11 - not found.")
      endif()
    endif()
  endif()
endmacro()


#################################################
# Add the given directory to the CMake project and thus process the inner CMakeLists.txt
# which should contain the pybind module (e.g. pybind11_add_module) instructions.
#
# Usage:
#
#     gz_add_pybind_project_settings() <- required!
#     gz_search_for_pybind() <- required!
#     gz_add_pybind_directory(my_bindings)
#
# Argument required by this macro:
#   DIRECTORY       Path to the folder with pybind module(s)
#
macro(gz_add_pybind_directory DIRECTORY)
  if (pybind11_FOUND AND NOT SKIP_PYBIND11)
    # Bindings subdirectory
    add_subdirectory(${DIRECTORY})
  endif()
endmacro()
