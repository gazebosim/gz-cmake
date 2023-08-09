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
#     ign_find_package(IgnOGRE2)
#
# Variables used by this module, they can change the default behaviour and need
# to be set before calling find_package:
#
#  IGN_OGRE2_PROJECT_NAME    Possible values: OGRE2 (default) or OGRE-Next
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
#  IgnOGRE2::IgnOGRE2       Imported target for OGRE2
#
# On Windows, we assume that all the OGRE* defines are passed in manually
# to CMake.
#
# Supports finding the following OGRE2 components: HlmsPbs, HlmsUnlit, Overlay,
#  PlanarReflections
#
# Example usage:
#
#     ign_find_package(IgnOGRE2
#                      VERSION 2.2.0
#                      COMPONENTS HlmsPbs HlmsUnlit Overlay)


# Sanity check: exclude OGRE1 project releasing versions in two ways:
#  - Legacy in from using 1.x.y until 1.12.y series
#  - Modern versions using X.Y.Z starting with 13.y.z
# Reduce valid versions to 2.x series
if (${IgnOGRE2_FIND_VERSION_MAJOR})
  if (${IgnOGRE2_FIND_VERSION_MAJOR} VERSION_LESS "2" OR
      ${IgnOGRE2_FIND_VERSION_MAJOR} VERSION_GREATER_EQUAL "3")
    set (OGRE2_FOUND false)
    return()
  endif()
endif()

macro(append_library VAR LIB)
  if(EXISTS "${LIB}")
    list(APPEND ${VAR} ${LIB})
  endif()
endmacro()

# Ubuntu Jammy version 2.2.5+dfsg3-0ubuntu2 is buggy in the pkg-config files
# duplicating usr/usr for some paths in pkg-config
macro(fix_pkgconfig_prefix_jammy_bug FILESYSTEM_PATH OUTPUT_VAR)
  if (NOT EXISTS "${FILESYSTEM_PATH}")
    string(REPLACE "/usr//usr" "/usr"
      ${OUTPUT_VAR}
      ${FILESYSTEM_PATH})
  endif()
endmacro()

# Ubuntu Jammy version 2.2.5+dfsg3-0ubuntu2 is buggy in the pkg-config files
# using a non existing path /usr/lib/${arch}/OGRE/OGRE-Next insted of the path
# /usr/lib/${arch}/OGRE-Next which is the right one
macro(fix_pkgconfig_resource_path_jammy_bug FILESYSTEM_PATH OUTPUT_VAR)
  if (NOT EXISTS "${FILESYSTEM_PATH}")
    string(REPLACE "OGRE/OGRE-Next" "OGRE-Next"
      ${OUTPUT_VAR}
      ${FILESYSTEM_PATH})
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

