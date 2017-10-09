#.rst
# IgnCreatePackage
# ----------------
#
# ign_create_docs
#
# Creates documentation for an ignition library project.
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
# Create documentation information
macro(ign_create_docs)

  #--------------------------------------
  # Traverse the doc directory
  add_subdirectory(doc)

  #--------------------------------------
  # Configure documentation uploader
  configure_file("${IGNITION_CMAKE_DIR}/upload_doc.sh.in"
    ${CMAKE_BINARY_DIR}/upload_doc.sh @ONLY)

  #--------------------------------------
  # If we're configuring only to build docs, stop here
  if (DOC_ONLY)
    message(WARNING "Configuration was done in DOC_ONLY mode."
    " You can build documentation (make doc), but nothing else.")
    return()
  endif()

  #--------------------------------------
  # Create man pages
  include(IgnRonn2Man)
  ign_add_manpage_target()

endmacro()
