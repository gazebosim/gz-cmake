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
# Find OGRE2 headers and libraries
#
# Usage of this module as follows:
#
#     ign_find_package(OGRE2)
#
# Variables defined by this module:
#
#  OGRE2_FOUND              System has OGRE libs/headers
#  OGRE2_LIBRARIES          The OGRE libraries
#  OGRE2_INCLUDE_DIRS       The location of OGRE headers
#  OGRE2_VERSION            Full OGRE version in the form of MAJOR.MINOR.PATCH
#  OGRE2_VERSION_MAJOR      OGRE major version
#  OGRE2_VERSION_MINOR      OGRE minor version
#  OGRE2_VERSION_PATCH      OGRE patch version
#  OGRE2_RESOURCE_PATH      Path to ogre plugins directory
#
# On Windows, we assume that all the OGRE* defines are passed in manually
# to CMake.
#
# Supports finding the following OGRE2 components: HlmsPbs, HlmsUnlit, Overlay
#
# Example usage:
#
#     ign_find_package(OGRE2
#                      VERSION 2.1.0
#                      COMPONENTS HlmsPbs HlmsUnlit Overlay)

# sanity check
if (${OGRE2_FIND_VERSION_MAJOR})
  if (${OGRE2_FIND_VERSION_MAJOR} VERSION_LESS "2")
    set (OGRE2_FOUND false)
    return()
  endif()
endif()

set(PKG_CONFIG_PATH_ORIGINAL $ENV{PKG_CONFIG_PATH})
set(PKG_CONFIG_PATH_TMP ${PKG_CONFIG_PATH_ORIGINAL})

if (NOT WIN32)
  execute_process(COMMAND pkg-config --variable pc_path pkg-config
                  OUTPUT_VARIABLE _pkgconfig_invoke_result
                  RESULT_VARIABLE _pkgconfig_failed)
  if(_pkgconfig_failed)
    BUILD_WARNING ("Failed to get pkg-config search paths")
  elseif (NOT "_pkgconfig_invoke_result" STREQUAL "")
    set (PKG_CONFIG_PATH_TMP "${PKG_CONFIG_PATH_TMP}:${_pkgconfig_invoke_result}")
  endif()
endif()

# check and see if there are any paths at all
if ("${PKG_CONFIG_PATH_TMP}" STREQUAL "")
  message("No valid pkg-config search paths found")
  return()
endif()

string(REPLACE ":" ";" PKG_CONFIG_PATH_TMP ${PKG_CONFIG_PATH_TMP})

# loop through pkg config paths and find an ogre version that is >= 2.0.0
foreach(pkg_path ${PKG_CONFIG_PATH_TMP})
  set(ENV{PKG_CONFIG_PATH} ${pkg_path})
  ign_pkg_check_modules_quiet(OGRE2 "OGRE")
  if (OGRE2_FOUND)
    if (${OGRE2_VERSION} VERSION_LESS 2.0.0)
      set (OGRE2_FOUND false)
    else ()
      break()
    endif()
  endif()
endforeach()

# reset pkg config path
set(ENV{PKG_CONFIG_PATH} ${PKG_CONFIG_PATH_ORIGINAL})

if (NOT OGRE2_FOUND)
  return()
endif()

# verify ogre header can be found in the include path
find_path(OGRE2_INCLUDE
  NAMES Ogre.h
  PATHS ${OGRE2_INCLUDE_DIRS}
  NO_DEFAULT_PATH
)

if(NOT OGRE2_INCLUDE)
  set(OGRE2_FOUND false)
  return()
endif()

# this macro and the version parsing logic below is taken from the
# FindOGRE.cmake file distributed by ogre
macro(get_preprocessor_entry CONTENTS KEYWORD VARIABLE)
  string(REGEX MATCH
    "# *define +${KEYWORD} +((\"([^\n]*)\")|([^ \n]*))"
    PREPROC_TEMP_VAR
    ${${CONTENTS}}
  )
  if (CMAKE_MATCH_3)
    set(${VARIABLE} ${CMAKE_MATCH_3})
  else ()
    set(${VARIABLE} ${CMAKE_MATCH_4})
  endif ()
