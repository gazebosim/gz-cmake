ign_get_libsources_and_unittests(sources gtest_sources)
ign_create_core_library(SOURCES ${sources} CXX_STANDARD 11)
target_link_libraries(${PROJECT_LIBRARY_TARGET_NAME}
  PUBLIC
    ignition-component_deps::ignition-component_deps-child)
ign_build_tests(TYPE UNIT SOURCES ${gtest_sources})
