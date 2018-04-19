# Setup the codecheck target, which will run cppcheck and cppplint.
function(ign_setup_target_for_codecheck)

  message (STATUS "\n\n\nHERE\n\n\n")
  find_program(CPPCHECK_PATH cppcheck)
  find_program(PYTHON_PATH python)
  find_program(FIND_PATH find)
  
  if(NOT CPPCHECK_PATH)
    message(WARNING "cppcheck not found! Aborting codecheck setup")
    return()
  endif()
  
  if(NOT PYTHON_PATH)
    message(WARNING "python not found! Aborting codecheck setup.")
    return()
  endif()
  
  if(NOT FIND_PATH)
    message(WARNING "find not found! Aborting codecheck setup.")
    return()
  endif()

  # Base set of cppcheck option
  set (CPPCHECK_BASE -q --inline-suppr -j 4)

  # Extra cppcheck option
  set (CPPCHECK_EXTRA --language=c++ --enable=style,performance,portability,information)

  # Rules for cppcheck
  set (CPPCHECK_RULES "-UM_PI --rule-file=${IGNITION_CMAKE_CODECHECK_DIR}/header_guard.rule --rule-file=${IGNITION_CMAKE_CODECHECK_DIR}/namespace_AZ.rule")

  # The find command
  set (CPPCHECK_FIND ${FIND_PATH} ${CPPCHECK_DIRS} -name '*.cc' -o -name '*.hh' -o -name '*.c' -o -name '*.h')

  file(WRITE ${PROJECT_BINARY_DIR}/__ign_codecheck_fake.cc
"/*
  * Copyright (C) 2018 Open Source Robotics Foundation
  *
  * Licensed under the Apache License, Version 2.0 (the 'License');
  * you may not use this file except in compliance with the License.
  * You may obtain a copy of the License at
  *
  *     http://www.apache.org/licenses/LICENSE-2.0
  *
  * Unless required by applicable law or agreed to in writing, software
  * distributed under the License is distributed on an 'AS IS' BASIS,
  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  * See the License for the specific language governing permissions and
  * limitations under the License.
  *
  */
  // This file guarantees cppcheck has at least one file to check,
  // thereby preventing an error.
")

  # Setup the codecheck target
  add_custom_target(codecheck

    # First cppcheck
    COMMAND ${CPPCHECK_PATH} ${CPPCHECK_BASE} ${CPPCHECK_EXTRA} -I ${CPPCHECK_INCLUDE_DIRS} ${CPPCHECK_RULES} `${CPPCHECK_FIND}` ${PROJECT_BINARY_DIR}/__ign_codecheck_fake.cc

    # Second cppcheck
    COMMAND ${CPPCHECK_PATH} ${CPPCHECK_BASE} --enable=missingInclude `${CPPCHECK_FIND}` ${PROJECT_BINARY_DIR}/__ign_codecheck_fake.cc -I ${CPPCHECK_INCLUDE_DIRS} 

    # cpplint cppcheck
    COMMAND python ${IGNITION_CMAKE_CODECHECK_DIR}/cpplint.py --extensions=cc,hh --quiet `${CPPCHECK_FIND}` ${PROJECT_BINARY_DIR}/__ign_codecheck_fake.cc )

endfunction()
