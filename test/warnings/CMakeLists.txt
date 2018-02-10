set(warning_tests
  nonvirtual_destructor
)

if(GCC)
  set(nonvirtual_destructor_string )
endif()

foreach(test ${warning_tests})

  add_executable(${test} ${test}.cc)
  set_target_properties(${test} PROPERTIES
    EXCLUDE_FROM_ALL TRUE
    EXCLUDE_FROM_DEFAULT_BUILD TRUE)

  add_test(NAME WARNING_${test}
    COMMAND ${CMAKE_SOURCE_DIR}/test/warnings/testrunner.bash ${CMAKE_COMMAND} --build . --target ${test} --config $<CONFIGURATION>
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR})

endforeach()

