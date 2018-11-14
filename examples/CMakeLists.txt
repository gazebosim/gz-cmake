include(ExternalProject)

# test multiple build types
set(build_types Release RelWithDebInfo Debug)
find_program(EXAMPLE_LCOV_PATH lcov)
if (NOT WIN32 AND EXAMPLE_LCOV_PATH)
  list(APPEND build_types Coverage)
endif()

set(example_directories
  ign_configure_build
  prerelease
  core_no_deps
  core_child
  )

# test to see if we have programs necessary to run codecheck
include(IgnCodeCheck)
ign_setup_target_for_codecheck()

foreach(example ${example_directories})
  set(run_codecheck false)
  if (${example} STREQUAL "ign_configure_build")
    set(example_tarball_name ignition-minimal-0.1.0.tar.bz2)
  elseif (${example} STREQUAL "prerelease")
    set(example_tarball_name ignition-minimal-1.0.0~pre1.tar.bz2)
  elseif (${example} STREQUAL "core_no_deps")
    set(example_tarball_name ignition-core_no_deps-0.1.0.tar.bz2)
    set(run_codecheck true)
  elseif (${example} STREQUAL "core_child")
    set(example_tarball_name ignition-core_child-0.1.0.tar.bz2)
    set(run_codecheck true)
  else()
    set(example_tarball_name)
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
    set(example_INSTALL_DIR ${CMAKE_BINARY_DIR}/install/${build_type})
    ExternalProject_Add(
      ${TEST_NAME}

      DEPENDS FAKE_INSTALL
      SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/${example}"
      # BUILD_ALWAYS needed since cmake doesn't notice when
      # example files change.
      # See alternate approach in a2113e0997c9 if this becomes too slow
      BUILD_ALWAYS 1
      CMAKE_ARGS
        "-DCMAKE_PREFIX_PATH=${FAKE_INSTALL_PREFIX};${example_INSTALL_DIR}"
        "-DCMAKE_BUILD_TYPE=${build_type}"
        "-DCMAKE_INSTALL_PREFIX=${example_INSTALL_DIR}"
      TEST_COMMAND
        ${CMAKE_COMMAND} -E copy
        "${CMAKE_CURRENT_BINARY_DIR}/${TEST_NAME}_pass.xml"
        "${CMAKE_CURRENT_BINARY_DIR}/test_results/${TEST_NAME}.xml"
    )
    if (${run_codecheck} AND TARGET codecheck)
      ExternalProject_Add_Step(
        ${TEST_NAME}
        codecheck
        COMMAND
          ${CMAKE_COMMAND} --build <BINARY_DIR> --target codecheck
        DEPENDEES
          configure
      )
    endif()
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

# dependencies between external projects
# hard to use DEPENDS in ExternalProject_Add because targets
# need to exist before they can be used there
foreach (build_type ${build_types})
  add_dependencies(core_child_${build_type} core_no_deps_${build_type})
endforeach()

# test that core_child pkg-config file requires core_no_deps
if (UNIX)
  set(TEST_NAME core_child_requires_core_no_deps)
  string(TIMESTAMP TEST_TIME)
  configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/junit_pass.xml.in"
    "${CMAKE_CURRENT_BINARY_DIR}/${TEST_NAME}_pass.xml"
    @ONLY)
  configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/junit_fail.xml.in"
    "${CMAKE_CURRENT_BINARY_DIR}/${TEST_NAME}_fail.xml"
    @ONLY)
  set(_env_vars)
  list(APPEND _env_vars "PKG_CONFIG_PATH=${example_INSTALL_DIR}/lib/pkgconfig:${FAKE_INSTALL_PREFIX}/lib/pkgconfig:$PKG_CONFIG_PATH")
  add_test(${TEST_NAME}
    ${CMAKE_CURRENT_SOURCE_DIR}/test_core_child_requires_core_no_deps.bash
  )
  set_tests_properties(${TEST_NAME} PROPERTIES
    ENVIRONMENT "${_env_vars}")
endif()
