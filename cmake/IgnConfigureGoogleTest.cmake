#.rst
# IgnConfigureGoogleTest
# -------------------
#
# ign_configure_googletest
#
# Downloads and sets up Google Test for an Ignition library project.
#
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

#################################################
# Downloads and sets up Google Test
macro(ign_configure_googletest)

  set(google_test_in ${IGNITION_CMAKE_DIR}/googletest.txt.in)
  set(google_test_out ${CMAKE_BINARY_DIR}/googletest-download/CMakeLists.txt)

  # Generate the "CMakeLists.txt" that downloads Google Test
  configure_file(${google_test_in} ${google_test_out})

  # Download and unpack googletest at configure time
  execute_process(COMMAND ${CMAKE_COMMAND} -Wno-dev -G "${CMAKE_GENERATOR}" .
    RESULT_VARIABLE result
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/googletest-download )
  if(result)
    message(FATAL_ERROR "CMake step for googletest failed: ${result}")
  endif()
  execute_process(COMMAND ${CMAKE_COMMAND} --build .
    RESULT_VARIABLE result
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/googletest-download )
  if(result)
    message(FATAL_ERROR "Build step for googletest failed: ${result}")
  endif()

  # Prevent overriding the parent project's compiler/linker
  # settings on Windows
  set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)

  # Add googletest directly to our build. This defines
  # the gtest and gtest_main targets.
  add_subdirectory(${CMAKE_BINARY_DIR}/googletest-src
                   ${CMAKE_BINARY_DIR}/googletest-build
                   EXCLUDE_FROM_ALL)

  target_include_directories(gmock_main SYSTEM BEFORE INTERFACE
  "${gtest_SOURCE_DIR}/include" "${gmock_SOURCE_DIR}/include")

endmacro()