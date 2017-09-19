#===============================================================================
# Copyright (C) 2017 Open Source Robotics Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
########################################
# An alternative to pkg_check_modules that creates an "imported target" which
# helps us to make relocatable packages.
# TODO: When we require cmake-3.6+, we should remove this function and just use
#       the standard pkg_check_modules, which provides an option called
#       IMPORTED_TARGET that will create the imported targets the way we do here
#
macro(ign_pkg_check_modules package)

  ign_pkg_check_modules_quiet(${package} ${ARGN})

  include(FindPackageHandleStandardArgs)
  find_package_handle_standard_args(
    ${package}
    REQUIRED_VARS ${package}_FOUND)

endmacro()

macro(ign_pkg_check_modules_quiet package)

  find_package(PkgConfig QUIET)
  pkg_check_modules(${package} ${ARGN})

  if(${package}_FOUND AND NOT TARGET ${package}::${package})

    # For some reason, pkg_check_modules does not provide complete paths to the
    # libraries it returns, even though find_package is conventionally supposed
    # to provide complete library paths. Having only the library name is harmful
    # to the ign_create_imported_target macro, so we will change the variable to
    # give it complete paths.
    #
    # TODO: How would we deal with multiple modules that are in different
    # directories? How does cmake-3.6+ handle that situation?
    _ign_pkgconfig_find_libraries(
      ${package}_LIBRARIES
      ${package}
      "${${package}_LIBRARIES}"
      "${${package}_LIBRARY_DIRS}")

    include(IgnImportTarget)
    ign_import_target(${package})

  endif()

endmacro()

# Based on discussion here: https://cmake.org/Bug/view.php?id=15804
# and a patch written by Sam Thursfield
function(_ign_pkgconfig_find_libraries output_var package library_names library_dirs)

  foreach(libname ${library_names})

    find_library(
      ${package}_LIBRARY_${libname}
      ${libname}
      PATHS ${library_dirs})

    list(APPEND library_paths "${${package}_LIBRARY_${libname}}")

  endforeach()

  set(${output_var} ${library_paths} PARENT_SCOPE)

endfunction()
