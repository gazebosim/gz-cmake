#.rst
# IgnPackaging
# ----------------
#
# ign_setup_packages
#
# Sets up package information for an ignition library project.
#
# ign_create_package
#
# Creates a package for an ignition library project
#
#===============================================================================
# Copyright (C) 2017 Open Source Robotics Foundation
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

#################################################
# Set up package information
macro(ign_setup_packages)

  #============================================================================
  # Use GNUInstallDirs to get canonical paths.
  # We use this filesystem style on Windows as well, because (quite frankly)
  # Windows does not seem to have any sensible convention of its own for
  # installing development libraries. (If anyone is aware of a widely accepted
  # convention for where to install development libraries on Windows, please
  # correct this.)
  include(GNUInstallDirs)

  #============================================================================
  #Find available package generators

  # DEB
  if("${CMAKE_SYSTEM}" MATCHES "Linux")
    find_program(DPKG_PROGRAM dpkg)
    if(EXISTS ${DPKG_PROGRAM})
      list(APPEND CPACK_GENERATOR "DEB")
    endif(EXISTS ${DPKG_PROGRAM})

    find_program(RPMBUILD_PROGRAM rpmbuild)
  endif()

  list(APPEND CPACK_SOURCE_GENERATOR "TBZ2")
  list(APPEND CPACK_SOURCE_GENERATOR "ZIP")
  list(APPEND CPACK_SOURCE_IGNORE_FILES "TODO;\.hg/;\.sw.$;/build/;\.hgtags;\.hgignore;appveyor\.yml;\.travis\.yml;codecov\.yml")

  include(InstallRequiredSystemLibraries)

  #execute_process(COMMAND dpkg --print-architecture _NPROCE)
  set(DEBIAN_PACKAGE_DEPENDS "")

  set(RPM_PACKAGE_DEPENDS "")

  set(PROJECT_CPACK_CFG_FILE "${PROJECT_BINARY_DIR}/cpack_options.cmake")

  #============================================================================
  # Set CPack variables
  set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION_FULL}")
  set(CPACK_PACKAGE_VERSION_MAJOR "${PROJECT_VERSION_MAJOR}")
  set(CPACK_PACKAGE_VERSION_MINOR "${PROJECT_VERSION_MINOR}")
  set(CPACK_PACKAGE_VERSION_PATCH "${PROJECT_VERSION_PATCH}")

  if(CPACK_GENERATOR)
    message(STATUS "Found CPack generators: ${CPACK_GENERATOR}")

    configure_file("${IGNITION_CMAKE_DIR}/cpack_options.cmake.in"
      ${PROJECT_CPACK_CFG_FILE} @ONLY)

    set(CPACK_PROJECT_CONFIG_FILE ${PROJECT_CPACK_CFG_FILE})
    include(CPack)
  endif()

  #============================================================================
  # If we're configuring only to package source, stop here
  if(PACKAGE_SOURCE_ONLY)
    message(WARNING "Configuration was done in PACKAGE_SOURCE_ONLY mode."
    "You can build a tarball (make package_source), but nothing else.")
    return()
  endif()

  #============================================================================
  # Developer's option to cache PKG_CONFIG_PATH and
  # LD_LIBRARY_PATH for local installs
  if(PKG_CONFIG_PATH)
    set(ENV{PKG_CONFIG_PATH} ${PKG_CONFIG_PATH}:$ENV{PKG_CONFIG_PATH})
  endif()

  if(LD_LIBRARY_PATH)
    set(ENV{LD_LIBRARY_PATH} ${LD_LIBRARY_PATH}:$ENV{LD_LIBRARY_PATH})
  endif()

  #============================================================================
  # Set up installation directories
  set(IGN_INCLUDE_INSTALL_DIR "${CMAKE_INSTALL_INCLUDEDIR}")
  set(IGN_INCLUDE_INSTALL_DIR_POSTFIX "ignition/${IGN_DESIGNATION}${PROJECT_VERSION_MAJOR}")
  set(IGN_INCLUDE_INSTALL_DIR_FULL    "${IGN_INCLUDE_INSTALL_DIR}/${IGN_INCLUDE_INSTALL_DIR_POSTFIX}")
  set(IGN_LIB_INSTALL_DIR ${CMAKE_INSTALL_LIBDIR})
  set(IGN_BIN_INSTALL_DIR ${CMAKE_INSTALL_BINDIR})

  #============================================================================
  # Handle the user's RPATH setting
  option(USE_FULL_RPATH "Turn on to enable the full RPATH" OFF)
  if(USE_FULL_RPATH)
    # use, i.e. don't skip the full RPATH for the build tree
    set(CMAKE_SKIP_BUILD_RPATH FALSE)

    # when building, don't use the install RPATH already
    # (but later on when installing)
    set(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)

    set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/${IGN_LIB_INSTALL_DIR}")

    # add the automatically determined parts of the RPATH
    # which point to directories outside the build tree to the install RPATH
    set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

    # the RPATH to be used when installing, but only if its not a system directory
    list(FIND CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES "${CMAKE_INSTALL_PREFIX}/${IGN_LIB_INSTALL_DIR}" isSystemDir)
    if("${isSystemDir}" STREQUAL "-1")
      set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/${IGN_LIB_INSTALL_DIR}")
    endif("${isSystemDir}" STREQUAL "-1")
  endif()

  #============================================================================
  # Add uninstall target
  configure_file(
    "${IGNITION_CMAKE_DIR}/cmake_uninstall.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
    IMMEDIATE @ONLY)
  add_custom_target(uninstall
    "${CMAKE_COMMAND}" -P
    "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake")

