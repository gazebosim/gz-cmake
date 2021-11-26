ign_get_libsources_and_unittests(sources gtest_sources)
ign_create_core_library(SOURCES ${sources} CXX_STANDARD 11)
ign_build_tests(TYPE UNIT SOURCES ${gtest_sources})