if (NOT WIN32)
  set(PKG_CONFIG_PATH_ORIGINAL $ENV{PKG_CONFIG_PATH})
  foreach (IGN_OGRE2_PROJECT_NAME "OGRE2" "OGRE-Next")
    message(STATUS "Looking for OGRE using the name: ${IGN_OGRE2_PROJECT_NAME}")
    if (IGN_OGRE2_PROJECT_NAME STREQUAL "OGRE2")
      set(OGRE2_INSTALL_PATH "OGRE-2.${IgnOGRE2_FIND_VERSION_MINOR}")
      set(OGRE2LIBNAME "Ogre")
    else()
      set(OGRE2_INSTALL_PATH "OGRE-Next")
      set(OGRE2LIBNAME "OgreNext")
    endif()

    # Note: OGRE2 installed from debs is named OGRE-2.2 while the version
    # installed from source does not have the 2.2 suffix
    # look for OGRE2 installed from debs
    ign_pkg_check_modules_quiet(${IGN_OGRE2_PROJECT_NAME} ${OGRE2_INSTALL_PATH} NO_CMAKE_ENVIRONMENT_PATH QUIET)

    if (${IGN_OGRE2_PROJECT_NAME}_FOUND)
      set(IGN_PKG_NAME ${OGRE2_INSTALL_PATH})
      set(OGRE2_FOUND ${${IGN_OGRE2_PROJECT_NAME}_FOUND})  # sync possible OGRE-Next to OGRE2
      fix_pkgconfig_prefix_jammy_bug("${${IGN_OGRE2_PROJECT_NAME}_LIBRARY_DIRS}" OGRE2_LIBRARY_DIRS)
      set(OGRE2_LIBRARIES ${${IGN_OGRE2_PROJECT_NAME}_LIBRARIES})  # sync possible Ogre-Next ot OGRE2
    else()
      # look for OGRE2 installed from source
      set(PKG_CONFIG_PATH_TMP ${PKG_CONFIG_PATH_ORIGINAL})
      execute_process(COMMAND pkg-config --variable pc_path pkg-config
                      OUTPUT_VARIABLE _pkgconfig_invoke_result
                      RESULT_VARIABLE _pkgconfig_failed)
      if(_pkgconfig_failed)
        IGN_BUILD_WARNING ("Failed to get pkg-config search paths")
      elseif (NOT _pkgconfig_invoke_result STREQUAL "")
        set (PKG_CONFIG_PATH_TMP "${PKG_CONFIG_PATH_TMP}:${_pkgconfig_invoke_result}")
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
        pkg_check_modules(OGRE2 "OGRE" NO_CMAKE_ENVIRONMENT_PATH QUIET)
        if (OGRE2_FOUND)
          if (${OGRE2_VERSION} VERSION_LESS 2.0.0)
            set (OGRE2_FOUND false)
          else ()
            # pkg_check_modules does not provide complete path to libraries
            # So update variable to point to full path
            set(OGRE2_LIBRARY_NAME ${OGRE2_LIBRARIES})
            find_library(OGRE2_LIBRARY NAMES ${OGRE2_LIBRARY_NAME}
                                       HINTS ${OGRE2_LIBRARY_DIRS} NO_DEFAULT_PATH)
            if ("${OGRE2_LIBRARY}" STREQUAL "OGRE2_LIBRARY-NOTFOUND")
              set(OGRE2_FOUND false)
              continue()
            else()
              set(OGRE2_LIBRARIES ${OGRE2_LIBRARY})
            endif()
            set(IGN_PKG_NAME "OGRE")
            break()
          endif()
        endif()
      endforeach()
    endif()

    if (NOT OGRE2_FOUND)
      message(STATUS "  ! ${IGN_OGRE2_PROJECT_NAME} not found")

      # reset pkg config path
      set(ENV{PKG_CONFIG_PATH} ${PKG_CONFIG_PATH_ORIGINAL})

      continue()
    endif()

    # use pkg-config to find ogre plugin path
    # do it here before resetting the pkg-config paths  
    pkg_get_variable(OGRE2_PLUGINDIR ${IGN_PKG_NAME} plugindir)

    if(NOT OGRE2_PLUGINDIR)
      IGN_BUILD_WARNING ("Failed to find OGRE's plugin directory. The build will succeed, but there will likely be run-time errors.")
    else()
      fix_pkgconfig_prefix_jammy_bug("${OGRE2_PLUGINDIR}" OGRE2_PLUGINDIR)
    endif()

    # reset pkg config path
    set(ENV{PKG_CONFIG_PATH} ${PKG_CONFIG_PATH_ORIGINAL})

    set(OGRE2_INCLUDE_DIRS ${${IGN_OGRE2_PROJECT_NAME}_INCLUDE_DIRS})  # sync possible OGRE-Next to OGRE2

    # verify ogre header can be found in the include path
    find_path(OGRE2_INCLUDE
      NAMES Ogre.h
      PATHS ${OGRE2_INCLUDE_DIRS}
      NO_DEFAULT_PATH
    )

    if(NOT OGRE2_INCLUDE)
      set(OGRE2_FOUND false)
      continue()
    endif()

    # manually search and append the the RenderSystem/GL3Plus path to
    # OGRE2_INCLUDE_DIRS so OGRE GL headers can be found
    foreach (dir ${OGRE2_INCLUDE_DIRS})
      get_filename_component(dir_name "${dir}" NAME)
      if ("${dir_name}" STREQUAL ${IGN_PKG_NAME})
        set(dir_include "${dir}/RenderSystems/GL3Plus")
      else()
        set(dir_include "${dir}")
      endif()
      list(APPEND OGRE2_INCLUDE_DIRS ${dir_include})
    endforeach()

    file(READ ${OGRE2_INCLUDE}/OgrePrerequisites.h OGRE_TEMP_VERSION_CONTENT)
    get_preprocessor_entry(OGRE_TEMP_VERSION_CONTENT OGRE_VERSION_MAJOR OGRE2_VERSION_MAJOR)
    get_preprocessor_entry(OGRE_TEMP_VERSION_CONTENT OGRE_VERSION_MINOR OGRE2_VERSION_MINOR)
    get_preprocessor_entry(OGRE_TEMP_VERSION_CONTENT OGRE_VERSION_PATCH OGRE2_VERSION_PATCH)
    get_preprocessor_entry(OGRE_TEMP_VERSION_CONTENT OGRE_VERSION_NAME OGRE2_VERSION_NAME)
    set(OGRE2_VERSION "${OGRE2_VERSION_MAJOR}.${OGRE2_VERSION_MINOR}.${OGRE2_VERSION_PATCH}")

    set(IgnOGRE2_VERSION_EXACT FALSE)
    set(IgnOGRE2_VERSION_COMPATIBLE FALSE)

    if (NOT ("${OGRE2_VERSION_MAJOR}" EQUAL "${IgnOGRE2_FIND_VERSION_MAJOR}"))
      set(OGRE2_FOUND FALSE)
      continue()
    endif()

    if (NOT ("${OGRE2_VERSION_MINOR}" EQUAL "${IgnOGRE2_FIND_VERSION_MINOR}"))
      message(STATUS "  ! ${IGN_OGRE2_PROJECT_NAME} found with incompatible version ${OGRE2_VERSION}")
      set(OGRE2_FOUND FALSE)
      continue()
    endif()

    if ("${OGRE2_VERSION}" VERSION_EQUAL "${IgnOGRE2_FIND_VERSION}")
      set(IgnOGRE2_VERSION_EXACT TRUE)
      set(IgnOGRE2_VERSION_COMPATIBLE TRUE)
    endif()

    if ("${OGRE2_VERSION}" VERSION_GREATER "${IgnOGRE2_FIND_VERSION}")
      set(IgnOGRE2_VERSION_COMPATIBLE TRUE)
    endif()

    # find ogre components
    include(IgnImportTarget)
    foreach(component ${IgnOGRE2_FIND_COMPONENTS})
      find_library(OGRE2-${component}
        NAMES
          "${OGRE2LIBNAME}${component}_d.${OGRE2_VERSION}"
          "${OGRE2LIBNAME}${component}_d"
          "${OGRE2LIBNAME}${component}.${OGRE2_VERSION}"
          "${OGRE2LIBNAME}${component}"
        HINTS ${OGRE2_LIBRARY_DIRS})
      if (NOT "${OGRE2-${component}}" STREQUAL "OGRE2-${component}-NOTFOUND")
        message(STATUS "  + component ${component}: found")
        # create a new target for each component
        set(component_TARGET_NAME "IgnOGRE2-${component}::IgnOGRE2-${component}")
        set(component_INCLUDE_DIRS ${OGRE2_INCLUDE_DIRS})

          foreach (dir ${OGRE2_INCLUDE_DIRS})
            get_filename_component(dir_name "${dir}" NAME)
            if ("${dir_name}" STREQUAL ${IGN_PKG_NAME})
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

        set(component_LIBRARY_DIRS ${OGRE2_LIBRARY_DIRS})
        set(component_LIBRARIES ${OGRE2-${component}})
        ign_import_target(${component} TARGET_NAME ${component_TARGET_NAME}
            LIB_VAR component_LIBRARIES
            INCLUDE_VAR component_INCLUDE_DIRS)

        # Forward the link directories to be used by RPath
        set_property(
          TARGET ${component_TARGET_NAME}
          PROPERTY INTERFACE_LINK_DIRECTORIES
          ${OGRE2_LIBRARY_DIRS}
        )
        # add it to the list of ogre libraries
        list(APPEND OGRE2_LIBRARIES ${component_TARGET_NAME})

      elseif(IgnOGRE2_FIND_REQUIRED_${component})
        message(STATUS "  ! component ${component}: not found!")
        set(OGRE2_FOUND false)
      endif()
    endforeach()

    # OGRE was found using the current value in the loop. No need to iterate
    # more times.
    if (OGRE2_FOUND)
      break()
    else()
      message(STATUS "  ! ${IGN_OGRE2_PROJECT_NAME} not found")
    endif()
  endforeach()

  if (NOT OGRE2_FOUND)
    return()
  endif()

  if ("${OGRE2_PLUGINDIR}" STREQUAL "")
    # set path to find ogre plugins
    # keep variable naming consistent with ogre 1
    # TODO currently using harded paths based on dir structure in ubuntu
    foreach(resource_path ${OGRE2_LIBRARY_DIRS})
      list(APPEND OGRE2_RESOURCE_PATH "${resource_path}/OGRE")
    endforeach()
  else()
    set(OGRE2_RESOURCE_PATH ${OGRE2_PLUGINDIR})
    # Seems that OGRE2_PLUGINDIR can end in a newline, which will cause problems
    # when we pass it to the compiler later.
    string(REPLACE "\n" "" OGRE2_RESOURCE_PATH ${OGRE2_RESOURCE_PATH})
  endif()
  fix_pkgconfig_resource_path_jammy_bug("${OGRE2_RESOURCE_PATH}" OGRE2_RESOURCE_PATH)

  # We need to manually specify the pkgconfig entry (and type of entry),
  # because ign_pkg_check_modules does not work for it.
  include(IgnPkgConfig)
  ign_pkg_config_library_entry(IgnOGRE2 OgreMain)