endmacro()

macro(ign_create_packages)

  #============================================================================
  # Configure the typical package configs for this project
  ign_create_pkgconfig()

  #============================================================================
  # Configure the cmake package for this project
  ign_create_cmake_package()

  #============================================================================
  # Load platform-specific build hooks if present.
  ign_load_build_hooks()

  #============================================================================
  # Tell the user what their settings are
  message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
  message(STATUS "Install prefix: ${CMAKE_INSTALL_PREFIX}")

endmacro()


#################################################
# Create a pkgconfig file for your ignition project, and install it.
# ign_create_pkgconfig()
function(ign_create_pkgconfig)

  set(pkgconfig_input "${IGNITION_CMAKE_DIR}/pkgconfig/ignition.pc.in")
  set(pkgconfig_output "${CMAKE_BINARY_DIR}/${PKG_NAME}.pc")
  configure_file(${pkgconfig_input} ${pkgconfig_output} @ONLY)

  install(
    FILES ${pkgconfig_output}
    DESTINATION ${IGN_LIB_INSTALL_DIR}/pkgconfig
    COMPONENT pkgconfig)

endfunction()

#################################################
# Make the cmake config files for this project
function(ign_create_cmake_package)

  # Set configuration arguments
  set(ign_config_input "${IGNITION_CMAKE_DIR}/ignition-config.cmake.in")
  set(ign_config_output "${PROJECT_NAME_LOWER}-config.cmake")
  set(ign_version_output "${PROJECT_NAME_LOWER}-config-version.cmake")
  set(ign_targets_output "${PROJECT_NAME_LOWER}-targets.cmake")
  set(ign_config_install_dir "${IGN_LIB_INSTALL_DIR}/cmake/${PROJECT_NAME_LOWER}")

  # Configure the package config file. It will be installed to
  # "[lib]/cmake/ignition-<project><major_version>/" where [lib] is the library
  # installation directory.
  configure_package_config_file(
    ${ign_config_input}
    ${ign_config_output}
    INSTALL_DESTINATION ${ign_config_install_dir}
    PATH_VARS IGN_LIB_INSTALL_DIR IGN_INCLUDE_INSTALL_DIR_FULL)

  # Use write_basic_package_version_file to generate a ConfigVersion file that
  # allow users of the library to specify the API or version to depend on
  write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/${ign_version_output}
    VERSION "${PROJECT_VERSION_FULL}"
    COMPATIBILITY SameMajorVersion)

  # Install the configuration files to the configuration installation directory
  install(
    FILES
      ${CMAKE_CURRENT_BINARY_DIR}/${ign_config_output}
      ${CMAKE_CURRENT_BINARY_DIR}/${ign_version_output}
    DESTINATION ${ign_config_install_dir}
    COMPONENT cmake)

  # Create *-targets.cmake file for build directory
  export(
    EXPORT ${PROJECT_EXPORT_NAME}
    FILE ${CMAKE_BINARY_DIR}/${ign_targets_output}
    # We add a namespace that ends with a :: to the name of the exported target.
    # This is so consumers of the project can call
    #     find_package(ignition-<project>)
    #     target_link_libraries(consumer_project ignition-<project>::ignition-<project>)
    # and cmake will understand that the consumer is asking to link the imported
    # target "ignition-<project>" to their "consumer_project" rather than asking
    # to link a library named "ignition-<project>". In other words, when
    # target_link_libraries is given a name that contains double-colons (::) it
    # will never mistake it for a library name, and it will throw an error if
    # it cannot find a target with the given name.
    #
    # The advantage of linking against a target rather than a library is that
    # you will automatically link against all the dependencies of that target.
    # This also helps us create find-config files that are relocatable.
    NAMESPACE ${PROJECT_EXPORT_NAME}::)

  # Install *-targets.cmake file
  install(
    EXPORT ${PROJECT_EXPORT_NAME}
    DESTINATION ${ign_config_install_dir}
    FILE ${ign_targets_output}
    # See explanation above for NAMESPACE
    NAMESPACE ${PROJECT_EXPORT_NAME}::)

endfunction()

#################################################
# Make the cmake config files for this project
# Pass an argument to specify the directory where the CMakeLists.txt for the
#   build hooks is located. If no argument is provided, we default to:
#   ${PROJECT_SOURCE_DIR}/packager-hooks
function(ign_load_build_hooks)

  if(ARGV0)
    set(hook_dir ${ARGV0})
  else()
    set(hook_dir "${PROJECT_SOURCE_DIR}/cmake/packager-hooks")
  endif()

  if(EXISTS ${hook_dir}/CMakeLists.txt)
    message(STATUS "Loading packager build hooks from ${hook_dir}")
    add_subdirectory(${hook_dir})
  endif()

endfunction()
