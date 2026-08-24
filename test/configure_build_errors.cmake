cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)

if(NOT DEFINED GZ_CMAKE_MODULE_DIR)
  message(FATAL_ERROR "GZ_CMAKE_MODULE_DIR must point to the gz-cmake modules")
endif()

function(check_configure_build_errors quit_if_build_errors)
  if(quit_if_build_errors)
    set(case_name "QUIT_IF_BUILD_ERRORS")
  else()
    set(case_name "default")
  endif()

  execute_process(
    COMMAND
      "${CMAKE_COMMAND}"
      "-DGZ_CMAKE_MODULE_DIR=${GZ_CMAKE_MODULE_DIR}"
      "-DQUIT_IF_BUILD_ERRORS=${quit_if_build_errors}"
      -P "${CMAKE_CURRENT_LIST_DIR}/configure_build_errors_input.cmake"
    RESULT_VARIABLE result
    OUTPUT_VARIABLE stdout
    ERROR_VARIABLE stderr
  )
  string(CONCAT output "${stdout}" "${stderr}")

  if(result EQUAL 0)
    message(FATAL_ERROR "${case_name}: expected configuration to fail")
  endif()

  foreach(expected
      "-- BUILD ERRORS: These must be resolved before compiling."
      "-- First synthetic build error"
      "-- Second synthetic build error"
      "-- END BUILD ERRORS"
      "Errors encountered in build."
      "Please see BUILD ERRORS above.")
    string(FIND "${output}" "${expected}" found)
    if(found EQUAL -1)
      message(FATAL_ERROR
        "${case_name}: missing expected output [${expected}]\n${output}")
    endif()
  endforeach()

  string(REGEX MATCHALL "CMake Error at" error_headers "${output}")
  list(LENGTH error_headers error_header_count)
  if(NOT error_header_count EQUAL 1)
    message(FATAL_ERROR
      "${case_name}: expected one CMake error block, got "
      "${error_header_count}\n${output}")
  endif()

  string(REGEX MATCHALL
    "Call Stack \\(most recent call first\\):" call_stacks "${output}")
  list(LENGTH call_stacks call_stack_count)
  if(NOT call_stack_count EQUAL 1)
    message(FATAL_ERROR
      "${case_name}: expected one call stack, got ${call_stack_count}\n${output}")
  endif()

  string(FIND "${output}" "CMake Warning at" warning_header)
  if(NOT warning_header EQUAL -1)
    message(FATAL_ERROR "${case_name}: unexpected warning block\n${output}")
  endif()

  string(FIND "${output}" "continued after gz_configure_build" continued)
  if(quit_if_build_errors AND NOT continued EQUAL -1)
    message(FATAL_ERROR "${case_name}: fatal error did not stop processing")
  elseif(NOT quit_if_build_errors AND continued EQUAL -1)
    message(FATAL_ERROR "${case_name}: SEND_ERROR did not continue processing")
  endif()
endfunction()

check_configure_build_errors(FALSE)
check_configure_build_errors(TRUE)
