set (files
cpplint.py
header_guard.rule
namespace_AZ.rule
)

install(FILES ${files}
  DESTINATION ${CMAKE_INSTALL_PREFIX}/share/ignition/${PROJECT_NAME_LOWER}/codecheck)
