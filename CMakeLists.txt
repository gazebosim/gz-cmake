cmake_minimum_required(VERSION 3.10.2 FATAL_ERROR)

#============================================================================
# Initialize the project
#============================================================================
project(ignition-cmake2 VERSION 2.0.0)

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
ign_configure_project(VERSION_SUFFIX gz11~v1)

#--------------------------------------
# Install the ignition documentation files
# Note: This is not actually creating a doc target for ign-cmake; this is just
# installing files that are useful for generating the documentation of other
# ignition projects.
add_subdirectory(doc)

#--------------------------------------
# Install the codecheck files
install(DIRECTORY codecheck/
        DESTINATION ${IGN_DATA_INSTALL_DIR}/codecheck)

#============================================================================
# Configure the package to be installed
#============================================================================

#--------------------------------------
# Create configuration and installation variables
set(ign_config_input  "${CMAKE_CURRENT_SOURCE_DIR}/config/ignition-cmake-config.cmake.in")
set(ign_config_output "${PROJECT_NAME_LOWER}-config.cmake")
set(ign_version_output "${PROJECT_NAME_LOWER}-config-version.cmake")
set(ign_config_install_dir "${CMAKE_INSTALL_DATAROOTDIR}/cmake/${PROJECT_NAME_LOWER}")
set(ign_pkgconfig_input "${CMAKE_CURRENT_SOURCE_DIR}/config/ignition-cmake.pc.in")
set(ign_pkgconfig_output "${CMAKE_BINARY_DIR}/ignition-cmake${PROJECT_VERSION_MAJOR}.pc")
set(ign_utilities_target ${PROJECT_EXPORT_NAME}-utilities)
set(ign_utilities_import_target_name ${PROJECT_EXPORT_NAME}::${ign_utilities_target})
set(ign_utilities_target_output_filename "${ign_utilities_target}-targets.cmake")
set(simple_utilities_import_name ${PROJECT_EXPORT_NAME}::utilities)

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

#--------------------------------------
# Configure and install the pkgconfig file (needed for utilities headers)
configure_file(${ign_pkgconfig_input} ${ign_pkgconfig_output} @ONLY)

install(
  FILES ${ign_pkgconfig_output}
  DESTINATION ${IGN_LIB_INSTALL_DIR}/pkgconfig
  COMPONENT pkgconfig)

#============================================================================
# Create and install the utilities component
#============================================================================
add_library(${ign_utilities_target} INTERFACE)
target_include_directories(${ign_utilities_target}
  INTERFACE
    $<INSTALL_INTERFACE:${IGN_INCLUDE_INSTALL_DIR_FULL}>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>)

# Export and install the interface target
install(
  TARGETS ${ign_utilities_target}
  EXPORT ${ign_utilities_target}
  COMPONENT interface)

export(
  EXPORT ${ign_utilities_target}
  FILE ${ign_utilities_target_output_filename}
  NAMESPACE ${PROJECT_EXPORT_NAME}::)

install(
  EXPORT ${ign_utilities_target}
  DESTINATION ${ign_config_install_dir}
  FILE ${ign_utilities_target_output_filename}
  NAMESPACE ${PROJECT_EXPORT_NAME}::)

# Install the header directory
# Note: The trailing slash after "include" is necessary
install(
  DIRECTORY include/
  DESTINATION ${IGN_INCLUDE_INSTALL_DIR_FULL}
  COMPONENT headers)

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
  set(FAKE_BUILD_DIRECTORY "${CMAKE_BINARY_DIR}/fake/build")
  set(FAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/fake/install")

  file(MAKE_DIRECTORY ${FAKE_BUILD_DIRECTORY})
  file(MAKE_DIRECTORY ${FAKE_INSTALL_PREFIX})

  include(ExternalProject)
  ExternalProject_Add(
    FAKE_INSTALL

    SOURCE_DIR "${CMAKE_SOURCE_DIR}"
    # BUILD_ALWAYS needed since cmake doesn't notice when
    # example files change.
    # See alternate approach in a2113e0997c9 if this becomes too slow
    BUILD_ALWAYS 1
    CMAKE_ARGS
      "-DBUILD_TESTING=OFF"
      "-DCMAKE_INSTALL_PREFIX=${FAKE_INSTALL_PREFIX}"
  )

  add_subdirectory(examples)
endif()
