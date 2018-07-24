
ign_get_sources(tests)

foreach(test ${tests})

  get_filename_component(name ${test} NAME_WE)
  set(name WARNING_${name})

  add_executable(${name} ${test})
  target_link_libraries(${name} ${PROJECT_EXPORT_NAME}-utilities)
  set_property(TARGET ${name} PROPERTY CXX_STANDARD 11)

  if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU"
      OR "${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")

    target_compile_options(${name} PRIVATE "-Wall" "-Werror")

  elseif(MSVC)

    target_compile_options(${name} PRIVATE "/W4" "/WX" "/we4265" "/EHsc")

  endif()

endforeach()
