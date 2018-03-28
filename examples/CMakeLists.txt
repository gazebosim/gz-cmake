include(ExternalProject)

# test multiple build types
set(build_types Release RelWithDebInfo Debug)
find_program(EXAMPLE_LCOV_PATH lcov)
if (NOT WIN32 AND EXAMPLE_LCOV_PATH)
  list(APPEND build_types Coverage)
endif()

set(example_directories ign_configure_build prerelease)

foreach(example ${example_directories})
  if (${example} STREQUAL "ign_configure_build")
    set(example_tarball_name ignition-minimal-0.1.0.tar.bz2)
  elseif (${example} STREQUAL "prerelease")
    set(example_tarball_name ignition-minimal-0.1.0~pre1.tar.bz2)
  endif()

  foreach (build_type ${build_types})
    set(TEST_NAME ${example}_${build_type})
    string(TIMESTAMP TEST_TIME)
    configure_file(
      "${CMAKE_CURRENT_SOURCE_DIR}/junit_pass.xml.in"
      "${CMAKE_CURRENT_BINARY_DIR}/${TEST_NAME}_pass.xml"
      @ONLY)
    configure_file(
      "${CMAKE_CURRENT_SOURCE_DIR}/junit_fail.xml.in"
      "${CMAKE_CURRENT_BINARY_DIR}/test_results/${TEST_NAME}.xml"
      @ONLY)
    ExternalProject_Add(
      ${TEST_NAME}

      SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/${example}"
      # BUILD_ALWAYS needed since cmake doesn't notice when
      # example files change.
      # See alternate approach in a2113e0997c9 if this becomes too slow
      BUILD_ALWAYS 1
      CMAKE_ARGS
        "-DCMAKE_PREFIX_PATH=${CMAKE_BINARY_DIR}"
        "-DCMAKE_BUILD_TYPE=${build_type}"
      TEST_COMMAND
        ${CMAKE_COMMAND} -E copy
        "${CMAKE_CURRENT_BINARY_DIR}/${TEST_NAME}_pass.xml"
        "${CMAKE_CURRENT_BINARY_DIR}/test_results/${TEST_NAME}.xml"

      # We explicitly disable the install command to ensure that the examples
      # do not get installed, and also because some strange behavior on Windows
      # causes the tests to require administrative privileges to build when this
      # option is left unset.
      INSTALL_COMMAND ""
    )
    if (CPACK_GENERATOR)
      ExternalProject_Add_Step(
        ${TEST_NAME}
        package_source
        COMMAND
          ${CMAKE_COMMAND} --build <BINARY_DIR> --target package_source
        DEPENDEES
          configure
      )
      ExternalProject_Add_Step(
        ${TEST_NAME}
        test_tarball_name
        COMMAND
          ${CMAKE_COMMAND} -E tar tf <BINARY_DIR>/${example_tarball_name}
        DEPENDEES
          package_source
        DEPENDERS
          test
      )
    endif()
    add_test(
      ${TEST_NAME}
      ${CMAKE_COMMAND} -E copy
      "${CMAKE_CURRENT_BINARY_DIR}/test_results/${TEST_NAME}.xml"
      "${CMAKE_BINARY_DIR}/test_results/${TEST_NAME}.xml"
    )
  endforeach()

endforeach()
