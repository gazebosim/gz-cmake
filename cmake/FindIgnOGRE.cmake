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

if (NOT WIN32)
  # pkg-config platforms
  set(PKG_CONFIG_PATH_ORIGINAL $ENV{PKG_CONFIG_PATH})
  set(PKG_CONFIG_PATH_TMP ${PKG_CONFIG_PATH_ORIGINAL})

  execute_process(COMMAND pkg-config --variable pc_path pkg-config
                  OUTPUT_VARIABLE _pkgconfig_invoke_result
                  RESULT_VARIABLE _pkgconfig_failed)
  if(_pkgconfig_failed)
    IGN_BUILD_WARNING ("Failed to get pkg-config search paths")
  elseif (NOT "_pkgconfig_invoke_result" STREQUAL "")
    set (PKG_CONFIG_PATH_TMP "${PKG_CONFIG_PATH_TMP}:${_pkgconfig_invoke_result}")
  endif()

  # check and see if there are any paths at all
  if ("${PKG_CONFIG_PATH_TMP}" STREQUAL "")
    message("No valid pkg-config search paths found")
    return()
  endif()

  string(REPLACE ":" ";" PKG_CONFIG_PATH_TMP_LIST ${PKG_CONFIG_PATH_TMP})

  # loop through pkg config paths and find an ogre version that is < 2.0.0
  foreach(pkg_path ${PKG_CONFIG_PATH_TMP_LIST})
    set(ENV{PKG_CONFIG_PATH} ${pkg_path})
    ign_pkg_check_modules_quiet(OGRE "OGRE >= ${full_version}")
    if (OGRE_FOUND)
      if (NOT ${OGRE_VERSION} VERSION_LESS 2.0.0)
        set (OGRE_FOUND false)
      else ()
        break()
      endif()
    endif()
  endforeach()

  if (OGRE_FOUND)
    # set OGRE major, minor, and patch version number
    string (REGEX REPLACE "^([0-9]+).*" "\\1"
      OGRE_VERSION_MAJOR "${OGRE_VERSION}")
    string (REGEX REPLACE "^[0-9]+\\.([0-9]+).*" "\\1"
      OGRE_VERSION_MINOR "${OGRE_VERSION}")
    string (REGEX REPLACE "^[0-9]+\\.[0-9]+\\.([0-9]+).*" "\\1"
      OGRE_VERSION_PATCH ${OGRE_VERSION})

    # find ogre components
    set(ENV{PKG_CONFIG_PATH} ${PKG_CONFIG_PATH_TMP})
    foreach(component ${IgnOGRE_FIND_COMPONENTS})
      ign_pkg_check_modules_quiet(IgnOGRE-${component} "OGRE-${component} >= ${full_version}")
      if(IgnOGRE-${component}_FOUND)
        list(APPEND OGRE_LIBRARIES IgnOGRE-${component}::IgnOGRE-${component})
      elseif(IgnOGRE_FIND_REQUIRED_${component})
        set(OGRE_FOUND false)
      endif()
    endforeach()

    execute_process(COMMAND pkg-config --variable=plugindir OGRE
                    OUTPUT_VARIABLE _pkgconfig_invoke_result
                    RESULT_VARIABLE _pkgconfig_failed)
    if(_pkgconfig_failed)
      IGN_BUILD_WARNING ("Failed to find OGRE's plugin directory.  The build will succeed, but there will likely be run-time errors.")
    else()
      # This variable will be substituted into cmake/setup.sh.in
      set(OGRE_PLUGINDIR ${_pkgconfig_invoke_result})
    endif()

    ign_pkg_config_library_entry(IgnOGRE OgreMain)

    set(OGRE_RESOURCE_PATH ${OGRE_PLUGINDIR})
    # Seems that OGRE_PLUGINDIR can end in a newline, which will cause problems
    # when we pass it to the compiler later.
    string(REPLACE "\n" "" OGRE_RESOURCE_PATH ${OGRE_RESOURCE_PATH})

  endif()

  #reset pkg config path
  set(ENV{PKG_CONFIG_PATH} ${PKG_CONFIG_PATH_ORIGINAL})

else()
  find_package(OGRE ${full_version}
               COMPONENTS ${IgnOGRE_FIND_COMPONENTS})

  if(OGRE_FOUND)
    # need to return only libraries defined by components and give them the
    # full path using OGRE_LIBRARY_DIRS
    set(ogre_all_libs)
    foreach(ogre_lib ${OGRE_LIBRARIES})
      # Be sure that all Ogre* libraries are using absolute paths
      set(prefix "")
      if(ogre_lib MATCHES "Ogre" AND NOT IS_ABSOLUTE "${ogre_lib}")
        set(prefix "${OGRE_LIBRARY_DIRS}/")
      endif()
      # Some Ogre libraries are not using the .lib extension
      set(postfix "")
      if(NOT ogre_lib MATCHES ".lib$")
        set(postfix ".lib")
      endif()
      set(lib_fullpath "${prefix}${ogre_lib}${postfix}")
      list(APPEND ogre_all_libs ${lib_fullpath})
    endforeach()
    set(OGRE_LIBRARIES ${ogre_all_libs})

    set(OGRE_RESOURCE_PATH ${OGRE_CONFIG_DIR})
  endif()
endif()

set(IgnOGRE_FOUND false)
if(OGRE_FOUND)
  set(IgnOGRE_FOUND true)
endif()
