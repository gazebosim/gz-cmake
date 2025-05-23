#.rst
# GzCMake
# --------
#
# Includes a set of modules that are needed for building the Gazebo libraries
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

#============================================================================
# gz-cmake modules
#============================================================================
include(GzUtils)
include(GzConfigureProject)
include(GzPackaging)
include(GzCreateDocs)
include(GzSetCompilerFlags)
include(GzConfigureBuild)
include(GzGetPackageXmlVersion)
include(GzImportTarget)
include(GzPkgConfig)
include(GzSanitizers)

#============================================================================
# Native cmake modules
#============================================================================
include(CMakePackageConfigHelpers)
include(CMakeParseArguments)
