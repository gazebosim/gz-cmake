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

  set(required_html_files
    "doxygen/html/annotated.html"
    "doxygen/html/hierarchy.html"
    "doxygen/html/index.html"
    "doxygen/html/functions.html"
    "doxygen/html/functions_func.html"
    "doxygen/html/functions_vars.html"
    "doxygen/html/functions_type.html"
    "doxygen/html/functions_enum.html"
    "doxygen/html/functions_eval.html"
    "doxygen/html/namespaces.html"
    "doxygen/html/namespacemembers_func.html"
    "doxygen/html/namespacemembers_type.html"
    "doxygen/html/namespacemembers_vars.html"
    "doxygen/html/namespacemembers_enum.html"
    "doxygen/html/namespacemembers_eval.html"
  )

  # Add an html file for each required_html_files, whic guarantees that
  # all the links in header.html are valid. This is needed because
  # doxygen does not generate an html file if the necessary content is not
  # present in a project. For example, the "hierarchy.html" may not be
  # generated in a project that has no class hierarchy. 
  if (DEFINED IGNITION_CMAKE_DOXYGEN_DIR)
    file(READ "${IGNITION_CMAKE_DOXYGEN_DIR}/header.html" doxygen_header)
    file(READ "${IGNITION_CMAKE_DOXYGEN_DIR}/footer.html" doxygen_footer)
    string(REGEX REPLACE "\\$projectname" "Ignition ${IGN_DESIGNATION_CAP}"
      doxygen_header ${doxygen_header})
    string(REGEX REPLACE "\\$projectnumber" "${PROJECT_VERSION_FULL}"
      doxygen_header ${doxygen_header})
    string(REGEX REPLACE "\\$title" "404"
      doxygen_header ${doxygen_header})
  elseif()
    set (doxygen_header "<html><body>")
    set (doxygen_footer "</body></html>")
  endif()

  foreach(required_file ${required_html_files})
    file(WRITE ${CMAKE_BINARY_DIR}/${required_file} ${doxygen_header})
    file(APPEND ${CMAKE_BINARY_DIR}/${required_file} 
      "<div class='header'><div class='headertitle'>
       <div class='title'>No Documentation</div>
       </div></div>
       <div class='contents'>
       <p>This library does not contain the selected type of documentation.</p>
       <p><a href='#' onClick='history.go(-1);return true;'>Back</a></p>
       </div>")

    file(APPEND ${CMAKE_BINARY_DIR}/${required_file} ${doxygen_footer})
  endforeach()

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
