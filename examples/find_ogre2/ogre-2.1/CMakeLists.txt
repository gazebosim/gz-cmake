cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(gz-ogre-2.1)

find_package(gz-cmake4 REQUIRED)

message(STATUS "Finding OGRE 2.1")

gz_find_package(GzOGRE2 VERSION 2.1
    COMPONENTS HlmsPbs HlmsUnlit Overlay)

message(STATUS "OGRE2_FOUND: " ${OGRE2_FOUND})
if(OGRE2_FOUND)
  message(STATUS "OGRE2_LIBRARIES: " ${OGRE2_LIBRARIES})
  message(STATUS "OGRE2_INCLUDE_DIRS: " ${OGRE2_INCLUDE_DIRS})
  message(STATUS "OGRE2_VERSION: " ${OGRE2_VERSION})
  message(STATUS "OGRE2_VERSION_MAJOR: " ${OGRE2_VERSION_MAJOR})
  message(STATUS "OGRE2_VERSION_MINOR: " ${OGRE2_VERSION_MINOR})
  message(STATUS "OGRE2_VERSION_PATCH: " ${OGRE2_VERSION_PATCH})
  message(STATUS "OGRE2_RESOURCE_PATH: " ${OGRE2_RESOURCE_PATH})

  message(STATUS "GzOGRE2_VERSION_EXACT: " ${GzOGRE2_VERSION_EXACT})
  message(STATUS "GzOGRE2_VERSION_COMPATIBLE: " ${GzOGRE2_VERSION_COMPATIBLE})
endif()
