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
# Find FreeImage

# Grab the version numbers requested by the call to find_package(~)
set(major_version ${FreeImage_FIND_VERSION_MAJOR})
set(minor_version ${FreeImage_FIND_VERSION_MINOR})

# Set the full version number
set(full_version ${major_version}.${minor_version})

include(IgnPkgConfig)
ign_pkg_check_modules_quiet(FreeImage FreeImage>=${full_version})

# If we don't have PkgConfig, or if PkgConfig failed, then do a manual search
if(NOT FreeImage_FOUND)
  message(STATUS "FreeImage.pc not found, we will search for "
                 "FreeImage_INCLUDE_DIRS and FreeImage_LIBRARIES")

  find_path(FreeImage_INCLUDE_DIRS FreeImage.h)
  if(NOT FreeImage_INCLUDE_DIRS)
    message(STATUS "Looking for FreeImage.h - not found")
    message(STATUS "Missing: Unable to find FreeImage.h")
  else(NOT FreeImage_INCLUDE_DIRS)
    # Check the FreeImage header for the right version
    set(testFreeImageSource ${CMAKE_CURRENT_BINARY_DIR}/CMakeTmp/test_freeimage.cc)
    set(FreeImage_test_output "")
    set(FreeImage_compile_output "")
    file(WRITE ${testFreeImageSource}
      "#include <FreeImage.h>\nint main () { if (FREEIMAGE_MAJOR_VERSION >= ${major_version} && FREEIMAGE_MINOR_VERSION >= ${minor_version}) return 1; else return 0;} \n")

    try_run(FREEIMAGE_RUNS
            FREEIMAGE_COMPILES
            ${CMAKE_CURRENT_BINARY_DIR}
            ${testFreeImageSource}
            CMAKE_FLAGS -DINCLUDE_DIRECTORIES=${FreeImage_INCLUDE_DIRS}
            RUN_OUTPUT_VARIABLE FreeImage_test_output
            COMPILE_OUTPUT_VARIABLE FreeImage_compile_output)

    if(NOT FREEIMAGE_COMPILES)
      message(STATUS "FreeImage test failed to compile - This may indicate a build system bug")
      return()
    endif(NOT FREEIMAGE_COMPILES)

    if(NOT FREEIMAGE_RUNS)
      message(STATUS "Invalid FreeImage Version. Requires ${major_version}.${minor_version}")
    endif(NOT FREEIMAGE_RUNS)
  endif(NOT FreeImage_INCLUDE_DIRS)

  find_library(FreeImage_LIBRARIES freeimage)
  if(FreeImage_LIBRARIES)
    set(FreeImage_FOUND true)
  else()
    set("Looking for libfreeimage - not found")
    message(STATUS "Missing: Unable to find libfreeimage")
  endif(FreeImage_LIBRARIES)

  if(FreeImage_FOUND)
    # Create the imported target for FreeImage if we found it
    include(IgnImportTarget)
    ign_import_target(FreeImage)
  endif()

endif()
