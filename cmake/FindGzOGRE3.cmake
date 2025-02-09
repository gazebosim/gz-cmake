#===============================================================================
# Copyright (C) 2025 Open Source Robotics Foundation
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
# Find OGRE3 headers and libraries
#
# Usage of this module as follows:
#
#     gz_find_package(GzOGRE3 VERSION 3)
#
# Variables used by this module, they can change the default behaviour and need
# to be set before calling find_package:
#
#  GZ_OGRE3_PROJECT_NAME    Possible values: OGRE (default) or OGRE-Next
#                            Specify the project name used in the packaging.
#                            It will impact directly in the name of the
#                            CMake/pkg-config modules being used.
#
# Variables defined by this module:
#
#  OGRE3_FOUND              System has OGRE libs/headers
#  OGRE3_LIBRARIES          The OGRE libraries
#  OGRE3_INCLUDE_DIRS       The location of OGRE headers
#  OGRE3_VERSION            Full OGRE version in the form of MAJOR.MINOR.PATCH
#  OGRE3_VERSION_MAJOR      OGRE major version
#  OGRE3_VERSION_MINOR      OGRE minor version
#  OGRE3_VERSION_PATCH      OGRE patch version
#  OGRE3_RESOURCE_PATH      Path to ogre plugins directory
#  GzOGRE3::GzOGRE3         Imported target for OGRE3
#
# Supports finding the following OGRE3 components: HlmsPbs, HlmsUnlit, Overlay,
#  PlanarReflections, Atmosphere
#
# Example usage:
#
#     gz_find_package(GzOGRE3
#                     VERSION 3.0.0
#                     COMPONENTS HlmsPbs HlmsUnlit Overlay Atmosphere)


if(NOT (GzOGRE3_FIND_VERSION_MAJOR))
  message(WARNING
    "find_package(GzOGRE3) must be called with a VERSION argument with a minimum of major version")
  set(OGRE3_FOUND false)
  return()
endif()

# Reduce valid versions to 3.x series
if (${GzOGRE3_FIND_VERSION_MAJOR})
  if (${GzOGRE3_FIND_VERSION_MAJOR} VERSION_LESS "3" OR
      ${GzOGRE3_FIND_VERSION_MAJOR} VERSION_GREATER_EQUAL "4")
    set (OGRE3_FOUND false)
    return()
  endif()
endif()

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

