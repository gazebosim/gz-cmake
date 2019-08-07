#===============================================================================
# Copyright (C) 2019 Open Source Robotics Foundation
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
# Copyright (c) 2011-2019, The DART development contributors
# All rights reserved.
#
# The list of contributors can be found at:
#   https://github.com/dartsim/dart/blob/master/LICENSE
#
# This file is provided under the "BSD-style" License
########################################

set(ign_quiet_arg)
if(IgnBullet_FIND_QUIETLY)
  set(ign_quiet_arg QUIET)
endif()

# Bullet. Force MODULE mode to use the FindBullet.cmake file distributed with
# CMake. Otherwise, we may end up using the BulletConfig.cmake file distributed
# with Bullet, which uses relative paths and may break transitive dependencies.
find_package(Bullet COMPONENTS BulletMath BulletCollision MODULE QUIET)

set(IgnBullet_FOUND ${BULLET_FOUND})

if((BULLET_FOUND OR Bullet_FOUND) AND NOT TARGET Bullet)
  add_library(Bullet INTERFACE IMPORTED)
  set_target_properties(Bullet PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${BULLET_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES "${BULLET_LIBRARIES}"
  )
endif()
