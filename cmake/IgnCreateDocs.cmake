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
# ign_create_docs(
#     [TAGFILES <tagfile_string>])
#
# This function will configure doxygen templates and install them.
#
# TAGFILES: Optional. Specify tagfiles for doxygen to use. It should have form like:
#           "\"${IGNITION-<DESIGNATION>_DOXYGEN_TAGFILE} = ${IGNITION-<DESIGNATION>_API_URL}\""
function(ign_create_docs)

  #------------------------------------
  # Define the expected arguments
  set(options)
  set(oneValueArgs "TAGFILES")
  set(multiValueArgs)

  #------------------------------------
  # Parse the arguments
  _ign_cmake_parse_arguments(ign_create_docs "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  #--------------------------------------
  # Configure documentation uploader
  configure_file("${IGNITION_CMAKE_DIR}/upload_doc.sh.in"
    ${CMAKE_BINARY_DIR}/upload_doc.sh @ONLY)

  #--------------------------------------
  # Create man pages
  include(IgnRonn2Man)
  ign_add_manpage_target()

  set(IGNITION_DOXYGEN_TAGFILES ${ign_create_docs_TAGFILES})

  find_package(Doxygen)
  if (DOXYGEN_FOUND AND EXISTS ${IGNITION_CMAKE_DOXYGEN_DIR}/api.in AND
      EXISTS ${IGNITION_CMAKE_DOXYGEN_DIR}/tutorials.in)
    configure_file(${IGNITION_CMAKE_DOXYGEN_DIR}/api.in
                   ${CMAKE_BINARY_DIR}/api.dox @ONLY)

    configure_file(${IGNITION_CMAKE_DOXYGEN_DIR}/tutorials.in
                   ${CMAKE_BINARY_DIR}/tutorials.dox @ONLY)

    add_custom_target(doc ALL
      # Generate the API documentation
      ${DOXYGEN_EXECUTABLE} ${CMAKE_BINARY_DIR}/api.dox
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR}

      COMMAND ${DOXYGEN_EXECUTABLE} ${CMAKE_BINARY_DIR}/tutorials.dox

      COMMENT "Generating API documentation with Doxygen" VERBATIM)

    install(FILES ${CMAKE_BINARY_DIR}/${PROJECT_NAME_LOWER}.tag.xml
      DESTINATION ${IGN_DATA_INSTALL_DIR}_${PROJECT_VERSION_MINOR})
  endif()

  #--------------------------------------
  # If we're configuring only to build docs, stop here
  if (DOC_ONLY)
    message(WARNING "Configuration was done in DOC_ONLY mode."
    " You can build documentation (make doc), but nothing else.")
    return()
  endif()

endfunction()
