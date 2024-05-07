cmake_minimum_required(VERSION 3.10.2 FATAL_ERROR)

#============================================================================
# Initialize the project
#============================================================================
project(ignition-cmake2 VERSION 2.17.2)

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
ign_configure_project(
  REPLACE_IGNITION_INCLUDE_PATH gz/cmake
  VERSION_SUFFIX
)

#--------------------------------------
# Set project-specific options
option(BUILDSYSTEM_TESTING "Enable extended buildsystem testing" FALSE)

#--------------------------------------
# Install the ignition documentation files
# Note: This is not actually creating a doc target for ign-cmake; this is just
# installing files that are useful for generating the documentation of other
# ignition projects.
add_subdirectory(doc)

#--------------------------------------
# Install the benchmark files
install(DIRECTORY benchmark/
        DESTINATION ${IGN_DATA_INSTALL_DIR}/benchmark)

#--------------------------------------
# Install the codecheck files
install(DIRECTORY codecheck/
        DESTINATION ${IGN_DATA_INSTALL_DIR}/codecheck)

#--------------------------------------
# Install the tools files
install(DIRECTORY tools/
        DESTINATION ${IGN_DATA_INSTALL_DIR}/tools)

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
set(ign_pkgconfig_install_dir "${CMAKE_INSTALL_FULL_LIBDIR}/pkgconfig")
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
file(RELATIVE_PATH
  IGN_PC_CONFIG_RELATIVE_PATH_TO_PREFIX
  "${ign_pkgconfig_install_dir}"
  "${CMAKE_INSTALL_PREFIX}"
)

# TODO(jrivero): CMake 3.20 provides cmake_path(APPEND) which implements the
# same functionality as join_paths(). Remove JoinPaths in the next major version
# if all the supported platforms are in 3.20 version.
include(JoinPaths)
join_paths(IGN_PC_LIBDIR "\${prefix}" "${CMAKE_INSTALL_LIBDIR}")
join_paths(IGN_PC_INCLUDEDIR "\${prefix}" "${CMAKE_INSTALL_INCLUDEDIR}" "${IGN_INCLUDE_INSTALL_DIR_POSTFIX}")

configure_file(${ign_pkgconfig_input} ${ign_pkgconfig_output} @ONLY)

install(
  FILES ${ign_pkgconfig_output}
  DESTINATION ${ign_pkgconfig_install_dir}
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
endif()

if (BUILD_TESTING AND BUILDSYSTEM_TESTING)
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

# Codecheck
set(CPPCHECK_DIRS
  ${CMAKE_SOURCE_DIR}/examples
)
set(CPPCHECK_INCLUDE_DIRS
  ${CMAKE_SOURCE_DIR}/include
  ${CMAKE_SOURCE_DIR}/examples
)
set(IGNITION_CMAKE_CODECHECK_DIR "${CMAKE_CURRENT_SOURCE_DIR}/codecheck")
include(IgnCodeCheck)
ign_setup_target_for_codecheck()

# Docs
set(IGNITION_CMAKE_DOXYGEN_DIR "${CMAKE_CURRENT_SOURCE_DIR}/doc/doxygen")
configure_file(${CMAKE_SOURCE_DIR}/api.md.in ${CMAKE_BINARY_DIR}/api.md)
configure_file(${CMAKE_SOURCE_DIR}/tutorials.md.in ${CMAKE_BINARY_DIR}/tutorials.md)
ign_create_docs(
  API_MAINPAGE_MD "${CMAKE_BINARY_DIR}/api.md"
  TUTORIALS_MAINPAGE_MD "${CMAKE_BINARY_DIR}/tutorials.md"
  )
