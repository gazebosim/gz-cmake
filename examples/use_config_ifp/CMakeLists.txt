cmake_minimum_required(VERSION 3.10.2 FATAL_ERROR)
project(ignition-find_config VERSION 0.1.0)
find_package(ignition-cmake2 REQUIRED)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/")
set(ignition-find_config_DIR "${CMAKE_SOURCE_DIR}/")
#ign_find_package(ignition-find_config) will search for Findignition-find_config.cmake before ignition-find_configConfig.cmake 
ign_find_package(ignition-find_config)
#After CONFIG arguemnt ign_find_package will skip MODULE mode and search for ignition-find_configConfig.cmake directly
ign_find_package(ignition-find_config CONFIG)
ign_configure_project()
ign_configure_build(QUIT_IF_BUILD_ERRORS)
ign_create_packages()

