# Copyright (C) 2023 Open Source Robotics Foundation
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
macro(gz_install_executable _name)
  set_target_properties(${_name} PROPERTIES VERSION ${PROJECT_VERSION_FULL})
  install (TARGETS ${_name} DESTINATION ${GZ_BIN_INSTALL_DIR})
  manpage(${_name} 1)
endmacro()

#################################################
macro(gz_add_executable _name)
  add_executable(${_name} ${ARGN})
  target_link_libraries(${_name} ${general_libraries})
endmacro()

#################################################
# gz_build_executables(SOURCES <sources>
#                       [PREFIX <prefix>]
#                       [LIB_DEPS <library_dependencies>]
#                       [INCLUDE_DIRS <include_dependencies>]
#                       [EXEC_LIST <output_var>]
#                       [EXCLUDE_PROJECT_LIB])
#
# Build executables for an Gazebo project. Arguments are as follows:
#
# SOURCES: Required. The names (without a path) of the source files for your
#          executables.
#
# PREFIX: Optional. This will append <prefix> onto each executable name.
#
# LIB_DEPS: Optional. Additional library dependencies that every executable
#           should link to, not including the library build by this project (it
#           will be linked automatically, unless you pass in the
#           EXCLUDE_PROJECT_LIB option).
#
# INCLUDE_DIRS: Optional. Additional include directories that should be visible
#               to all of these executables.
#
# EXEC_LIST: Optional. Provide a variable which will be given the list of the
#            names of the executables generated by this macro. These will also
#            be the names of the targets.
#
# EXCLUDE_PROJECT_LIB: Pass this argument if you do not want your executables to
#                      link to your project's core library. On Windows, this
#                      will also skip the step of copying the runtime library
#                      into your executable's directory.
#
macro(gz_build_executables)
  # Define the expected arguments
  set(options EXCLUDE_PROJECT_LIB)
  set(oneValueArgs PREFIX EXEC_LIST)
  set(multiValueArgs SOURCES LIB_DEPS INCLUDE_DIRS)

  if(gz_build_executables_EXEC_LIST)
    set(${gz_build_executables_EXEC_LIST} "")
  endif()
  #------------------------------------
  # Parse the arguments
  _gz_cmake_parse_arguments(gz_build_executables "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  foreach(exec_file ${gz_build_executables_SOURCES})

    get_filename_component(BINARY_NAME ${exec_file} NAME_WE)
    set(BINARY_NAME ${gz_build_executables_PREFIX}${BINARY_NAME})

    add_executable(${BINARY_NAME} ${exec_file})

    if(gz_build_executables_EXEC_LIST)
      list(APPEND ${gz_build_executables_EXEC_LIST} ${BINARY_NAME})
    endif()

    if(NOT gz_build_executables_EXCLUDE_PROJECT_LIB)
      target_link_libraries(${BINARY_NAME} ${PROJECT_LIBRARY_TARGET_NAME})
    endif()

    if(gz_build_executables_LIB_DEPS)
      target_link_libraries(${BINARY_NAME} ${gz_build_executables_LIB_DEPS})
    endif()

    target_include_directories(${BINARY_NAME}
      PRIVATE
        ${PROJECT_SOURCE_DIR}
        ${PROJECT_BINARY_DIR}
        ${gz_build_executables_INCLUDE_DIRS})

  endforeach()

endmacro()
