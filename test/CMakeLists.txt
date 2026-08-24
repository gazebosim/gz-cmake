if (UNIX)
  add_test(cmake_minimum_required_match
    bash
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake_minimum_required.bash
    ${CMAKE_SOURCE_DIR}
    --xml_output_dir
    ${CMAKE_BINARY_DIR}/test_results
  )
endif()

add_test(
  NAME configure_build_errors
  COMMAND
    "${CMAKE_COMMAND}"
    "-DGZ_CMAKE_MODULE_DIR=${CMAKE_SOURCE_DIR}/cmake"
    -P "${CMAKE_CURRENT_SOURCE_DIR}/configure_build_errors.cmake"
)

# This test requires the use of std::filesystem, so it is only compiled on non-GCC
# compilers of with GCC >= 11
if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 11.0)
  add_subdirectory(get_install_prefix)
endif()
