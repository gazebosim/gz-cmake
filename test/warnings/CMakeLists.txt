set(warning_tests
  nonvirtual_destructor
)

# TODO: How should we check that warning suppression is working on Windows?
if (UNIX)
  set(nonvirtual_destructor_string )
  set(warning_flag "-Wall" "-Werror")

  foreach(test ${warning_tests})

    add_executable(${test} ${test}.cc)
    message("Compiling ${test} with ${warning_flag} warning mode")
    target_compile_options(${test} PRIVATE ${warning_flag})

    set_target_properties(${test} PROPERTIES
      EXCLUDE_FROM_ALL TRUE
      EXCLUDE_FROM_DEFAULT_BUILD TRUE)

    add_test(NAME WARNING_${test}
      COMMAND ${CMAKE_SOURCE_DIR}/test/warnings/testrunner.bash ${CMAKE_COMMAND} --build . --target ${test} --config $<CONFIGURATION>
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR})

    set_tests_properties(WARNING_${test} PROPERTIES
      PASS_REGULAR_EXPRESSION "deleting object of abstract class type")

  endforeach()

endif()
