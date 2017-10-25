include(ExternalProject)

set(build_types Release RelWithDebInfo Debug)
if (NOT WIN32)
  list(APPEND build_types Coverage)
endif()
foreach (build_type ${build_types})
  set(example ign_configure_build)
  ExternalProject_Add(
    ${example}_${build_type}

    SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/${example}"
    CMAKE_ARGS
      "-DCMAKE_PREFIX_PATH=${CMAKE_BINARY_DIR}"
      "-DCMAKE_BUILD_TYPE=${build_type}"
  )
endforeach()
