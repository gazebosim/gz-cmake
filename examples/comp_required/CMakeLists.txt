cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(gz-comp_required VERSION 0.1.0)
find_package(gz-cmake REQUIRED)
gz_configure_project()

# The missing_dep component depends on a package that does not exist, so
# gz_find_package always marks it to be skipped.
gz_find_package(GzCMakeTestMissingPackage QUIET
  REQUIRED_BY missing_dep)

# The manual_skip component is always skipped by the project itself: it sets
# INTERNAL_SKIP_manual_skip and leaves the component out of the COMPONENTS
# list, as gz-rendering does for render engines that cannot be built.
set(INTERNAL_SKIP_manual_skip true)

gz_configure_build(QUIT_IF_BUILD_ERRORS
  COMPONENTS present missing_dep)
