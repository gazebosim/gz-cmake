
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
#     gz_find_package(GzOGRE2)
#
# Variables used by this module, they can change the default behaviour and need
# to be set before calling find_package:
#
#  GZ_OGRE2_PROJECT_NAME    Possible values: OGRE2 (default) or OGRE-Next
#                            (Only on UNIX, not in use for Windows)
#                            Specify the project name used in the packaging.
#                            It will impact directly in the name of the
#                            CMake/pkg-config modules being used.
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
#  GzOGRE2::GzOGRE2       Imported target for OGRE2
#
# On Windows, we assume that all the OGRE* defines are passed in manually
# to CMake.
#
# Supports finding the following OGRE2 components: HlmsPbs, HlmsUnlit, Overlay,
#  PlanarReflections
#
# Example usage:
#
#     gz_find_package(GzOGRE2
#                     VERSION 2.2.0
#                     COMPONENTS HlmsPbs HlmsUnlit Overlay)


if(NOT (GzOGRE2_FIND_VERSION_MAJOR AND GzOGRE2_FIND_VERSION_MINOR))
  message(WARNING 
    "find_package(GzOGRE2) must be called with a VERSION argument with a minimum of major and minor version")
  set(OGRE2_FOUND false)
  return()
endif()

# Sanity check: exclude OGRE1 project releasing versions in two ways:
#  - Legacy in from using 1.x.y until 1.12.y series
#  - Modern versions using X.Y.Z starting with 13.y.z
# Reduce valid versions to 2.x series
if (${GzOGRE2_FIND_VERSION_MAJOR})
  if (${GzOGRE2_FIND_VERSION_MAJOR} VERSION_LESS "2" OR
      ${GzOGRE2_FIND_VERSION_MAJOR} VERSION_GREATER_EQUAL "3")
    set (OGRE2_FOUND false)
    return()
  endif()
endif()

function(colcon_do_nothing)
  # This is a function to "trick" colcon to doing correct dependency order resolution
  # without having to do a colcon.pkg file
  find_package(OGRE-Next QUIET)
endfunction()

macro(append_library VAR LIB)
  if(EXISTS "${LIB}")
    list(APPEND ${VAR} ${LIB})
  endif()
endmacro()