find_package(PkgConfig QUIET)
if (PkgConfig_FOUND)
  set(PKG_CONFIG_PATH_ORIGINAL $ENV{PKG_CONFIG_PATH})
  foreach (GZ_OGRE3_PROJECT_NAME "OGRE" "OGRE-Next")
    message(STATUS "Looking for OGRE3 using the name: ${GZ_OGRE3_PROJECT_NAME}")
    if (GZ_OGRE3_PROJECT_NAME STREQUAL "OGRE")
      set(OGRE3_INSTALL_PATH "OGRE")
      set(OGRE3LIBNAME "Ogre")
    else()
      set(OGRE3_INSTALL_PATH "OGRE-Next")
      set(OGRE3LIBNAME "OgreNext")
    endif()

    # Note: OGRE3 installed from debs is named OGRE-3.0 while the version
    # installed from source does not have the 3.0 suffix
    # look for OGRE3 installed from debs
    gz_pkg_check_modules_quiet(${GZ_OGRE3_PROJECT_NAME} ${OGRE3_INSTALL_PATH} NO_CMAKE_ENVIRONMENT_PATH QUIET)

    if (${GZ_OGRE3_PROJECT_NAME}_FOUND)
      set(GZ_PKG_NAME ${OGRE3_INSTALL_PATH})
      set(OGRE3_FOUND ${${GZ_OGRE3_PROJECT_NAME}_FOUND})  # sync possible OGRE-Next to OGRE3
      set(OGRE3_LIBRARY_DIRS ${${GZ_OGRE3_PROJECT_NAME}_LIBRARY_DIRS})
      set(OGRE3_LIBRARIES ${${GZ_OGRE3_PROJECT_NAME}_LIBRARIES})  # sync possible Ogre-Next ot OGRE3
    else()
      # look for OGRE3 installed from source
      set(PKG_CONFIG_PATH_TMP ${PKG_CONFIG_PATH_ORIGINAL})
      execute_process(COMMAND pkg-config --variable pc_path pkg-config
                      OUTPUT_VARIABLE _pkgconfig_invoke_result
                      RESULT_VARIABLE _pkgconfig_failed)
      if(_pkgconfig_failed)
        GZ_BUILD_WARNING ("Failed to get pkg-config search paths")
      elseif (NOT _pkgconfig_invoke_result STREQUAL "")
        set (PKG_CONFIG_PATH_TMP "${PKG_CONFIG_PATH_TMP}:${_pkgconfig_invoke_result}")
      endif()

      # check and see if there are any paths at all
      if ("${PKG_CONFIG_PATH_TMP}" STREQUAL "")
        message("No valid pkg-config search paths found")
        return()
      endif()

      string(REPLACE ":" ";" PKG_CONFIG_PATH_TMP ${PKG_CONFIG_PATH_TMP})

      # loop through pkg config paths and find an ogre version that is >= 3.0.0
      foreach(pkg_path ${PKG_CONFIG_PATH_TMP})
        set(ENV{PKG_CONFIG_PATH} ${pkg_path})
        pkg_check_modules(OGRE3 "OGRE" NO_CMAKE_ENVIRONMENT_PATH QUIET)
        if (OGRE3_FOUND)
          if (${OGRE3_VERSION} VERSION_LESS 3.0.0)
            set (OGRE3_FOUND false)
          else()
            # pkg_check_modules does not provide complete path to libraries
            # So update variable to point to full path
            set(OGRE3_LIBRARY_NAME ${OGRE3_LIBRARIES})
            find_library(OGRE3_LIBRARY NAMES ${OGRE3_LIBRARY_NAME}
                                       HINTS ${OGRE3_LIBRARY_DIRS} NO_DEFAULT_PATH)
            if ("${OGRE3_LIBRARY}" STREQUAL "OGRE3_LIBRARY-NOTFOUND")
              set(OGRE3_FOUND false)
              continue()
            else()
              set(OGRE3_LIBRARIES ${OGRE3_LIBRARY})
            endif()
            set(GZ_PKG_NAME "OGRE")
            break()
          endif()
        endif()
      endforeach()
    endif()

    if (NOT OGRE3_FOUND)
      message(STATUS "  ! ${GZ_OGRE3_PROJECT_NAME} not found")

      # reset pkg config path
      set(ENV{PKG_CONFIG_PATH} ${PKG_CONFIG_PATH_ORIGINAL})

      continue()
    endif()

    # use pkg-config to find ogre plugin path
    # do it here before resetting the pkg-config paths
    pkg_get_variable(OGRE3_PLUGINDIR ${GZ_PKG_NAME} plugindir)

    if(NOT OGRE3_PLUGINDIR)
      GZ_BUILD_WARNING ("Failed to find OGRE3's plugin directory. The build will succeed, but there will likely be run-time errors.")
    endif()

    # reset pkg config path
    set(ENV{PKG_CONFIG_PATH} ${PKG_CONFIG_PATH_ORIGINAL})

    set(OGRE3_INCLUDE_DIRS ${${GZ_OGRE3_PROJECT_NAME}_INCLUDE_DIRS})  # sync possible OGRE-Next to OGRE3

    unset(OGRE3_INCLUDE CACHE)
    unset(OGRE3_INCLUDE)
    # verify ogre header can be found in the include path
    find_path(OGRE3_INCLUDE
      NAMES Ogre.h
      PATHS ${OGRE3_INCLUDE_DIRS}
      NO_DEFAULT_PATH
    )

    if(NOT OGRE3_INCLUDE)
      set(OGRE3_FOUND false)
      continue()
    endif()

    # manually search and append the the RenderSystem/GL3Plus path to
    # OGRE3_INCLUDE_DIRS so OGRE GL headers can be found
    foreach (dir ${OGRE3_INCLUDE_DIRS})
      get_filename_component(dir_name "${dir}" NAME)
      if ("${dir_name}" STREQUAL ${GZ_PKG_NAME})
        set(dir_include "${dir}/RenderSystems/GL3Plus")
      else()
        set(dir_include "${dir}")
      endif()
      list(APPEND OGRE3_INCLUDE_DIRS ${dir_include})
    endforeach()

    file(READ ${OGRE3_INCLUDE}/OgrePrerequisites.h OGRE_TEMP_VERSION_CONTENT)
    get_preprocessor_entry(OGRE_TEMP_VERSION_CONTENT OGRE_VERSION_MAJOR OGRE3_VERSION_MAJOR)
    get_preprocessor_entry(OGRE_TEMP_VERSION_CONTENT OGRE_VERSION_MINOR OGRE3_VERSION_MINOR)
    get_preprocessor_entry(OGRE_TEMP_VERSION_CONTENT OGRE_VERSION_PATCH OGRE3_VERSION_PATCH)
    get_preprocessor_entry(OGRE_TEMP_VERSION_CONTENT OGRE_VERSION_NAME OGRE3_VERSION_NAME)
    set(OGRE3_VERSION "${OGRE3_VERSION_MAJOR}.${OGRE3_VERSION_MINOR}.${OGRE3_VERSION_PATCH}")

    set(GzOGRE3_VERSION_EXACT FALSE)
    set(GzOGRE3_VERSION_COMPATIBLE FALSE)

    if (NOT ("${OGRE3_VERSION_MAJOR}" EQUAL "${GzOGRE3_FIND_VERSION_MAJOR}"))
      set(OGRE3_FOUND FALSE)
      continue()
    endif()

    if (NOT ("${OGRE3_VERSION_MINOR}" EQUAL "${GzOGRE3_FIND_VERSION_MINOR}"))
      message(STATUS "  ! ${GZ_OGRE3_PROJECT_NAME} found with incompatible version ${OGRE3_VERSION}")
      set(OGRE3_FOUND FALSE)
      continue()
    endif()

    if ("${OGRE3_VERSION}" VERSION_EQUAL "${GzOGRE3_FIND_VERSION}")
      set(GzOGRE3_VERSION_EXACT TRUE)
      set(GzOGRE3_VERSION_COMPATIBLE TRUE)
    endif()

    if ("${OGRE3_VERSION}" VERSION_GREATER "${GzOGRE3_FIND_VERSION}")
      set(GzOGRE3_VERSION_COMPATIBLE TRUE)
    endif()

    # find ogre components
    include(GzImportTarget)
    foreach(component ${GzOGRE3_FIND_COMPONENTS})
      find_library(OGRE3-${component}
        NAMES
          "${OGRE3LIBNAME}${component}_d.${OGRE3_VERSION}"
          "${OGRE3LIBNAME}${component}_d"
          "${OGRE3LIBNAME}${component}.${OGRE3_VERSION}"
          "${OGRE3LIBNAME}${component}"
        HINTS ${OGRE3_LIBRARY_DIRS})
      if (NOT "${OGRE3-${component}}" STREQUAL "OGRE3-${component}-NOTFOUND")
        message(STATUS "  + component ${component}: found")
        # create a new target for each component
        set(component_TARGET_NAME "GzOGRE3-${component}::GzOGRE3-${component}")
        set(component_INCLUDE_DIRS ${OGRE3_INCLUDE_DIRS})

          foreach (dir ${OGRE3_INCLUDE_DIRS})
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
              # 3. append the Atmosphere include
              if(${component} STREQUAL "Atmosphere")
                 list(APPEND component_INCLUDE_DIRS "${dir}/Atmosphere")
              endif()
            endif()
          endforeach()

        set(component_LIBRARY_DIRS ${OGRE3_LIBRARY_DIRS})
        set(component_LIBRARIES ${OGRE3-${component}})
        gz_import_target(${component} TARGET_NAME ${component_TARGET_NAME}
            LIB_VAR component_LIBRARIES
            INCLUDE_VAR component_INCLUDE_DIRS)

        # Forward the link directories to be used by RPath
        set_property(
          TARGET ${component_TARGET_NAME}
          PROPERTY INTERFACE_LINK_DIRECTORIES
          ${OGRE3_LIBRARY_DIRS}
        )
        # add it to the list of ogre libraries
        list(APPEND OGRE3_LIBRARIES ${component_TARGET_NAME})

      elseif(GzOGRE3_FIND_REQUIRED_${component})
        message(STATUS "  ! component ${component}: not found!")
        set(OGRE3_FOUND false)
      endif()
    endforeach()

    # OGRE was found using the current value in the loop. No need to iterate
    # more times.
    if (OGRE3_FOUND)
      break()
    else()
      message(STATUS "  ! ${GZ_OGRE3_PROJECT_NAME} not found")
    endif()
  endforeach()

  if (NOT OGRE3_FOUND)
    return()
  endif()

  if ("${OGRE3_PLUGINDIR}" STREQUAL "")
    # set path to find ogre plugins
    # keep variable naming consistent with ogre 1
    # TODO currently using harded paths based on dir structure in ubuntu
    foreach(resource_path ${OGRE3_LIBRARY_DIRS})
      foreach (ogre3_plugin_dir_name "OGRE" "OGRE-Next")
        if (EXISTS "${resource_path}/${ogre3_plugin_dir_name}")
          list(APPEND OGRE3_RESOURCE_PATH "${resource_path}/${ogre3_plugin_dir_name}")
        endif()
      endforeach()
    endforeach()
  else()
    set(OGRE3_RESOURCE_PATH ${OGRE3_PLUGINDIR})
    # Seems that OGRE3_PLUGINDIR can end in a newline, which will cause problems
    # when we pass it to the compiler later.
    string(REPLACE "\n" "" OGRE3_RESOURCE_PATH ${OGRE3_RESOURCE_PATH})
  endif()

  # We need to manually specify the pkgconfig entry (and type of entry),
  # because gz_pkg_check_modules does not work for it.
  include(GzPkgConfig)
  gz_pkg_config_library_entry(GzOGRE3 OgreMain)
endif()

set(GzOGRE3_FOUND false)
# create OGRE3 target
if (OGRE3_FOUND)
  set(GzOGRE3_FOUND true)

  gz_import_target(GzOGRE3
    TARGET_NAME GzOGRE3::GzOGRE3
    LIB_VAR OGRE3_LIBRARIES
    INCLUDE_VAR OGRE3_INCLUDE_DIRS)

  # Forward the link directories to be used by RPath
  set_property(
    TARGET GzOGRE3::GzOGRE3
    PROPERTY INTERFACE_LINK_DIRECTORIES
    ${OGRE3_LIBRARY_DIRS}
  )
else()
  # Unset variables so that we don't leak incorrect versions
  set(OGRE3_VERSION "")
  set(OGRE3_VERSION_MAJOR "")
  set(OGRE3_VERSION_MINOR "")
  set(OGRE3_VERSION_PATCH "")
  set(OGRE3_LIBRARIES "")
  set(OGRE3_INCLUDE_DIRS "")
endif()
