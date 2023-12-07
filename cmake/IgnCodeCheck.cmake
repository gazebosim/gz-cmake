# Setup the codecheck target, which will run cppcheck and cppplint.
function(ign_setup_target_for_codecheck)
  include(IgnPython)

  find_program(cppcheck_path cppcheck)
  find_program(FIND_PATH find)

  if(NOT cppcheck_path)
    message(STATUS "The program [cppcheck] was not found! Skipping codecheck setup")
    return()
  endif()

  if(NOT FIND_PATH)
    message(STATUS "The program [find] was not found! Skipping codecheck setup.")
    return()
  endif()

  # Base set of cppcheck option
  set (cppcheck_base -q --inline-suppr -j 4 --language=c++ --std=c++14 --force)
  if (EXISTS "${PROJECT_BINARY_DIR}/cppcheck.suppress")
    set (cppcheck_base ${cppcheck_base} --suppressions-list=${PROJECT_BINARY_DIR}/cppcheck.suppress)
  endif()

  # Extra cppcheck option
  set (cppcheck_extra --enable=style,performance,portability,information)

  # Rules for cppcheck
  set (cppcheck_rules "\
    -UM_PI \
    --rule-file=${IGNITION_CMAKE_CODECHECK_DIR}/header_guard.rule \
    --rule-file=${IGNITION_CMAKE_CODECHECK_DIR}/namespace_AZ.rule")

  # The find command
  set (cppcheck_find
    ${FIND_PATH} ${CPPCHECK_DIRS} -name '*.cc' -o -name '*.hh' -o -name '*.c' -o -name '*.h')

  message(STATUS "Adding codecheck target")

  # Each include directory needs an -I flag
  set(cppcheck_include_dirs_FLAGS)
  foreach(dir ${cppcheck_include_dirs})
    list(APPEND cppcheck_include_dirs_FLAGS "-I${dir}")
  endforeach()

  add_custom_target(cppcheck
    COMMENT "cppcheck target"
    # First cppcheck
    COMMAND ${cppcheck_path} ${cppcheck_base} ${cppcheck_extra}
            ${cppcheck_include_dirs_FLAGS}
            ${cppcheck_rules} `${cppcheck_find}`
    # Second cppcheck
    COMMAND ${cppcheck_path} ${cppcheck_base} --enable=missingInclude
            `${cppcheck_find}`
  )

  add_custom_target(codecheck
    COMMENT "codecheck execution"
    DEPENDS cppcheck
  )

  if(Python3_Interpreter_FOUND)
    add_custom_target(cpplint
      COMMENT "cpplint execution"
      COMMAND ${Python3_EXECUTABLE} ${IGNITION_CMAKE_CODECHECK_DIR}/cpplint.py
              --extensions=cc,hh --quiet `${cppcheck_find}`
    )

    add_dependencies(codecheck cpplint)
  endif()
endfunction()
