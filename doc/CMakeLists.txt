# TODO: Write documentation for ignition-cmake

set (files
  cppreference.tag.xml
  layout.xml)

install(FILES ${files}
        DESTINATION ${CMAKE_INSTALL_PREFIX}/share/ignition/${PROJECT_NAME_LOWER}/doxygen)
