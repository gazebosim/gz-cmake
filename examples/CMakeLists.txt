include(ExternalProject)

set(build_types Release RelWithDebInfo Debug Coverage)
foreach (build_type ${build_types})
  ExternalProject_Add(
    ign_configure_build_${build_type}

    SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/ign_configure_build"
    CMAKE_ARGS
      "-DCMAKE_PREFIX_PATH=${CMAKE_BINARY_DIR}"
      "-DCMAKE_BUILD_TYPE=${build_type}"
  )
endforeach()