# filter all ocurrences of LIBRARY_STR with the form of: debug;<path>;optimized;<path>
# based on CMAKE_BUILD_TYPE
macro(select_lib_by_build_type LIBRARY_STR OUTPUT_VAR)
  foreach(library ${LIBRARY_STR})
    if(library STREQUAL optimized)
      set(conf optimized)
    elseif(library STREQUAL debug)
      set(conf debug)
    else()
      if(conf STREQUAL optimized)
        append_library(LIB_RELEASE ${library})
        set(conf)
      elseif(conf STREQUAL debug)
        append_library(LIB_DEBUG ${library})
        set(conf)
      else()
        # assume library without debug/optimized prefix
        append_library(LIB_RELEASE ${library})
        append_library(LIB_DEBUG ${library})
      endif()
    endif()
  endforeach()

  if(LIB_DEBUG AND CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(${OUTPUT_VAR} "${LIB_DEBUG}")
  elseif(LIB_RELEASE)
    set(${OUTPUT_VAR} "${LIB_RELEASE}")
  endif()
endmacro()

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

macro(find_package_ogre_next)
  set(options)
  set(oneValueArgs PROJECT_NAME INSTALL_PATH LIBRARY_NAME)
  set(multiValueArgs)

  _gz_cmake_parse_arguments(find_package_ogre_next "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  set(OGRE_NEXT_PROJECT_NAME ${find_package_ogre_next_PROJECT_NAME})
  set(OGRE_NEXT_INSTALL_PATH ${find_package_ogre_next_INSTALL_PATH})
  set(OGRE_NEXT_LIBRARY_NAME ${find_package_ogre_next_LIBRARY_NAME})
  set(OGRE_NEXT_FOUND FALSE)

  gz_pkg_check_modules_quiet(${OGRE_NEXT_PROJECT_NAME} ${OGRE_NEXT_INSTALL_PATH} NO_CMAKE_ENVIRONMENT_PATH QUIET)

  if (NOT ${OGRE_NEXT_PROJECT_NAME}_FOUND)
    message(STATUS "(GzOGRE2): Searching for ${OGRE_NEXT_PROJECT_NAME} (${GzOGRE2_FIND_VERSION_MAJOR}.${GzOGRE2_FIND_VERSION_MINOR}.${GzOGRE2_FIND_VERSION_PATCH}): NOT FOUND")
  else()
    message(STATUS "(GzOGRE2): Searching for ${OGRE_NEXT_PROJECT_NAME} (${GzOGRE2_FIND_VERSION_MAJOR}.${GzOGRE2_FIND_VERSION_MINOR}.${GzOGRE2_FIND_VERSION_PATCH}): Found Candidate")

    set(OGRE_NEXT_LIBRARIES ${${OGRE_NEXT_PROJECT_NAME}_LIBRARIES})
    set(OGRE_NEXT_LIBRARY_DIRS ${${OGRE_NEXT_PROJECT_NAME}_LIBRARY_DIRS})
    set(OGRE_NEXT_INCLUDE_DIRS ${${OGRE_NEXT_PROJECT_NAME}_INCLUDE_DIRS})
    set(GZ_PKG_NAME ${OGRE_NEXT_PROJECT_NAME})

    # Pull in the header to check the version 
    # Don't cache this variable because of mulitple macro invocations
    unset(OGRE_NEXT_INCLUDE)
    find_path(OGRE_NEXT_INCLUDE
      NAMES Ogre.h
      HINTS ${OGRE_NEXT_INCLUDE_DIRS} 
      NO_DEFAULT_PATH
      NO_CACHE
    )

    if (OGRE_NEXT_INCLUDE)
      file(READ ${OGRE_NEXT_INCLUDE}/OgrePrerequisites.h OGRE_NEXT_TEMP_VERSION_CONTENT)
      get_preprocessor_entry(OGRE_NEXT_TEMP_VERSION_CONTENT OGRE_VERSION_MAJOR OGRE_NEXT_VERSION_MAJOR)
      get_preprocessor_entry(OGRE_NEXT_TEMP_VERSION_CONTENT OGRE_VERSION_MINOR OGRE_NEXT_VERSION_MINOR)
      get_preprocessor_entry(OGRE_NEXT_TEMP_VERSION_CONTENT OGRE_VERSION_PATCH OGRE_NEXT_VERSION_PATCH)
      get_preprocessor_entry(OGRE_NEXT_TEMP_VERSION_CONTENT OGRE_VERSION_NAME  OGRE_NEXT_VERSION_NAME)
      set(OGRE_NEXT_VERSION "${OGRE_NEXT_VERSION_MAJOR}.${OGRE_NEXT_VERSION_MINOR}.${OGRE_NEXT_VERSION_PATCH}")
      message(STATUS "(GzOGRE2): Found version: (${OGRE_NEXT_VERSION})")
      set(OGRE_NEXT_FOUND TRUE)

      execute_process(COMMAND pkg-config --variable=plugindir ${OGRE_NEXT_INSTALL_PATH}
                      OUTPUT_VARIABLE _pkgconfig_invoke_result
                      RESULT_VARIABLE _pkgconfig_failed)

      if(NOT _pkgconfig_failed)
        set(OGRE_NEXT_VERSION_EXACT FALSE)
        set(OGRE_NEXT_VERSION_COMPATIBLE FALSE)

        if (NOT ("${OGRE_NEXT_VERSION_MAJOR}" EQUAL "${GzOGRE2_FIND_VERSION_MAJOR}"))
          set(OGRE_NEXT_FOUND FALSE)
        endif()

        if (NOT ("${OGRE_NEXT_VERSION_MINOR}" EQUAL "${GzOGRE2_FIND_VERSION_MINOR}"))
          message(STATUS "  ! ${OGRE_NEXT_PROJECT_NAME} found with incompatible version ${OGRE2_VERSION}")
          set(OGRE_NEXT_FOUND FALSE)
        endif()

        if ("${OGRE_NEXT_VERSION}" VERSION_EQUAL "${GzOGRE2_FIND_VERSION}")
          set(OGRE_NEXT_VERSION_EXACT TRUE)
          set(OGRE_NEXT_VERSION_COMPATIBLE TRUE)
        elseif ("${OGRE_NEXT_VERSION}" VERSION_GREATER_EQUAL "${GzOGRE2_FIND_VERSION}")
          set(OGRE_NEXT_VERSION_EXACT FALSE)
          set(OGRE_NEXT_VERSION_COMPATIBLE TRUE)
        endif()

        if (OGRE_NEXT_FOUND)
          set (OGRE_NEXT_COMPONENTS_FOUND TRUE)
          foreach(component ${GzOGRE2_FIND_COMPONENTS})
            unset(OGRE_NEXT-${component})
            find_library(OGRE_NEXT-${component}
              NAMES
                "${OGRE_NEXT_LIBRARY_NAME}${component}_d.${OGRE_NEXT_VERSION}"
                "${OGRE_NEXT_LIBRARY_NAME}${component}_d"
                "${OGRE_NEXT_LIBRARY_NAME}${component}.${OGRE_NEXT_VERSION}"
                "${OGRE_NEXT_LIBRARY_NAME}${component}"
              HINTS ${OGRE_NEXT_LIBRARY_DIRS}
              NO_CACHE
            )
            if (NOT "${OGRE_NEXT-${component}}" STREQUAL "OGRE_NEXT-${component}-NOTFOUND")
              message(STATUS "  + component ${component}: found")
            else()
              message(STATUS "  + component ${component}: not found")
              set(OGRE_NEXT_COMPONENTS_FOUND FALSE)
            endif()
          endforeach()
        endif()
      endif()
      set(OGRE_NEXT_FOUND ${OGRE_NEXT_COMPONENTS_FOUND})
    endif()
  endif()
endmacro()

# This should cover the most cases.
if (NOT OGRE_NEXT_FOUND)
  find_package_ogre_next(
    PROJECT_NAME "Ogre-Next"
    INSTALL_PATH "OGRE-Next"
    LIBRARY_NAME "OgreNext"
  )
endif()

if (NOT OGRE_NEXT_FOUND)
  message(STATUS "Searching for OGRE 2.3 from debs")
  find_package_ogre_next(
    PROJECT_NAME "OGRE-2.${GzOGRE2_FIND_VERSION_MINOR}"
    INSTALL_PATH "OGRE-2.${GzOGRE2_FIND_VERSION_MINOR}"
    LIBRARY_NAME "OgreNext" 
  )
endif()

if (OGRE_NEXT_FOUND)
  include(GzImportTarget)
  foreach(component ${GzOGRE2_FIND_COMPONENTS})
    unset(OGRE_NEXT-${component})
    find_library(OGRE_NEXT-${component}
      NAMES
        "${OGRE_NEXT_LIBRARY_NAME}${component}_d.${OGRE_NEXT_VERSION}"
        "${OGRE_NEXT_LIBRARY_NAME}${component}_d"
        "${OGRE_NEXT_LIBRARY_NAME}${component}.${OGRE_NEXT_VERSION}"
        "${OGRE_NEXT_LIBRARY_NAME}${component}"
      HINTS ${OGRE_NEXT_LIBRARY_DIRS}
      NO_CACHE)

    set(component_TARGET_NAME "GzOGRE2-${component}::GzOGRE2-${component}")
    set(component_INCLUDE_DIRS ${OGRE_NEXT_INCLUDE_DIRS})

    # Do include directory munging for components
    foreach (dir ${OGRE_NEXT_INCLUDE_DIRS})
      get_filename_component(dir_name "${dir}" NAME)
      if ("${dir_name}" STREQUAL ${GZ_PKG_NAME})
        # 1. append the Hlms/Common include dir if it exists.
        string(FIND ${component} "Hlms" HLMS_POS)
        if(${HLMS_POS} GREATER -1)
          set(dir_include "${dir}/Hlms/Common")
          if (EXISTS ${dir_include})
            list(APPEND component_INCLUDE_DIRS ${dir_include})
          endif()
        endif()
        # 2. append the PlanarReflections include
        if(${component} STREQUAL "PlanarReflections")
           list(APPEND component_INCLUDE_DIRS "${dir}/PlanarReflections")
        endif()
      endif()
    endforeach()

    set(component_LIBRARY_DIRS ${OGRE_NEXT_LIBRARY_DIRS})
    set(component_LIBRARIES ${OGRE_NEXT-${component}})
    gz_import_target(${component} TARGET_NAME ${component_TARGET_NAME}
      LIB_VAR component_LIBRARIES
      INCLUDE_VAR component_INCLUDE_DIRS
    )

    set_property(
      TARGET ${component_TARGET_NAME} 
      PROPERTY INTERFACE_LINK_DIRECTORIES
      ${OGRE_NEXT_LIBRARY_DIRS}
    )
    list(APPEND OGRE_NEXT_LIBRARIES ${component_TARGET_NAME})
  endforeach()

  set(OGRE_NEXT_RESOURCE_PATH "")
  if ("${OGRE_NEXT_PLUGINDIR}" STREQUAL "")
    foreach(resource_path ${OGRE_NEXT_LIBRARY_DIRS})
      list(APPEND OGRE_NEXT_RESOURCE_PATH "${resource_path}/${OGRE_NEXT_INSTALL_PATH}")
    endforeach()
  else()
    set(OGRE_NEXT_RESOURCE_PATH ${OGRE_NEXT_PLUGINDIR})
    # Seems that OGRE2_PLUGINDIR can end in a newline, which will cause problems
    # when we pass it to the compiler later.
    string(REPLACE "\n" "" OGRE_NEXT_RESOURCE_PATH ${OGRE_NEXT_RESOURCE_PATH})
  endif()

  set(GzOGRE2_FOUND TRUE)
  gz_import_target(GzOGRE2
    TARGET_NAME GzOGRE2::GzOGRE2
    LIB_VAR OGRE_NEXT_LIBRARIES
    INCLUDE_VAR OGRE_NEXT_INCLUDE_DIRS
  )
  set_property(
    TARGET GzOGRE2::GzOGRE2
    PROPERTY INTERFACE_LINK_DIRECTORIES
    ${OGRE_NEXT_LIBRARY_DIRS}
  )

  set(OGRE2_FOUND ${OGRE_NEXT_FOUND})
  set(OGRE2_VERSION ${OGRE_NEXT_VERSION})
  set(OGRE2_VERSION_MAJOR ${OGRE_NEXT_VERSION_MAJOR})
  set(OGRE2_VERSION_MINOR ${OGRE_NEXT_VERSION_MINOR})
  set(OGRE2_VERSION_PATCH ${OGRE_NEXT_VERSION_PATCH})
  set(OGRE2_LIBRARIES ${OGRE_NEXT_LIBRARIES})
  set(OGRE2_INCLUDE ${OGRE_NEXT_INCLUDE})  # Specifically used for ogre2/terra engine
  set(OGRE2_INCLUDE_DIRS ${OGRE_NEXT_INCLUDE_DIRS})
  set(OGRE2_RESOURCE_PATH ${OGRE_NEXT_RESOURCE_PATH})
  set(GzOGRE2_VERSION_EXACT ${OGRE_NEXT_VERSION_EXACT}) 
  set(GzOGRE2_VERSION_COMPATIBLE ${OGRE_NEXT_VERSION_COMPATIBLE})
endif()

set(IgnOGRE2_FOUND ${GzOGRE2_FOUND})  # TODO(CH3): Deprecated. Remove on tock.
set(IGN_PKG_NAME ${GZ_PKG_NAME})  # TODO(CH3): Deprecated. Remove on tock.
