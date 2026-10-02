# Configure an example with extra cmake flags and check the outcome.
#
# Usage:
#   cmake -DTEST_NAME=<name>
#         -DSOURCE_DIR=<example source dir>
#         -DBINARY_DIR=<fresh build dir>
#         -DPREFIX_PATH=<gz-cmake install prefix>
#         -DGENERATOR=<cmake generator>
#         -DRESULTS_DIR=<junit output dir>
#         -DEXPECT=PASS|FAIL
#         [-DEXPECT_REGEX=<regex the configure output must match>]
#         [-DEXPECT_NOT_REGEX=<regex the configure output must not match>]
#         -P test_comp_required.cmake [-- <extra configure arguments>...]
#
# Whitespace in the configure output is collapsed to single spaces before
# matching, since cmake wraps long messages.

set(configure_args)
set(after_separator FALSE)
math(EXPR last_arg "${CMAKE_ARGC} - 1")
foreach(i RANGE ${last_arg})
  if(after_separator)
    list(APPEND configure_args "${CMAKE_ARGV${i}}")
  elseif("${CMAKE_ARGV${i}}" STREQUAL "--")
    set(after_separator TRUE)
  endif()
endforeach()

file(REMOVE_RECURSE "${BINARY_DIR}")
execute_process(
  COMMAND ${CMAKE_COMMAND}
    -S "${SOURCE_DIR}"
    -B "${BINARY_DIR}"
    -G "${GENERATOR}"
    "-DCMAKE_PREFIX_PATH=${PREFIX_PATH}"
    ${configure_args}
  RESULT_VARIABLE configure_result
  OUTPUT_VARIABLE configure_output
  ERROR_VARIABLE configure_output
)
string(REGEX REPLACE "[ \t\r\n]+" " " flat_output "${configure_output}")

set(failures)
if(EXPECT STREQUAL "PASS" AND NOT configure_result EQUAL 0)
  list(APPEND failures "expected configure to succeed, it failed")
elseif(EXPECT STREQUAL "FAIL" AND configure_result EQUAL 0)
  list(APPEND failures "expected configure to fail, it succeeded")
endif()
if(DEFINED EXPECT_REGEX AND NOT flat_output MATCHES "${EXPECT_REGEX}")
  list(APPEND failures "output does not match [${EXPECT_REGEX}]")
endif()
if(DEFINED EXPECT_NOT_REGEX AND flat_output MATCHES "${EXPECT_NOT_REGEX}")
  list(APPEND failures "output matches [${EXPECT_NOT_REGEX}]")
endif()

string(TIMESTAMP TEST_TIME)
if(failures)
  set(junit_template junit_fail.xml.in)
else()
  set(junit_template junit_pass.xml.in)
endif()
configure_file(
  "${CMAKE_CURRENT_LIST_DIR}/${junit_template}"
  "${RESULTS_DIR}/${TEST_NAME}.xml"
  @ONLY)

if(failures)
  list(JOIN failures "\n  " failures_str)
  message(FATAL_ERROR
    "${TEST_NAME}:\n  ${failures_str}\n"
    "Configure arguments: ${configure_args}\n"
    "Configure output:\n${configure_output}")
endif()
message(STATUS "${TEST_NAME} passed")
