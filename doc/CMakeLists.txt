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
        DESTINATION ${IGN_SHARE_INSTALL_DIR}/doxygen)

