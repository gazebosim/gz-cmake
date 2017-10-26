include(ExternalProject)

# test multiple build types
set(build_types Release RelWithDebInfo Debug)
find_program(EXAMPLE_LCOV_PATH lcov)
if (NOT WIN32 AND EXAMPLE_LCOV_PATH)
  list(APPEND build_types Coverage)
endif()
foreach (build_type ${build_types})
  set(example ign_configure_build)
  set(EXAMPLE_NAME ${example}_${build_type})
  string(TIMESTAMP EXAMPLE_TIME)
  configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/junit_pass.xml.in"
    "${CMAKE_CURRENT_BINARY_DIR}/${EXAMPLE_NAME}_pass.xml"
    @ONLY)
  configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/junit_fail.xml.in"
    "${CMAKE_CURRENT_BINARY_DIR}/test_results/${EXAMPLE_NAME}.xml"
    @ONLY)
  ExternalProject_Add(
    ${EXAMPLE_NAME}

    SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/${example}"
    CMAKE_ARGS
      "-DCMAKE_PREFIX_PATH=${CMAKE_BINARY_DIR}"
      "-DCMAKE_BUILD_TYPE=${build_type}"
    TEST_COMMAND
      ${CMAKE_COMMAND} -E copy
      "${CMAKE_CURRENT_BINARY_DIR}/${EXAMPLE_NAME}_pass.xml"
      "${CMAKE_CURRENT_BINARY_DIR}/test_results/${EXAMPLE_NAME}.xml"
  )
  ExternalProject_Add_Step(
    ${EXAMPLE_NAME} CMakeDepend
    DEPENDS
      "${CMAKE_CURRENT_SOURCE_DIR}/${example}/CMakeLists.txt"
      "${CMAKE_CURRENT_SOURCE_DIR}/${example}/doc/CMakeLists.txt"
      "${CMAKE_CURRENT_SOURCE_DIR}/${example}/include/CMakeLists.txt"
      "${CMAKE_CURRENT_SOURCE_DIR}/${example}/src/CMakeLists.txt"
      "${CMAKE_CURRENT_SOURCE_DIR}/${example}/test/CMakeLists.txt"
    DEPENDERS
      configure
  )
  add_test(
    ${EXAMPLE_NAME}
    ${CMAKE_COMMAND} -E copy
    "${CMAKE_CURRENT_BINARY_DIR}/test_results/${EXAMPLE_NAME}.xml"
    "${CMAKE_BINARY_DIR}/test_results/${EXAMPLE_NAME}.xml"
  )
endforeach()
