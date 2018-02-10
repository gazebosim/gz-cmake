if (UNIX)
  add_test(cmake_minimum_required_match
    bash
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake_minimum_required.bash
    ${CMAKE_SOURCE_DIR}
    --xml_output_dir
    ${CMAKE_BINARY_DIR}/test_results
  )
endif()

include_directories(
  ${PROJECT_SOURCE_DIR}/test/gtest/include
  ${PROJECT_SOURCE_DIR}/test/gtest
  ${PROJECT_SOURCE_DIR}/test
)

if(NOT MSVC)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
endif()

# Build gtest
add_library(gtest STATIC gtest/src/gtest-all.cc)
add_library(gtest_main STATIC gtest/src/gtest_main.cc)
target_link_libraries(gtest_main gtest)
set(GTEST_LIBRARY "${PROJECT_BINARY_DIR}/test/libgtest.a")
set(GTEST_MAIN_LIBRARY "${PROJECT_BINARY_DIR}/test/libgtest_main.a")

add_subdirectory(pimpl)
add_subdirectory(unit)
add_subdirectory(warnings)
