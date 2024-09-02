gz_get_libsources_and_unittests(sources gtest_sources)
gz_create_core_library(SOURCES ${sources} CXX_STANDARD 11)
target_link_libraries(${PROJECT_LIBRARY_TARGET_NAME}
  PUBLIC
    gz-use_component_deps_c::gz-use_component_deps_c)
gz_build_tests(TYPE UNIT SOURCES ${gtest_sources})
