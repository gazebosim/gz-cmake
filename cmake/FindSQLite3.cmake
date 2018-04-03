#===============================================================================
# Copyright (C) 2018 Open Source Robotics Foundation
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
# Find SQLite3

ign_pkg_check_modules_quiet(SQLite3 "sqlite3 >= 3.7.13")

if(MSVC)

  set(SQLite3_FOUND TRUE)

  find_library(SQLite3_LIBRARIES sqlite3)
  if(NOT SQLite3_LIBRARIES)
    set(SQLite3_FOUND FALSE)
    if(NOT SQLite3_FIND_QUIETLY)
      message(STATUS "Looking for sqlite3 library - not found")
    endif()
  endif()

  find_path(SQLite3_INCLUDE_DIRS sqlite3.h)
  if(NOT SQLite3_INCLUDE_DIRS)
    set(SQLite3_FOUND FALSE)
    if(NOT SQLite3_FIND_QUIETLY)
      message(STATUS "Looking for sqlite header (sqlite3.h) - not found")
    endif()
  endif()

  ign_import_target(SQLite3)

endif()
