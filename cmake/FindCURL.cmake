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
# Find curl.
#
# Usage of this module as follows:
#
#     find_package(CURL)
#
# Variables defined by this module:
#
#  CURL_FOUND              System has CURL libs/headers
#  CURL_INCLUDE_DIRS       The location of CURL headers
#  CURL_LIBRARIES          The CURL libraries

find_package(curl ${CURL_VERSION} CONFIG QUIET)
include(IgnPkgConfig)

if(CURL_FOUND)
  ign_pkg_config_entry(CURL "curl = ${CURL_VERSION}")
else()
  ign_pkg_check_modules(CURL libcurl)

  # If that failed, then fall back to manual detection.
  if(NOT CURL_FOUND)

    if(NOT CURL_FIND_QUIETLY)
      message(STATUS "Attempting manual search for curl")
    endif()

    find_path(CURL_INCLUDE_DIRS curl.h ${CURL_INCLUDE_DIRS} ENV CPATH)
    find_library(CURL_LIBRARIES NAMES curl)
    set(CURL_FOUND true)

    if(NOT CURL_INCLUDE_DIRS)
      if(NOT CURL_FIND_QUIETLY)
        message(STATUS "Looking for curl headers - not found")
      endif()
      set(CURL_FOUND false)
    endif()

    if(NOT CURL_LIBRARIES)
      if(NOT CURL_FIND_QUIETLY)
        message (STATUS "Looking for curl library - not found")
      endif()
      set(CURL_FOUND false)
    endif()

    if(CURL_FOUND)
      include(IgnImportTarget)
      ign_import_target(CURL)
    endif()

    include(FindPackageHandleStandardArgs)
    find_package_handle_standard_args(
      CURL
      REQUIRED_VARS CURL_FOUND)
  endif()
endif()