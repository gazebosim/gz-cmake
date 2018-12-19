
ign_add_component(child INTERFACE
  GET_TARGET_NAME child)

target_link_libraries(${child}
  INTERFACE
    ${PROJECT_LIBRARY_TARGET_NAME}-parent)

install(
  DIRECTORY include/
  DESTINATION "${IGN_INCLUDE_INSTALL_DIR_FULL}")
