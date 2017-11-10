# Base Io build system
# Written by there.exists.teslos<there.exists.teslos.gmail.com>
#
# Find ODE Open Dynamics Engine
find_path(ODE_INCLUDE_DIR ode/ode.h
    /usr/include
    /usr/local/include
)

set(ODE_NAMES ${ODE_NAMES} ode libode)
find_library(ODE_LIBRARY NAMES ${ODE_NAMES} PATH)

if(ODE_INCLUDE_DIR)
    message(STATUS "Found ODE include dir: ${ODE_INCLUDE_DIR}")
else(ODE_INCLUDE_DIR)
    message(STATUS "Couldn't find ODE include dir: ${ODE_INCLUDE_DIR}")
endif(ODE_INCLUDE_DIR)

if(ODE_LIBRARY)
    message(STATUS "Found ODE library: ${ODE_LIBRARY}")
else(ODE_LIBRARY)
    message(STATUS "Couldn't find ODE library: ${ODE_LIBRARY}")
endif(ODE_LIBRARY)

if(ODE_INCLUDE_DIR AND ODE_LIBRARY)
  set(ODE_FOUND TRUE CACHE STRING "Whether ODE was found or not")
endif(ODE_INCLUDE_DIR AND ODE_LIBRARY)

if(ODE_FOUND)
    message(STATUS "Looking for Open Dynamics Engine - found")
    set(CMAKE_C_FLAGS "-DdSINGLE")
    set(HAVE_ODE true)
    include(IgnImportTarget)
    ign_import_target(FreeImage)
  if(NOT ODE_FIND_QUIETLY)
    message(STATUS "Found ODE: ${ODE_LIBRARY}")
  endif(NOT ODE_FIND_QUIETLY)
else(ODE_FOUND)
  if(ODE_FIND_REQUIRED)
    message(FATAL_ERROR "Could not find ODE")
  endif(ODE_FIND_REQUIRED)
endif(ODE_FOUND)
