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

#--------------------------------------
# Find OGRE headers and libraries
#
# Usage of this module as follows:
#
#     ign_find_package(OGRE)
#
# Variables defined by this module:
#
#  OGRE_FOUND              System has OGRE libs/headers
#  OGRE_LIBRARIES          The OGRE libraries
#  OGRE_INCLUDE_DIRS       The location of OGRE headers
#  OGRE_VERSION            Full OGRE version in the form of MAJOR.MINOR.PATCH
#  OGRE_VERSION_MAJOR      OGRE major version
#  OGRE_VERSION_MINOR      OGRE minor version
#  OGRE_VERSION_PATCH      OGRE patch version
#  OGRE_RESOURCE_PATH      Path to ogre plugins directory
#
# On Windows, we assume that all the OGRE* defines are passed in manually
# to CMake.
#
# Supports finding the following OGRE components: RTShaderSystem, Terrain, Overlay
#
# Example usage:
#
#     ign_find_package(OGRE
#                      VERSION 1.8.0
#                      COMPONENTS RTShaderSystem Terrain Overlay)

include(IgnPkgConfig)

# Grab the version numbers requested by the call to find_package(~)
set(major_version ${OGRE_FIND_VERSION_MAJOR})
set(minor_version ${OGRE_FIND_VERSION_MINOR})

# Set the full version number
set(full_version ${major_version}.${minor_version})

ign_pkg_check_modules_quiet(OGRE "OGRE >= ${full_version}")

if (OGRE_FOUND)

  # set OGRE major, minor, and patch version number
  string (REGEX REPLACE "^([0-9]+).*" "\\1"
    OGRE_VERSION_MAJOR "${OGRE_VERSION}")
  string (REGEX REPLACE "^[0-9]+\\.([0-9]+).*" "\\1"
    OGRE_VERSION_MINOR "${OGRE_VERSION}")
  string (REGEX REPLACE "^[0-9]+\\.[0-9]+\\.([0-9]+).*" "\\1"
    OGRE_VERSION_PATCH ${OGRE_VERSION})

  # find ogre components
  foreach(component ${OGRE_FIND_COMPONENTS})
    ign_pkg_check_modules_quiet(OGRE-${component} "OGRE-${component} >= ${full_version}")
    if(OGRE-${component}_FOUND)
      list(APPEND OGRE_LIBRARIES OGRE-${component}::OGRE-${component})
    elseif(OGRE_FIND_REQUIRED_${component})
      set(OGRE_FOUND false)
    endif()
  endforeach()

  # Also find OGRE's plugin directory, which is provided in its .pc file as the
  # `plugindir` variable.  We have to call pkg-config manually to get it.
  # On Windows, we assume that all the OGRE* defines are passed in manually
  # to CMake.
  if (PKG_CONFIG_FOUND)
    execute_process(COMMAND pkg-config --variable=plugindir OGRE
                    OUTPUT_VARIABLE _pkgconfig_invoke_result
                    RESULT_VARIABLE _pkgconfig_failed)
    if(_pkgconfig_failed)
      BUILD_WARNING ("Failed to find OGRE's plugin directory.  The build will succeed, but there will likely be run-time errors.")
    else()
      # This variable will be substituted into cmake/setup.sh.in
      set (OGRE_PLUGINDIR ${_pkgconfig_invoke_result})
    endif()
  endif()

  set(OGRE_RESOURCE_PATH ${OGRE_PLUGINDIR})
  # Seems that OGRE_PLUGINDIR can end in a newline, which will cause problems when
  # we pass it to the compiler later.
  string(REPLACE "\n" "" OGRE_RESOURCE_PATH ${OGRE_RESOURCE_PATH})
endif ()
