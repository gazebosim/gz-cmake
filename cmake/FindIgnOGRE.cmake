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
#     ign_find_package(IgnOGRE)
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
#     ign_find_package(IgnOGRE
#                      VERSION 1.8.0
#                      COMPONENTS RTShaderSystem Terrain Overlay)

# Grab the version numbers requested by the call to find_package(~)
set(major_version ${IgnOGRE_FIND_VERSION_MAJOR})
set(minor_version ${IgnOGRE_FIND_VERSION_MINOR})

# Set the full version number
set(full_version ${major_version}.${minor_version})

if (WIN32)
  find_package(OGRE ${full_version}
               COMPONENTS ${IgnOGRE_FIND_COMPONENTS})

  # The last subdirecty of OGRE_INCLUDE_DIRS from vcpkg FindOgre includes the
  # OGRE/ subdirectory while the code uses headers the form OGRE/header.h
  set(p_last_subdir)
  foreach (dir ${OGRE_INCLUDE_DIRS})
    get_filename_component(last_subdir ${dir} NAME)
    if (last_subdir STREQUAL "OGRE")
      get_filename_component(p_last_subdir "${dir}/.." ABSOLUTE)
      list(APPEND OGRE_INCLUDE_DIRS ${p_last_subdir})
    endif()
  endforeach()

  # Transform the libraries to absolute path form
  foreach (lib ${OGRE_LIBRARIES})
      list(APPEND OGRE_LIBRARIES_full_path "${OGRE_LIBRARY_DIRS}/${lib}")
  endforeach()
  set (OGRE_LIBRARIES ${OGRE_LIBRARIES_full_path})
  
  message(STATUS "OGRE_LIBRARIES ${OGRE_LIBRARIES}")
  message(STATUS "COMPONENTS: ${IgnOGRE_FIND_COMPONENTS}")

else()
  include(IgnPkgConfig)
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
    foreach(component ${IgnOGRE_FIND_COMPONENTS})
      ign_pkg_check_modules_quiet(OGRE-${component} "OGRE-${component} >= ${full_version}")
      if(OGRE-${component}_FOUND)
        list(APPEND OGRE_LIBRARIES OGRE-${component}::OGRE-${component})
      elseif(IgnOGRE_FIND_REQUIRED_${component})
         set(OGRE_FOUND false)
      endif()
    endforeach()

    # Also find OGRE's plugin directory, which is provided in its .pc file as the
    # `plugindir` variable.  We have to call pkg-config manually to get it.
    # On Windows, we assume that all the OGRE* defines are passed in manually
    # to CMake.
    execute_process(COMMAND pkg-config --variable=plugindir OGRE
 			    OUTPUT_VARIABLE _pkgconfig_invoke_result
			    RESULT_VARIABLE _pkgconfig_failed)
    if(_pkgconfig_failed)
      BUILD_WARNING ("Failed to find OGRE's plugin directory.  The build will succeed, but there will likely be run-time errors.")
    else()
      # This variable will be substituted into cmake/setup.sh.in
      set (OGRE_PLUGINDIR ${_pkgconfig_invoke_result})
    endif()

    set(OGRE_RESOURCE_PATH ${OGRE_PLUGINDIR})
    # Seems that OGRE_PLUGINDIR can end in a newline, which will cause problems when
    # we pass it to the compiler later.
    string(REPLACE "\n" "" OGRE_RESOURCE_PATH ${OGRE_RESOURCE_PATH})
  endif()
endif ()

set(IgnOGRE_FOUND false)
if(OGRE_FOUND)
  set(IgnOGRE_FOUND true)
endif()