endmacro()

file(READ ${OGRE2_INCLUDE}/OgrePrerequisites.h OGRE_TEMP_VERSION_CONTENT)
get_preprocessor_entry(OGRE_TEMP_VERSION_CONTENT OGRE_VERSION_MAJOR OGRE2_VERSION_MAJOR)
get_preprocessor_entry(OGRE_TEMP_VERSION_CONTENT OGRE_VERSION_MINOR OGRE2_VERSION_MINOR)
get_preprocessor_entry(OGRE_TEMP_VERSION_CONTENT OGRE_VERSION_PATCH OGRE2_VERSION_PATCH)
get_preprocessor_entry(OGRE_TEMP_VERSION_CONTENT OGRE_VERSION_NAME OGRE2_VERSION_NAME)
set(OGRE2_VERSION "${OGRE2_VERSION_MAJOR}.${OGRE2_VERSION_MINOR}.${OGRE2_VERSION_PATCH}")

# get ogre library paths
if ("${OGRE2_LIBRARY_DIRS}" STREQUAL "")
  foreach (lib ${OGRE2_LIBRARIES})
    get_filename_component(OGRE2_LIBRARY_DIR "${lib}" PATH)
    list(APPEND OGRE2_LIBRARY_DIRS ${OGRE2_LIBRARY_DIR})
  endforeach()
endif()

# find the main ogre library
set(OGRE2_LIBRARY_NAME OgreMain)
find_library(OGRE2_LIBRARY NAMES ${OGRE2_LIBRARY_NAME} HINTS ${OGRE2_LIBRARY_DIRS} NO_DEFAULT_PATH)

if ("${OGRE2_LIBRARY}" STREQUAL "OGRE2_LIBRARY-NOTFOUND")
  set(OGRE2_FOUND false)
  return()
endif()

# find ogre components
include(IgnImportTarget)
foreach(component ${OGRE2_FIND_COMPONENTS})
  find_library(OGRE2-${component} NAMES "Ogre${component}" HINTS ${OGRE2_LIBRARY_DIRS})
  if (NOT "OGRE2-${component}" STREQUAL "OGRE2-${component}-NOTFOUND")
    # create a new target for each component
    set(component_TARGET_NAME "OGRE2-${component}::OGRE2-${component}")
    set(component_INCLUDE_DIRS ${OGRE2_INCLUDE_DIRS})
    set(component_LIBRARY_DIRS ${OGRE2_LIBRARY_DIRS})
    set(component_LIBRARIES ${OGRE2-${component}})
    ign_import_target(${component} TARGET_NAME ${component_TARGET_NAME}
        LIB_VAR component_LIBRARIES
        INCLUDE_VAR component_INCLUDE_DIRS)

    # add it to the list of ogre libraries
    list(APPEND OGRE2_LIBRARIES ${component_TARGET_NAME})

  elseif(OGRE2_FIND_REQUIRED_${component})
    set(OGRE2_FOUND false)
  endif()
endforeach()

# set path to find ogre plugins
# keep variable naming consistent with ogre 1
# TODO currently using harded paths based on dir structure in ubuntu
foreach(resource_path ${OGRE2_LIBRARY_DIRS})
  list(APPEND OGRE2_RESOURCE_PATH "${resource_path}/OGRE")
endforeach()

# create OGRE2 target
if (OGRE2_FOUND)
  ign_import_target(OGRE2)
endif()

# We need to manually specify the pkgconfig entry (and type of entry),
# because ign_pkg_check_modules does not work for it.
include(IgnPkgConfig)
ign_pkg_config_library_entry(OGRE2 OgreMain)
