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
#
# NOTE: This macro assumes that pkgconfig is the only means by which you will be
#       searching for the package. If you intend to continue searching in the
#       event that pkgconfig fails (or is unavailable), then you should instead
#       call ign_pkg_check_modules_quiet(~).
macro(ign_pkg_check_modules package)

  ign_pkg_check_modules_quiet(${package} ${ARGN})

  if(NOT PKG_CONFIG_FOUND)
    status(WARNING "The package [${package}] requires pkg-config in order to be found. "
                   "Please install pkg-config so we can search for that package.")
  endif()

  include(FindPackageHandleStandardArgs)
  find_package_handle_standard_args(
    ${package}
    REQUIRED_VARS ${package}_FOUND)

endmacro()

# This is an alternative to ign_pkg_check_modules(~) which you can use if you
# have an alternative way to look for the package if pkgconfig is not available
# or cannot find the requested package. This will still setup the pkgconfig
# variables for you, whether or not pkgconfig is available.
macro(ign_pkg_check_modules_quiet package)

  find_package(PkgConfig QUIET)

  set(${package}_PKGCONFIG_ENTRY "${ARGN}")
  set(${package}_PKGCONFIG_TYPE PROJECT_PKGCONFIG_REQUIRES)

  if(PKG_CONFIG_FOUND)

    pkg_check_modules(${package} ${ARGN})

    # TODO: When we require cmake-3.6+, we should remove this procedure and just
    #       use the plain pkg_check_modules, which provides an option called
    #       IMPORTED_TARGET that will create the imported targets the way we do
    #       here.
    if(${package}_FOUND AND NOT TARGET ${package}::${package})

      # pkg_check_modules will put ${package}_FOUND into the CACHE, which would
      # prevent our FindXXX.cmake script from being entered the next time cmake
      # is run by a dependent project. This is a problem for us because we
      # produce an imported target which gets wiped out and needs to recreated
      # between runs.
      #
      # TODO: Investigate if there is a more conventional solution to this
      # problem. Perhaps the cmake-3.6 version of pkg_check_modules has a
      # better solution.
      unset(${package}_FOUND CACHE)
      set(${package}_FOUND true)

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
