# Setup the codecheck target, which will run cppcheck and cppplint.
function(IGN_SETUP_TARGET_FOR_CODECHECK)

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

  # Includes for cppcheck
  set (CPPCHECK_INCLUDES -I ${CMAKE_SOURCE_DIR}/include -I ${CMAKE_BINARY_DIR} -I ${CMAKE_SOURCE_DIR}/test -I ${CMAKE_SOURCE_DIR}/include/ignition/${IGN_DESIGNATION})
 
  # Directories to check for code 
  set (CPPCHECK_DIRS
    ${CMAKE_SOURCE_DIR}/src
    ${CMAKE_SOURCE_DIR}/include
    ${CMAKE_SOURCE_DIR}/test/integration
    ${CMAKE_SOURCE_DIR}/test/regression
    ${CMAKE_SOURCE_DIR}/test/performance)

  # The find command
  set (CPPCHECK_FIND ${FIND_PATH} ${CPPCHECK_DIRS} -name '*.cc' -o -name '*.hh' -o -name '*.c' -o -name '*.h')

  # Setup the codecheck target
  add_custom_target(codecheck

    # First cppcheck
    COMMAND ${CPPCHECK_PATH} ${CPPCHECK_BASE} ${CPPCHECK_EXTRA} ${CPPCHECK_INCLUDES} ${CPPCHECK_RULES} `${CPPCHECK_FIND}` 

    # Second cppcheck
    COMMAND ${CPPCHECK_PATH} ${CPPCHECK_BASE} --enable=missingInclude `${CPPCHECK_FIND}` ${CPPCHECK_INCLUDES}

    # cpplint cppcheck
    COMMAND ${CPPCHECK_FIND} | xargs python ${IGNITION_CMAKE_CODECHECK_DIR}/cpplint.py --extensions=cc,hh --quiet)

endfunction()
