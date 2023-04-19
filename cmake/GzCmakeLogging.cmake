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
# gz_build_error macro
macro(ign_build_error)
  # TODO(chapulina) Enable warnings after all libraries have migrated.
  # message(WARNING "ign_build_error is deprecated, use gz_build_error instead.")

  foreach(str ${ARGN})
    set(msg "\t${str}")
    list(APPEND build_errors ${msg})
  endforeach()
endmacro(ign_build_error)
macro(gz_build_error)
  foreach(str ${ARGN})
    set(msg "\t${str}")
    list(APPEND build_errors ${msg})
  endforeach()
endmacro(gz_build_error)

#################################################
# gz_build_warning macro
macro(ign_build_warning)
  # TODO(chapulina) Enable warnings after all libraries have migrated.
  # message(WARNING "ign_build_warning is deprecated, use gz_build_warning instead.")

  foreach(str ${ARGN})
    list(APPEND build_warnings "${str}")
  endforeach(str ${ARGN})
endmacro(ign_build_warning)
macro(gz_build_warning)
  foreach(str ${ARGN})
    list(APPEND build_warnings "${str}")
  endforeach(str ${ARGN})
endmacro(gz_build_warning)
