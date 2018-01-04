set (files
  api.in
  cppreference.tag.xml
  footer.html
  header.html
  layout.xml
  tutorials-footer.html
  tutorials-header.html
  tutorials.in)


install(FILES ${files}
        DESTINATION ${CMAKE_INSTALL_PREFIX}/share/ignition/${PROJECT_NAME_LOWER}/doxygen)

