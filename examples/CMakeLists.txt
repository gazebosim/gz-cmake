include(ExternalProject)

ExternalProject_Add(
  ign_configure_build

  SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/ign_configure_build"
  CMAKE_ARGS "-DCMAKE_PREFIX_PATH=${CMAKE_BINARY_DIR}"
)
