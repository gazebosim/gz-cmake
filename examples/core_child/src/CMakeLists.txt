gz_get_libsources_and_unittests(sources gtest_sources)
gz_create_core_library(SOURCES ${sources} CXX_STANDARD 11)
target_link_libraries(${PROJECT_LIBRARY_TARGET_NAME}
  PUBLIC
    ignition-core_no_deps::ignition-core_no_deps)
gz_build_tests(TYPE UNIT SOURCES ${gtest_sources})
