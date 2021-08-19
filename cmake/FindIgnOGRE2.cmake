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
# Supports finding the following OGRE2 components: HlmsPbs, HlmsUnlit, Overlay
#
# Example usage:
#
#     ign_find_package(IgnOGRE2
#                      VERSION 2.2.0
#                      COMPONENTS HlmsPbs HlmsUnlit Overlay)

# sanity check
if (${IgnOGRE2_FIND_VERSION_MAJOR})
  if (${IgnOGRE2_FIND_VERSION_MAJOR} VERSION_LESS "2")
    set (OGRE2_FOUND false)
    return()
  endif()
endif()

message(STATUS "-- Finding OGRE 2.${IgnOGRE2_FIND_VERSION_MINOR}")
set(OGRE2_INSTALL_PATH "OGRE-2.${IgnOGRE2_FIND_VERSION_MINOR}")

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

if (NOT WIN32)
  set(PKG_CONFIG_PATH_ORIGINAL $ENV{PKG_CONFIG_PATH})

  # Note: OGRE2 installed from debs is named OGRE-2.2 while the version
  # installed from source does not have the 2.2 suffix
  # look for OGRE2 installed from debs
  ign_pkg_check_modules_quiet(OGRE2 ${OGRE2_INSTALL_PATH} NO_CMAKE_ENVIRONMENT_PATH QUIET)

  if (OGRE2_FOUND)
    set(IGN_PKG_NAME ${OGRE2_INSTALL_PATH})
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
    return()
  endif()

  # use pkg-config to find ogre plugin path
  # do it here before resetting the pkg-config paths
  execute_process(COMMAND pkg-config --variable=plugindir ${IGN_PKG_NAME}
                  OUTPUT_VARIABLE _pkgconfig_invoke_result
                  RESULT_VARIABLE _pkgconfig_failed)
  if(_pkgconfig_failed)
    IGN_BUILD_WARNING ("Failed to find OGRE's plugin directory. The build will succeed, but there will likely be run-time errors.")
  else()
    set(OGRE2_PLUGINDIR ${_pkgconfig_invoke_result})
  endif()

  # reset pkg config path
  set(ENV{PKG_CONFIG_PATH} ${PKG_CONFIG_PATH_ORIGINAL})

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

  # find ogre components
  include(IgnImportTarget)
  foreach(component ${IgnOGRE2_FIND_COMPONENTS})
    find_library(OGRE2-${component}
      NAMES
        "Ogre${component}_d.${OGRE2_VERSION}"
        "Ogre${component}_d"
        "Ogre${component}.${OGRE2_VERSION}"
        "Ogre${component}"
      HINTS ${OGRE2_LIBRARY_DIRS})
    if (NOT "OGRE2-${component}" STREQUAL "OGRE2-${component}-NOTFOUND")

      # create a new target for each component
      set(component_TARGET_NAME "IgnOGRE2-${component}::IgnOGRE2-${component}")
      set(component_INCLUDE_DIRS ${OGRE2_INCLUDE_DIRS})

      # append the Hlms/Common include dir if it exists.
      string(FIND ${component} "Hlms" HLMS_POS)
      if(${HLMS_POS} GREATER -1)
        foreach (dir ${OGRE2_INCLUDE_DIRS})
          get_filename_component(dir_name "${dir}" NAME)
          if ("${dir_name}" STREQUAL ${IGN_PKG_NAME})
            set(dir_include "${dir}/Hlms/Common")
            if (EXISTS ${dir_include})
              list(APPEND component_INCLUDE_DIRS ${dir_include})
            endif()
          endif()
        endforeach()
      endif()

      set(component_LIBRARY_DIRS ${OGRE2_LIBRARY_DIRS})
      set(component_LIBRARIES ${OGRE2-${component}})
      ign_import_target(${component} TARGET_NAME ${component_TARGET_NAME}
          LIB_VAR component_LIBRARIES
          INCLUDE_VAR component_INCLUDE_DIRS)

      # add it to the list of ogre libraries
      list(APPEND OGRE2_LIBRARIES ${component_TARGET_NAME})

    elseif(IgnOGRE2_FIND_REQUIRED_${component})
      set(OGRE2_FOUND false)
    endif()
  endforeach()

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

  # We need to manually specify the pkgconfig entry (and type of entry),
  # because ign_pkg_check_modules does not work for it.
  include(IgnPkgConfig)
  ign_pkg_config_library_entry(IgnOGRE2 OgreMain)

