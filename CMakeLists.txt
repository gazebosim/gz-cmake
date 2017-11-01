cmake_minimum_required(VERSION 3.5.1 FATAL_ERROR)

#============================================================================
# Initialize the project
#============================================================================

#--------------------------------------
# Initialize the IGNITION_CMAKE_DIR variable with the location of the cmake
# directory that sits next to this find-module.
set(IGNITION_CMAKE_DIR "${CMAKE_CURRENT_LIST_DIR}/cmake")

#--------------------------------------
# Add the location of this package's cmake directory to the CMAKE_MODULE_PATH
list(APPEND CMAKE_MODULE_PATH "${IGNITION_CMAKE_DIR}")

#--------------------------------------
# include the master IgnCMake module
include(IgnCMake)

#--------------------------------------
# Set up the project
ign_configure_project(cmake 0.1.1)

#============================================================================
# Configure the package to be installed
#============================================================================

#--------------------------------------
# Create configuration and installation variables
set(ign_config_input  "${CMAKE_CURRENT_SOURCE_DIR}/config/ignition-cmake-config.cmake.in")
set(ign_config_output "${PROJECT_NAME_LOWER}-config.cmake")
set(ign_version_output "${PROJECT_NAME_LOWER}-config-version.cmake")
set(ign_config_install_dir "${IGN_LIB_INSTALL_DIR}/cmake/${PROJECT_NAME_LOWER}")

#--------------------------------------
# Configure and install the config file
configure_package_config_file(
  ${ign_config_input}
  ${ign_config_output}
  INSTALL_DESTINATION ${ign_config_install_dir}
  NO_CHECK_REQUIRED_COMPONENTS_MACRO)

#--------------------------------------
# Configure and install the version file
write_basic_package_version_file(
  ${CMAKE_CURRENT_BINARY_DIR}/${ign_version_output}
  VERSION "${PROJECT_VERSION_FULL}"
  COMPATIBILITY SameMajorVersion)

install(
  FILES
    ${CMAKE_CURRENT_BINARY_DIR}/${ign_config_output}
    ${CMAKE_CURRENT_BINARY_DIR}/${ign_version_output}
  DESTINATION ${ign_config_install_dir}
  COMPONENT cmake)


#============================================================================
# Install the files for this package
#============================================================================
set(ign_modules_install_dir "${ign_config_install_dir}/cmake${PROJECT_VERSION_MAJOR}")

file(GLOB modules "cmake/*.cmake")
file(GLOB templates "cmake/*.in")

install(
  FILES ${modules} ${templates}
  DESTINATION ${ign_modules_install_dir}
  COMPONENT modules)

file(GLOB pkgconfig_templates "cmake/pkgconfig/*.in")

install(
  FILES ${pkgconfig_templates}
  DESTINATION ${ign_modules_install_dir}/pkgconfig
  COMPONENT modules)

message(STATUS "Install prefix: ${CMAKE_INSTALL_PREFIX}")

include(CTest)
if (BUILD_TESTING)
  add_subdirectory(test)

  #============================================================================
  # Build examples
  #============================================================================
  # find_package expects cmakeN (e.g. cmake0, cmake1, ... depending on the major version of ign-cmake)
  # to be in the build folder because that is where the ignition-cmake-config.cmake file is located
  # before it is installed
  if (UNIX)
    # make a symlink on unix
    execute_process(
      COMMAND
        ${CMAKE_COMMAND} -E create_symlink ${CMAKE_SOURCE_DIR}/cmake ${CMAKE_BINARY_DIR}/cmake${PROJECT_VERSION_MAJOR})
  else()
    # otherwise copy the files one by one
    # use configure_file(... COPYONLY) since it will run again if files change
    foreach (filename ${modules} ${templates})
      get_filename_component(file ${filename} NAME)
      configure_file(${filename} ${CMAKE_BINARY_DIR}/cmake${PROJECT_VERSION_MAJOR}/${file} COPYONLY)
    endforeach()
    foreach (filename ${pkgconfig_templates})
      get_filename_component(file ${filename} NAME)
      configure_file(${filename} ${CMAKE_BINARY_DIR}/cmake${PROJECT_VERSION_MAJOR}/pkgconfig/${file} COPYONLY)
    endforeach()
  endif()
  add_subdirectory(examples)
endif()