else() #WIN32

  set(OGRE2_FOUND TRUE)
  set(OGRE_LIBRARIES "")
  set(OGRE2_VERSION "")
  set(OGRE2_VERSION_MAJOR "")
  set(OGRE2_VERSION_MINOR "")
  set(OGRE2_RESOURCE_PATH "")

  set(OGRE2_SEARCH_VER "OGRE-${IgnOGRE2_FIND_VERSION_MAJOR}.${IgnOGRE2_FIND_VERSION_MINOR}")
  set(OGRE2_PATHS "")
  set(OGRE2_INC_PATHS "")
  foreach(_rootPath ${VCPKG_CMAKE_FIND_ROOT_PATH})
      list(APPEND OGRE2_PATHS "${_rootPath}/lib/${OGRE2_SEARCH_VER}/")
      list(APPEND OGRE2_PATHS "${_rootPath}/lib/${OGRE2_SEARCH_VER}/manual-link/")
      list(APPEND OGRE2_INC_PATHS "${_rootPath}/include/${OGRE2_SEARCH_VER}")
  endforeach()

  find_library(OGRE2_LIBRARY
    NAMES "OgreMain"
    HINTS ${OGRE2_PATHS}
    NO_DEFAULT_PATH)

  find_path(OGRE2_INCLUDE
    NAMES "Ogre.h"
    HINTS ${OGRE2_INC_PATHS})

  if("${OGRE2_LIBRARY}" STREQUAL "OGRE2_LIBRARY-NOTFOUND")
    set(OGRE2_FOUND false)
  else()
    set(OGRE2_LIBRARIES ${OGRE2_LIBRARY})
  endif()

  if(NOT OGRE2_INCLUDE)
    set(OGRE2_FOUND false)
  endif()

  if (OGRE2_FOUND)
    set(OGRE2_INCLUDE_DIRS ${OGRE2_INCLUDE})
    set(OGRE2_LIBRARY_DIRS ${OGRE2_PATHS})

    file(READ ${OGRE2_INCLUDE}/OgrePrerequisites.h OGRE_TEMP_VERSION_CONTENT)
    get_preprocessor_entry(OGRE_TEMP_VERSION_CONTENT OGRE_VERSION_MAJOR OGRE2_VERSION_MAJOR)
    get_preprocessor_entry(OGRE_TEMP_VERSION_CONTENT OGRE_VERSION_MINOR OGRE2_VERSION_MINOR)
    get_preprocessor_entry(OGRE_TEMP_VERSION_CONTENT OGRE_VERSION_PATCH OGRE2_VERSION_PATCH)
    get_preprocessor_entry(OGRE_TEMP_VERSION_CONTENT OGRE_VERSION_NAME OGRE2_VERSION_NAME)
    set(OGRE2_VERSION "${OGRE2_VERSION_MAJOR}.${OGRE2_VERSION_MINOR}.${OGRE2_VERSION_PATCH}")
    set(OGRE_TEMP_VERSION_CONTENT "")

    macro(ogre_find_component COMPONENT HEADER PATH_HINTS)
      set(PREFIX OGRE2_${COMPONENT})
      find_path(${PREFIX}_INCLUDE_DIR
          NAMES ${HEADER}
          HINTS ${OGRE2_INCLUDE_DIRS}
          PATH_SUFFIXES
              ${PATH_HINTS} ${COMPONENT} ${OGRE2_SEARCH_VER}/${COMPONENT})

      find_library(${PREFIX}_LIBRARY
          NAMES
              "Ogre${COMPONENT}"
              "Ogre${COMPONENT}_d"
          HINTS
              ${OGRE2_LIBRARY_DIRS}
          NO_DEFAULT_PATH)

      if (NOT ${PREFIX}_FOUND)
        if (${PREFIX}_INCLUDE_DIR AND ${PREFIX}_LIBRARY)
          set(${PREFIX}_FOUND TRUE)
          set(${PREFIX}_INCLUDE_DIRS ${${PREFIX}_INCLUDE_DIR})
          set(${PREFIX}_LIBRARIES ${${PREFIX}_LIBRARY})
          message(STATUS "Found ${PREFIX}: ${${PREFIX}_LIBRARIES}")
        endif()
      endif()
  endmacro()

  macro(ogre_find_plugin PLUGIN HEADER)
    set(PREFIX OGRE2_${PLUGIN})
    string(REPLACE "RenderSystem_" "" PLUGIN_TEMP ${PLUGIN})
    string(REPLACE "Plugin_" "" PLUGIN_NAME ${PLUGIN_TEMP})
      # header files for plugins are not usually needed, but find them anyway if they are present
    set(OGRE2_PLUGIN_PATH_SUFFIXES
      PlugIns
      PlugIns/${PLUGIN_NAME}
      Plugins
      Plugins/${PLUGIN_NAME}
      ${PLUGIN}
      RenderSystems
      RenderSystems/${PLUGIN_NAME}
      ${ARGN})
    find_path(
      ${PREFIX}_INCLUDE_DIR
      NAMES
        ${HEADER}
      HINTS
        ${OGRE2_INCLUDE_DIRS} ${OGRE_PREFIX_SOURCE}
      PATH_SUFFIXES
        ${OGRE2_PLUGIN_PATH_SUFFIXES})
    find_library(${PREFIX}_LIBRARY
      NAMES ${PLUGIN}
      HINTS  ${OGRE2_LIBRARY_DIRS}
      PATH_SUFFIXES "" opt "${OGRE2_SEARCH_VER}" "${OGRE2_SEARCH_VER}/opt")

    if (NOT ${PREFIX}_FOUND)
      if (${PREFIX}_INCLUDE_DIR AND ${PREFIX}_LIBRARY)
          set(${PREFIX}_FOUND TRUE)
          set(${PREFIX}_INCLUDE_DIRS ${${PREFIX}_INCLUDE_DIR})
          set(${PREFIX}_LIBRARIES ${${PREFIX}_LIBRARY})
          message(STATUS "Found ${PREFIX}: ${${PREFIX}_LIBRARIES}")
      endif()
    endif()
  endmacro()

  ogre_find_component(Overlay OgreOverlaySystem.h "Overlay")
  ogre_find_component(HlmsPbs OgreHlmsPbs.h Hlms/Pbs/)
  ogre_find_component(HlmsUnlit OgreHlmsUnlit.h Hlms/Unlit)

  ogre_find_plugin(Plugin_ParticleFX OgreParticleFXPrerequisites.h PlugIns/ParticleFX/include)
  ogre_find_plugin(RenderSystem_GL3Plus OgreGL3PlusRenderSystem.h RenderSystems/GL3Plus/include)
  ogre_find_plugin(RenderSystem_Direct3D11 OgreD3D11RenderSystem.h RenderSystems/Direct3D11/include)

  foreach(component ${IgnOGRE2_FIND_COMPONENTS})
    set(PREFIX OGRE2_${component})
    if(${PREFIX}_FOUND)
      set(component_TARGET_NAME "IgnOGRE2-${component}::IgnOGRE2-${component}")
      set(component_INCLUDE_DIRS ${${PREFIX}_INCLUDE_DIRS})
      # append the Hlms/Common include dir if it exists.
      string(FIND ${component} "Hlms" HLMS_POS)
      if(${HLMS_POS} GREATER -1)
        foreach (dir ${OGRE2_INCLUDE_DIRS})
          get_filename_component(dir_name "${dir}" NAME)
          if ("${dir_name}" STREQUAL "OGRE-${OGRE2_VERSION_MAJOR}.${OGRE2_VERSION_MINOR}")
            set(dir_include "${dir}/Hlms/Common")
            if (EXISTS ${dir_include})
              list(APPEND component_INCLUDE_DIRS ${dir_include})
            endif()
          endif()
        endforeach()
      endif()

      set(component_LIBRARIES ${${PREFIX}_LIBRARIES})

      ign_import_target(${component}
        TARGET_NAME ${component_TARGET_NAME}
        LIB_VAR component_LIBRARIES
        INCLUDE_VAR component_INCLUDE_DIRS
      )
      list(APPEND OGRE2_LIBRARIES ${component_TARGET_NAME})
    endif()
  endforeach()

  set(OGRE2_PLUGINS_VCPKG Plugin_ParticleFX RenderSystem_GL3Plus RenderSystem_Direct3D11)
  foreach(PLUGIN ${OGRE2_PLUGINS_VCPKG})
    if(OGRE2_${PLUGIN}_FOUND)
      list(APPEND OGRE2_INCLUDE_DIRS ${OGRE2_${PLUGIN}_INCLUDE_DIRS})
    endif()
  endforeach()
  endif()
endif()

set(IgnOGRE2_FOUND false)
# create OGRE2 target
if (OGRE2_FOUND)
  set(IgnOGRE2_FOUND true)

  ign_import_target(IgnOGRE2
    TARGET_NAME IgnOGRE2::IgnOGRE2
    LIB_VAR OGRE2_LIBRARIES
    INCLUDE_VAR OGRE2_INCLUDE_DIRS)

  # Forward the link directories to be used by RPath
  set_property(
    TARGET IgnOGRE2::IgnOGRE2
    PROPERTY INTERFACE_LINK_DIRECTORIES
    ${OGRE2_LIBRARY_DIRS}
  )
else()
  # Unset variables so that we don't leak incorrect versions
  set(OGRE2_VERSION "")
  set(OGRE2_VERSION_MAJOR "")
  set(OGRE2_VERSION_MINOR "")
  set(OGRE2_VERSION_PATCH "")
  set(OGRE2_LIBRARIES "")
  set(OGRE2_INCLUDE_DIRS "")
endif()
