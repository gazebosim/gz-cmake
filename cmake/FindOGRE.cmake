#--------------------------------------
# Find ogre
# On Windows, we assume that all the OGRE* defines are passed in manually
# to CMake.

include(IgnPkgConfig)

# Grab the version numbers requested by the call to find_package(~)
set(major_version ${OGRE_FIND_VERSION_MAJOR})
set(minor_version ${OGRE_FIND_VERSION_MINOR})

# Set the full version number
set(full_version ${major_version}.${minor_version})

if (NOT WIN32)
  execute_process(COMMAND pkg-config --modversion OGRE
                  OUTPUT_VARIABLE OGRE_VERSION)
  string(REPLACE "\n" "" OGRE_VERSION ${OGRE_VERSION})

  string (REGEX REPLACE "^([0-9]+).*" "\\1"
    OGRE_MAJOR_VERSION "${OGRE_VERSION}")
  string (REGEX REPLACE "^[0-9]+\\.([0-9]+).*" "\\1"
    OGRE_MINOR_VERSION "${OGRE_VERSION}")
  string (REGEX REPLACE "^[0-9]+\\.[0-9]+\\.([0-9]+).*" "\\1"
    OGRE_PATCH_VERSION ${OGRE_VERSION})

  set(OGRE_VERSION
    ${OGRE_MAJOR_VERSION}.${OGRE_MINOR_VERSION}.${OGRE_PATCH_VERSION})
endif()

ign_pkg_check_modules_quiet(OGRE "OGRE >= ${full_version}")

if (OGRE_FOUND)

  ign_pkg_check_modules_quiet(OGRE-RTShaderSystem "OGRE-RTShaderSystem >= ${full_version}")

  if (OGRE-RTShaderSystem_FOUND)
    set(ogre_ldflags ${OGRE-RTShaderSystem_LDFLAGS})
    set(ogre_include_dirs ${OGRE-RTShaderSystem_INCLUDE_DIRS})
    set(ogre_libraries ${OGRE-RTShaderSystem_LIBRARIES})
    set(ogre_library_dirs ${OGRE-RTShaderSystem_LIBRARY_DIRS})
    set(ogre_cflags ${OGRE-RTShaderSystem_CFLAGS})

    set (INCLUDE_RTSHADER ON CACHE BOOL "Enable GPU shaders")
  else ()
    set (INCLUDE_RTSHADER OFF CACHE BOOL "Enable GPU shaders")
  endif ()

  set(ogre_ldflags ${ogre_ldflags} ${OGRE_LDFLAGS})
  set(ogre_include_dirs ${ogre_include_dirs} ${OGRE_INCLUDE_DIRS})
  set(ogre_libraries ${ogre_libraries};${OGRE_LIBRARIES})
  set(ogre_library_dirs ${ogre_library_dirs} ${OGRE_LIBRARY_DIRS})
  set(ogre_cflags ${ogre_cflags} ${OGRE_CFLAGS})

  ign_pkg_check_modules_quiet(OGRE-Terrain OGRE-Terrain)
  if (OGRE-Terrain_FOUND)
    set(ogre_ldflags ${ogre_ldflags} ${OGRE-Terrain_LDFLAGS})
    set(ogre_include_dirs ${ogre_include_dirs} ${OGRE-Terrain_INCLUDE_DIRS})
    set(ogre_libraries ${ogre_libraries};${OGRE-Terrain_LIBRARIES})
    set(ogre_library_dirs ${ogre_library_dirs} ${OGRE-Terrain_LIBRARY_DIRS})
    set(ogre_cflags ${ogre_cflags} ${OGRE-Terrain_CFLAGS})
  endif()

  ign_pkg_check_modules_quiet(OGRE-Overlay OGRE-Overlay)
  if (OGRE-Overlay_FOUND)
    set(ogre_ldflags ${ogre_ldflags} ${OGRE-Overlay_LDFLAGS})
    set(ogre_include_dirs ${ogre_include_dirs} ${OGRE-Overlay_INCLUDE_DIRS})
    set(ogre_libraries ${ogre_libraries};${OGRE-Overlay_LIBRARIES})
    set(ogre_library_dirs ${ogre_library_dirs} ${OGRE-Overlay_LIBRARY_DIRS})
    set(ogre_cflags ${ogre_cflags} ${OGRE-Overlay_CFLAGS})
  endif()

  set (OGRE_INCLUDE_DIRS ${ogre_include_dirs}
       CACHE INTERNAL "Ogre include path")

  # Also find OGRE's plugin directory, which is provided in its .pc file as the
  # `plugindir` variable.  We have to call pkg-config manually to get it.
  # On Windows, we assume that all the OGRE* defines are passed in manually
  # to CMake.
  if (NOT WIN32)
    execute_process(COMMAND pkg-config --variable=plugindir OGRE
                    OUTPUT_VARIABLE _pkgconfig_invoke_result
                    RESULT_VARIABLE _pkgconfig_failed)
    if(_pkgconfig_failed)
      BUILD_WARNING ("Failed to find OGRE's plugin directory.  The build will succeed, but there will likely be run-time errors.")
    else()
      # This variable will be substituted into cmake/setup.sh.in
      set (OGRE_PLUGINDIR ${_pkgconfig_invoke_result})
    endif()
  endif()

  set(OGRE_RESOURCE_PATH ${OGRE_PLUGINDIR})
  # Seems that OGRE_PLUGINDIR can end in a newline, which will cause problems when
  # we pass it to the compiler later.
  string(REPLACE "\n" "" OGRE_RESOURCE_PATH ${OGRE_RESOURCE_PATH})

  message(STATUS "Looking for OGRE - found")
  set(HAVE_OGRE true)
  if(NOT OGRE_FIND_QUIETLY)
    message(STATUS "Found OGRE: ${OGRE_LIBRARIES}")
  endif(NOT OGRE_FIND_QUIETLY)

else(OGRE_FOUND)

  if(OGRE_FIND_REQUIRED)
    message(FATAL_ERROR "Could not find OGRE")
  endif(OGRE_FIND_REQUIRED)

endif ()