else() #WIN32
  # reset ogre variables to be sure they dont conflict with OGRE1
  # todo(anyone) May need to change this to set(<variable> "")
  # and verify that it works on Windows.
  # More info: when evaluating Variable References of the form ${VAR}, CMake
  # first searches for a normal variable with that name. If no such normal
  # variable exists, CMake will then search for a cache entry with that name.
  # Because of this unsetting a normal variable can expose a cache variable
  # that was previously hidden. To force a variable reference of the form ${VAR}
  # to return an empty string, use set(<variable> ""), which clears the normal
  # variable but leaves it defined.
  unset(OGRE_FOUND)
  unset(OGRE_INCLUDE_DIRS)
  unset(OGRE_LIBRARIES)
  foreach(ogre_component ${IgnOGRE2_FIND_COMPONENTS})
    set(OGRE_${ogre_component}_FOUND FALSE)
  endforeach()
  # currently designed to work with osrf vcpkg ogre2 portfile
  set(OGRE2_PATHS "")
  if(${IgnOGRE2_FIND_VERSION_MINOR} EQUAL 2)
    message(STATUS "Finding 2")
    # Specific case for osrf ogre 2.2 vcpkg
    foreach(_rootPath ${VCPKG_CMAKE_FIND_ROOT_PATH})
      list(APPEND OGRE2_PATHS "${_rootPath}/share/ogre22")
    endforeach()
  else()
    set(OGRE2_PATHS ${VCPKG_CMAKE_FIND_ROOT_PATH})
  endif()

  find_package(OGRE2
               HINTS ${OGRE2_PATHS}
               COMPONENTS ${IgnOGRE2_FIND_COMPONENTS})
  set(OGRE2_INCLUDE_DIRS ${OGRE_INCLUDE_DIRS})
  # Imported from OGRE1: link component libs outside of static build
  foreach(ogre_component ${IgnOGRE2_FIND_COMPONENTS})
    if (OGRE_${ogre_component}_FOUND)
       list(APPEND OGRE_LIBRARIES "${OGRE_${ogre_component}_LIBRARIES}")
    endif()
  endforeach()

  select_lib_by_build_type("${OGRE_LIBRARIES}" OGRE2_LIBRARIES)

  set(OGRE2_PLUGINS_VCPKG Plugin_ParticleFX RenderSystem_GL RenderSystem_GL3Plus RenderSystem_Direct3D11)

  foreach(PLUGIN ${OGRE2_PLUGINS_VCPKG})
    if(OGRE_${PLUGIN}_FOUND)
      message("Plugin found: ${PLUGIN}")
      list(APPEND OGRE2_INCLUDE_DIRS ${OGRE_${PLUGIN}_INCLUDE_DIRS})
    endif()
  endforeach()

  include(IgnPkgConfig)
  ign_pkg_config_library_entry(IgnOGRE2 OgreMain)
endif()

set(IgnOGRE2_FOUND false)
# create OGRE2 target
if (OGRE2_FOUND)
  set(IgnOGRE2_FOUND true)

  ign_import_target(IgnOGRE2
    TARGET_NAME IgnOGRE2::IgnOGRE2
    LIB_VAR OGRE2_LIBRARIES
    INCLUDE_VAR OGRE2_INCLUDE_DIRS)
endif()
