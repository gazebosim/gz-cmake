cmake_minimum_required(VERSION 3.5.1 FATAL_ERROR)

#============================================================================
# Initialize the project
#============================================================================
project(ignition-cmake1 VERSION 1.0.0)

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
ign_configure_project(VERSION_SUFFIX pre2)

#--------------------------------------
# Install the ignition documentation files
# Note: This is not actually creating a doc target for ign-cmake; this is just
# installing files that are useful for generating the documentation of other
# ignition projects.
ign_create_docs()

#============================================================================
# Configure the package to be installed
#============================================================================

#--------------------------------------
# Create configuration and installation variables
set(ign_config_input  "${CMAKE_CURRENT_SOURCE_DIR}/config/ignition-cmake-config.cmake.in")
set(ign_config_output "${PROJECT_NAME_LOWER}-config.cmake")
set(ign_version_output "${PROJECT_NAME_LOWER}-config-version.cmake")
set(ign_config_install_dir "${CMAKE_INSTALL_DATAROOTDIR}/cmake/${PROJECT_NAME_LOWER}")

#--------------------------------------
# Configure and install the config file
configure_package_config_file(
  ${ign_config_input}
  ${ign_config_output}
  INSTALL_DESTINATION ${ign_config_install_dir}
  PATH_VARS IGN_DATA_INSTALL_DIR
  NO_CHECK_REQUIRED_COMPONENTS_MACRO)

#--------------------------------------
# Configure and install the version file
write_basic_package_version_file(
  ${CMAKE_CURRENT_BINARY_DIR}/${ign_version_output}
  VERSION "${PROJECT_VERSION_FULL_NO_SUFFIX}"
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
  # Do a fake install of ign-cmake in order to test the examples.
  # Copy or symlink the config.cmake files and cmake folder
  set(FAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install/fake")
  set(FAKE_CMAKE_INSTALL_DIR "${FAKE_INSTALL_PREFIX}/${ign_config_install_dir}")
  set(FAKE_DATA_INSTALL_DIR "${FAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_DATAROOTDIR}/${IGN_DATA_INSTALL_DIR_POSTFIX}")
  if (UNIX)
    # make symlinks on unix
    execute_process(
      COMMAND
        ${CMAKE_COMMAND} -E make_directory ${FAKE_CMAKE_INSTALL_DIR} ${FAKE_DATA_INSTALL_DIR})
    execute_process(
      COMMAND
        ${CMAKE_COMMAND} -E create_symlink ${CMAKE_BINARY_DIR}/${ign_config_output} ${FAKE_CMAKE_INSTALL_DIR}/${ign_config_output})
    execute_process(
      COMMAND
        ${CMAKE_COMMAND} -E create_symlink ${CMAKE_BINARY_DIR}/${ign_version_output} ${FAKE_CMAKE_INSTALL_DIR}/${ign_version_output})
    execute_process(
      COMMAND
        ${CMAKE_COMMAND} -E create_symlink ${CMAKE_SOURCE_DIR}/cmake ${FAKE_CMAKE_INSTALL_DIR}/cmake${PROJECT_VERSION_MAJOR})
    execute_process(
      COMMAND
        ${CMAKE_COMMAND} -E create_symlink ${CMAKE_SOURCE_DIR}/doc/doxygen ${FAKE_DATA_INSTALL_DIR}/doxygen)
  else()
    # otherwise copy the files one by one
    # use configure_file(... COPYONLY) since it will run again if files change
    configure_file(${CMAKE_BINARY_DIR}/${ign_config_output} ${FAKE_CMAKE_INSTALL_DIR}/${ign_config_output} COPYONLY)
    configure_file(${CMAKE_BINARY_DIR}/${ign_version_output} ${FAKE_CMAKE_INSTALL_DIR}/${ign_version_output} COPYONLY)
    foreach (filename ${modules} ${templates})
      get_filename_component(file ${filename} NAME)
      configure_file(${filename} ${FAKE_CMAKE_INSTALL_DIR}/cmake${PROJECT_VERSION_MAJOR}/${file} COPYONLY)
    endforeach()
    foreach (filename ${pkgconfig_templates})
      get_filename_component(file ${filename} NAME)
      configure_file(${filename} ${FAKE_CMAKE_INSTALL_DIR}/cmake${PROJECT_VERSION_MAJOR}/pkgconfig/${file} COPYONLY)
    endforeach()
    file(GLOB doc_doxygen "doc/doxygen/*")
    foreach (filename ${doc_doxygen})
      get_filename_component(file ${filename} NAME)
      configure_file(${filename} ${FAKE_DATA_INSTALL_DIR}/doxygen/${file} COPYONLY)
    endforeach()
  endif()
  add_subdirectory(examples)
endif()
