if (UNIX)
  add_test(cmake_minimum_required_match
    bash
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake_minimum_required.bash
    ${CMAKE_SOURCE_DIR}
    --xml_output_dir
    ${CMAKE_BINARY_DIR}/test_results
  )
endif()
