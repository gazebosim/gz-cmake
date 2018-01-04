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
# Find ogre
# On Windows, we assume that all the OGRE* defines are passed in manually
# to CMake.

include(IgnPkgConfig)

# Grab the version numbers requested by the call to find_package(~)
set(major_version ${OGRE_FIND_VERSION_MAJOR})
set(minor_version ${OGRE_FIND_VERSION_MINOR})

# Set the full version number
set(full_version ${major_version}.${minor_version})

if (NOT WIN32)
  execute_process(COMMAND pkg-config --modversion OGRE
                  OUTPUT_VARIABLE OGRE_VERSION)
  string(REPLACE "\n" "" OGRE_VERSION ${OGRE_VERSION})

  string (REGEX REPLACE "^([0-9]+).*" "\\1"
    OGRE_MAJOR_VERSION "${OGRE_VERSION}")
  string (REGEX REPLACE "^[0-9]+\\.([0-9]+).*" "\\1"
    OGRE_MINOR_VERSION "${OGRE_VERSION}")
  string (REGEX REPLACE "^[0-9]+\\.[0-9]+\\.([0-9]+).*" "\\1"
    OGRE_PATCH_VERSION ${OGRE_VERSION})

  set(OGRE_VERSION
    ${OGRE_MAJOR_VERSION}.${OGRE_MINOR_VERSION}.${OGRE_PATCH_VERSION})
endif()

ign_pkg_check_modules_quiet(OGRE "OGRE >= ${full_version}")

if (OGRE_FOUND)

  ign_pkg_check_modules_quiet(OGRE-RTShaderSystem "OGRE-RTShaderSystem >= ${full_version}")
  if (OGRE-RTShaderSystem_FOUND)
    list(APPEND OGRE_LIBRARIES OGRE-RTShaderSystem::OGRE-RTShaderSystem)
  endif ()

  ign_pkg_check_modules_quiet(OGRE-Terrain OGRE-Terrain)
  if (OGRE-Terrain_FOUND)
    list(APPEND OGRE_LIBRARIES OGRE-Terrain::OGRE-Terrain)
  endif()

  ign_pkg_check_modules_quiet(OGRE-Overlay OGRE-Overlay)
  if (OGRE-Overlay_FOUND)
    list(APPEND OGRE_LIBRARIES OGRE-Overlay::OGRE-Overlay)
  endif()

  # Also find OGRE's plugin directory, which is provided in its .pc file as the
  # `plugindir` variable.  We have to call pkg-config manually to get it.
  # On Windows, we assume that all the OGRE* defines are passed in manually
  # to CMake.
  if (NOT WIN32)
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
