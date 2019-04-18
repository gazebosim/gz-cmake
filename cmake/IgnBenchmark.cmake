function(ign_add_version_info_target)

  # generate a version_info.json file that can be used to embed project
  # version information
  # While this command may look a bit unweildy, it creates a target
  # that forces the file to be regenerated at build time.

  add_custom_target(version_info_target
    COMMAND ${CMAKE_COMMAND}
      -Dinput_file=${IGNITION_CMAKE_DIR}/version_info.json.in
      -Doutput_file=${PROJECT_BINARY_DIR}/version_info.json
      -Drepository_root=${CMAKE_CURRENT_SOURCE_DIR}
      -Dbuild_type=${CMAKE_BUILD_TYPE}
      -Dversion=${PROJECT_VERSION}
      -Dversion_full=${PROJECT_VERSION_FULL}
      -Dmajor=${PROJECT_VERSION_MAJOR}
      -Dminor=${PROJECT_VERSION_MINOR}
      -Dpatch=${PROJECT_VERSION_PATCH}
      -Dproject_name=${PROJECT_NAME}
      -P ${IGNITION_CMAKE_DIR}/IgnGenerateVersionInfo.cmake
  )

endfunction()

