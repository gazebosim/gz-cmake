#.rst
#
#===============================================================================
# Copyright (C) 2023 Open Source Robotics Foundation
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

option(GZ_CMAKE_SYMLINK_INSTALL
  "Replace the CMake install command with a custom implementation using symlinks instead of copying resources"
  OFF)

if(GZ_CMAKE_SYMLINK_INSTALL)
  message(STATUS "Override CMake install command with custom implementation "
    "using symlinks instead of copying resources")

  if(${gz-cmake3_DIR})
    set(GZ_CMAKE_DIR "${gz-cmake3_DIR}/cmake3")
  endif()

  include(
    "${GZ_CMAKE_DIR}/symlink_install/ament_cmake_symlink_install_append_install_code.cmake")
  include(
    "${GZ_CMAKE_DIR}/symlink_install/ament_cmake_symlink_install_directory.cmake")
  include(
    "${GZ_CMAKE_DIR}/symlink_install/ament_cmake_symlink_install_files.cmake")
  include(
    "${GZ_CMAKE_DIR}/symlink_install/ament_cmake_symlink_install_programs.cmake")
  include(
    "${GZ_CMAKE_DIR}/symlink_install/ament_cmake_symlink_install_targets.cmake")
  include("${GZ_CMAKE_DIR}/symlink_install/install.cmake")

  # create the install script from the template
  # ament_cmake_core/cmake/symlink_install/ament_cmake_symlink_install.cmake.in
  set(AMENT_CMAKE_SYMLINK_INSTALL_INSTALL_SCRIPT
    "${CMAKE_CURRENT_BINARY_DIR}/ament_cmake_symlink_install/ament_cmake_symlink_install.cmake")
  configure_file(
    "${GZ_CMAKE_DIR}/symlink_install/ament_cmake_symlink_install.cmake.in"
    "${AMENT_CMAKE_SYMLINK_INSTALL_INSTALL_SCRIPT}"
    @ONLY
  )
  # register script for being executed at install time
  install(SCRIPT "${AMENT_CMAKE_SYMLINK_INSTALL_INSTALL_SCRIPT}")

  if(AMENT_CMAKE_UNINSTALL_TARGET)
    # register uninstall script
    set(AMENT_CMAKE_SYMLINK_INSTALL_UNINSTALL_SCRIPT
      "${CMAKE_CURRENT_BINARY_DIR}/ament_cmake_symlink_install/ament_cmake_symlink_install_uninstall_script.cmake")
    configure_file(
      "${GZ_CMAKE_DIR}/symlink_install/ament_cmake_symlink_install_uninstall_script.cmake.in"
      "${AMENT_CMAKE_SYMLINK_INSTALL_UNINSTALL_SCRIPT}"
      @ONLY
    )
    ament_cmake_uninstall_target_append_uninstall_code(
      "include(\"${AMENT_CMAKE_SYMLINK_INSTALL_UNINSTALL_SCRIPT}\")"
      COMMENTS "uninstall files installed using the symlink install functions")
  endif()
endif()
