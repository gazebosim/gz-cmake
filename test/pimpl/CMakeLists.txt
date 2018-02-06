
add_library(pimpl SHARED classes.cc)

target_include_directories(pimpl
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/..>)

target_link_libraries(pimpl PUBLIC ${PROJECT_EXPORT_NAME}-utilities)
