
# This hack allows us to easily build tests against the utilities library.
# Tests are automatically linked against PROJECT_LIBRARY_TARGET_NAME, but in
# this case that would be ignition-cmake# when we really want it to be
# ignition-cmake#-utilities.
#
# TODO: Consider a less hamfisted way of handling this.
set(PROJECT_LIBRARY_TARGET_NAME ${PROJECT_EXPORT_NAME}-utilities)

ign_get_sources(tests)

ign_build_tests(
  TYPE UNIT
  SOURCES ${tests})

if(TARGET UNIT_ImplPtr_TEST)
  target_link_libraries(UNIT_ImplPtr_TEST pimpl)
endif()
