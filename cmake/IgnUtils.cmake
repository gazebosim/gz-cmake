
#################################################
# ign_find_package(<PACKAGE_NAME> [REQUIRED] [EXACT] [QUIET] [PRIVATE] [BUILD_ONLY] [PKGCONFIG_IGNORE]
#                  [VERSION <ver>]
#                  [EXTRA_ARGS <args>]
#                  [PRETTY <name>]
#                  [PKGCONFIG <pkgconfig_name>]
#                  [PKGCONFIG_LIB <lib_name>]
#                  [PKGCONFIG_VER_COMPARISON <|>|=|<=|>=]
#                  [PURPOSE <"explanation for this dependency">])
#
# This is a wrapper for the standard cmake find_package which behaves according
# to the conventions of the ignition library. In particular, we do not quit
# immediately when a required package is missing. Instead, we check all
# dependencies and provide an overview of what is missing at the end of the
# configuration process. Descriptions of the function arguments are as follows:
#
# <PACKAGE_NAME>: The name of the package as it would normally be passed to
#                 find_package(~). Note if your package corresponds to a
#                 find-module named FindABC.cmake, then <PACKAGE_NAME> must be
#                 ABC, with the case matching. If the find-module is named
#                 FindAbc.cmake, then <PACKAGE_NAME> must be Abc. This will not
#                 necessarily match the library's actual name, nor will it
#                 necessarily match the name used by pkgconfig, so there are
#                 additional arguments (i.e. PRETTY, PKGCONFIG) to specify
#                 alternative names for this package that can be used depending
#                 on the context.
#
# [REQUIRED]: Optional. If provided, this will trigger an ignition build_error.
#             If not provided, this will trigger an ignition build_warning.
#
# [EXACT]: Optional. This will pass on the EXACT option to find_package(~) and
#          also add it to the call to find_dependency(~) in the
#          <project>-config.cmake file.
#
# [QUIET]: Optional. If provided, it will be passed forward to cmake's
#          find_package(~) command. This function will still print its normal
#          output.
#
# [PRIVATE]: Optional. Use this to indicate that consumers of the project do not
#            need to link against this package, but it must be present on the
#            system, because our project must link against it.
#
# [BUILD_ONLY]: Optional. Use this to indicate that the project only needs this
#               package while building, and it does not need to be available to
#               the consumer of this project at all. Normally this should only
#               apply to a header-only library whose headers are included
#               exclusively in the source files and not included in any public
#               (i.e. installed) project headers.
#
# [PKGCONFIG_IGNORE]: Discouraged. If this option is provided, this package will
#                     not be added to the project's pkgconfig file in any way.
#                     This should only be used in very rare circumstances.
#
# [VERSION]: Optional. Follow this argument with the major[.minor[.patch[.tweak]]]
#            version that you need for this package.
#
# [EXTRA_ARGS]: Optional. Additional args to pass forward to find_package(~)
#
# [PRETTY]: Optional. If provided, the string that follows will replace
#           <PACKAGE_NAME> when printing messages, warnings, or errors to the
#           terminal.
#
# [PKGCONFIG]: Optional. If provided, the string that follows will be used to
#              specify a "required" package for pkgconfig. If not provided, then
#              <PACKAGE_NAME> will be used instead.
#
# [PKGCONFIG_LIB]: Optional. Use this to indicate that the package should be
#                  considered a "library" by pkgconfig. This is used for
#                  libraries which do not come with *.pc metadata, such as
#                  system libraries, libm, libdl, or librt. Generally you should
#                  leave this out, because most packages will be considered
#                  "modules" by pkgconfig, which is how we will treat the
#                  package by default. The string which follows this argument
#                  will be used as the library name, and the string that follows
#                  a PKGCONFIG argument will be ignored, so the PKGCONFIG
#                  argument can be left out when using this argument.
#
# [PKGCONFIG_VER_COMPARISON]: Optional. If provided, pkgconfig will be told how
#                             the available version of this package must compare
#                             to the specified version. Acceptable values are
#                             =, <, >, <=, >=. Default will be =. If no version
#                             is provided using VERSION, then this will be left
#                             out, whether or not it is provided.
#
# [PURPOSE]: Optional. If provided, the string that follows will be appended to
#            the build_warning or build_error that this function produces when
#            the package could not be found.
#
macro(ign_find_package PACKAGE_NAME)

  #------------------------------------
  # Define the expected arguments
  set(options REQUIRED EXACT QUIET PRIVATE BUILD_ONLY)
  set(oneValueArgs VERSION PRETTY PURPOSE EXTRA_ARGS PKGCONFIG PKGCONFIG_LIB PKGCONFIG_VER_COMPARISON)
  set(multiValueArgs) # We are not using multiValueArgs yet

  #------------------------------------
  # Parse the arguments
  cmake_parse_arguments(ign_find_package "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  #------------------------------------
  # Construct the arguments to pass to find_package
  if(ign_find_package_VERSION)
    list(APPEND ${PACKAGE_NAME}_find_package_args ${ign_find_package_VERSION})
  endif()

  if(ign_find_package_QUIET)
    list(APPEND ${PACKAGE_NAME}_find_package_args QUIET)
  endif()

  if(ign_find_package_EXACT)
    list(APPEND ${PACKAGE_NAME}_find_package_args EXACT)
  endif()

  if(ign_find_package_EXTRA_ARGS)
    list(APPEND ${PACKAGE_NAME}_find_package_args ${ign_find_package_EXTRA_ARGS})
  endif()

  #------------------------------------
  # Figure out which name to print
  if(ign_find_package_PRETTY)
    set(${PACKAGE_NAME}_pretty ${ign_find_package_PRETTY})
  else()
    set(${PACKAGE_NAME}_pretty ${PACKAGE_NAME})
  endif()


  #------------------------------------
  # Call find_package with the provided arguments
  find_package(${PACKAGE_NAME} ${${PACKAGE_NAME}_find_package_args})
  if(${PACKAGE_NAME}_FOUND)

    message(STATUS "Looking for ${${PACKAGE_NAME}_pretty} - found\n")

  else()

    message(STATUS "Looking for ${${PACKAGE_NAME}_pretty} - not found\n")

    #------------------------------------
    # Construct the warning/error message to produce
    set(${PACKAGE_NAME}_msg "Missing: ${${PACKAGE_NAME}_pretty}")
    if(DEFINED ign_find_package_PURPOSE)
      set(${PACKAGE_NAME}_msg "${${PACKAGE_NAME}_msg} - ${ign_find_package_PURPOSE}")
    endif()

    #------------------------------------
    # Produce an error if the package is required, or a warning if it is not
    if(ign_find_package_REQUIRED)
      ign_build_error(${${PACKAGE_NAME}_msg})
    else()
      ign_build_warning(${${PACKAGE_NAME}_msg})
    endif()
  endif()


  #------------------------------------
  # Add this package to the list of dependencies that will be inserted into the
  # find-config file, unless the invoker specifies that it should not be added.
  # Also, add this package or library as an entry to the pkgconfig file that we
  # will produce for our project.
  if(ign_find_package_REQUIRED AND NOT ign_find_package_BUILD_ONLY)

    # Set up the arguments we want to pass to the find_dependency invokation for
    # our ignition project. We always need to pass the name of the dependency.
    set(${PACKAGE_NAME}_dependency_args ${PACKAGE_NAME})

    # If a version is provided here, we should pass that as well.
    if(ign_find_package_VERSION)
      ign_string_append(${PACKAGE_NAME}_dependency_args ${ign_find_package_VERSION})
    endif()

    # If we have specified the exact version, we should provide that as well.
    if(ign_find_package_EXACT)
      ign_string_append(${PACKAGE_NAME}_dependency_args EXACT)
    endif()

    list(APPEND PROJECT_CMAKE_DEPENDENCIES "${${PACKAGE_NAME}_dependency_args}")

    #------------------------------------
    # Add this library or project to its relevant pkgconfig entry, unless we
    # have been explicitly instructed to ignore it.
    if(NOT ign_find_package_PKGCONFIG_IGNORE)
      # Create the string that will be used as this library or package's entry
      # in the pkgconfig file.
      if(ign_find_package_PKGCONFIG_LIB)
        # Libraries must be prepended with -l
        set(${PACKAGE_NAME}_pkgconfig_entry "-l${ign_find_package_PKGCONFIG_LIB}")
      elseif(ign_find_package_PKGCONFIG)
        # Modules (a.k.a. packages) can just be provided with the name
        set(${PACKAGE_NAME}_pkgconfig_entry "${ign_find_package_PKGCONFIG}")
      else()
        set(${PACKAGE_NAME}_pkgconfig_entry "${PACKAGE_NAME}")
      endif()

      # Add the version requirements to the entry.
      if(ign_find_package_VERSION)
        # Note, specifying the version is not supported for library dependencies.
        # It is only supported for packages, a.k.a. modules.
        if(NOT ign_find_package_PKGCONFIG_LIB)
          set(comparison "=")
          if(ign_find_package_PKGCONFIG_VER_COMPARISON)
            set(comparison ${ign_find_package_PKGCONFIG_VER_COMPARISON})
          endif()
          set(${PACKAGE_NAME}_pkgconfig_entry "${${PACKAGE_NAME}_pkgconfig_entry} ${comparison} ${ign_find_package_VERSION}")
        endif()
      endif()

      #------------------------------------
      # Figure out what type of entry this should be for pkgconfig
      set(${PACKAGE_NAME}_pkgconfig_type)
      if(ign_find_package_PKGCONFIG_LIB)
        # If we have a "library", use PROJECT_PKGCONFIG_LIB
        set(${PACKAGE_NAME}_pkgconfig_type PROJECT_PKGCONFIG_LIBS)
      else()
        # If we have a "module", use PROJECT_PKGCONFIG_REQUIRES
        set(${PACKAGE_NAME}_pkgconfig_type PROJECT_PKGCONFIG_REQUIRES)
      endif()

      if(ign_find_package_PRIVATE)
        # If this is a private library or module, add the _PRIVATE suffix
        set(${PACKAGE_NAME}_pkgconfig_type ${${PACKAGE_NAME}_pkgconfig_type}_PRIVATE)
      endif()

      # Append the entry as a string onto whichever type we selected
      set(${${PACKAGE_NAME}_pkgconfig_type} "${${${PACKAGE_NAME}_pkgconfig_type}} ${${PACKAGE_NAME}_pkgconfig_entry}")

    endif()
  endif()

endmacro()

#################################################
# Macro to turn a list into a string (why doesn't CMake have this built-in?)
macro(ign_list_to_string _string _list)
    set(${_string})
    foreach(_item ${_list})
      set(${_string} "${${_string}} ${_item}")
    endforeach(_item)
    #string(STRIP ${${_string}} ${_string})
endmacro()

#################################################
# Macro to append a value to a string
macro(ign_string_append output_var val)

  set(${output_var} "${${output_var}} ${val}")

endmacro()

#################################################
# ign_get_sources_and_unittests(<lib_srcs> <tests>)
#
# From the current directory, grab all the files ending in "*.cc" and sort them
# into library source files <lib_srcs> and unittest source files <tests>. Remove
# their paths to make them suitable for passing into ign_add_[library/tests].
function(ign_get_libsources_and_unittests lib_sources_var tests_var)

  # GLOB all the source files
  file(GLOB source_files "*.cc")
  list(SORT source_files)

  # GLOB all the unit tests
  file(GLOB test_files "*_TEST.cc")
  list(SORT test_files)

  # Initialize these lists
  set(tests)
  set(sources)

  # Remove the unit tests from the list of source files
  foreach(test_file ${test_files})

    list(REMOVE_ITEM source_files ${test_file})

    # Remove the path from the unit test and append to the list of tests.
    get_filename_component(test ${test_file} NAME)
    list(APPEND tests ${test})

  endforeach()

  foreach(source_file ${source_files})

    # Remove the path from the library source file and append it to the list of
    # library source files.
    get_filename_component(source ${source_file} NAME)
    list(APPEND sources ${source})

  endforeach()

  # Return the lists that have been created.
  set(${lib_sources_var} ${sources} PARENT_SCOPE)
  set(${tests_var} ${tests} PARENT_SCOPE)

endfunction()

#################################################
# ign_get_sources(<sources>)
#
# From the current directory, grab all the source files and place them into
# <sources>. Remove their paths to make them suitable for passing into
# ign_add_[library/tests].
function(ign_get_sources sources_var)

  # GLOB all the source files
  file(GLOB source_files "*.cc")
  list(SORT source_files)

  # Initialize this list
  set(sources)

  foreach(source_file ${source_files})

    # Remove the path from the source file and append it the list of soures
    get_filename_component(source ${source_file} NAME)
    list(APPEND sources ${source})

  endforeach()

  # Return the list that has been created
  set(${sources_var} ${sources} PARENT_SCOPE)

endfunction()

#################################################
# ign_install_all_headers(
#   [ADDITIONAL_DIRS <dirs>]
#   [EXCLUDE <excluded_headers>])
#
# From the current directory, install all header files, including files from the
# "detail" subdirectory. You can optionally specify additional directories
# (besides detail) to also install. You may also specify header files to
# exclude from the installation. This will accept all files ending in *.h and
# *.hh. You may append an additional suffix (like .old or .backup) to prevent
# a file from being included here.
#
# This will also run configure_file on ign_auto_headers.hh.in and config.hh.in
# and install both of them.
function(ign_install_all_headers)

  #------------------------------------
  # Define the expected arguments
  set(options) # We are not using options yet
  set(oneValueArgs) # We are not using oneValueArgs yet
  set(multiValueArgs ADDITIONAL_DIRS EXCLUDE)

  #------------------------------------
  # Parse the arguments
  cmake_parse_arguments(ign_install_all_headers "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  #------------------------------------
  # Build list of directories
  set(dir_list "." "detail" ${ign_install_all_headers_ADDITIONAL_DIRS})

  #------------------------------------
  # Grab the excluded files
  set(excluded ${ign_install_all_headers_EXCLUDE})

  #------------------------------------
  # Initialize the string of all headers
  set(ign_headers)

  #------------------------------------
  # Install all the non-excluded headers
  foreach(dir ${dir_list})

    # GLOB all the header files in dir
    file(GLOB header_files "${dir}/*.h" "${dir}/*.hh")
    list(SORT header_files)

    # Replace full paths with relative paths
    set(headers)
    foreach(header_file ${header_files})

      get_filename_component(header ${header_file} NAME)
      if("." STREQUAL ${dir})
        list(APPEND headers ${header})
      else()
        list(APPEND headers ${dir}/${header})
      endif()

    endforeach()

    # Remove the excluded headers
    if(headers)
      foreach(exclude ${excluded})
        list(REMOVE_ITEM headers ${exclude})
      endforeach()
    endif()

    # Add each header, prefixed by its directory, to the auto headers variable
    foreach(header ${headers})
      set(ign_headers "${ign_headers}#include <ignition/${IGN_DESIGNATION}/${header}>\n")
    endforeach()

    if("." STREQUAL ${dir})
      set(destination "${IGN_INCLUDE_INSTALL_DIR_FULL}/ignition/${IGN_DESINATION}")
    else()
      set(destination "${IGN_INCLUDE_INSTALL_DIR_FULL}/ignition/${IGN_DESINATION}/${dir}")
    endif()

    install(
      FILES ${headers}
      DESTINATION ${destination}
      COMPONENT headers)

  endforeach()

  # Define the install directory for the meta headers
  set(meta_header_install_dir ${IGN_INCLUDE_INSTALL_DIR_FULL}/ignition/${IGN_DESIGNATION})

  # Define the input/output of the configuration for the "master" header
  set(master_header_in ${IGNITION_CMAKE_DIR}/ign_auto_headers.hh.in)
  set(master_header_out ${CMAKE_CURRENT_BINARY_DIR}/${IGN_DESIGNATION}.hh)

  # Generate the "master" header that includes all of the headers
  configure_file(${master_header_in} ${master_header_out})

  # Install the "master" header
  install(
    FILES ${master_header_out}
    DESTINATION ${meta_header_install_dir}
    COMPONENT headers)

  # Define the input/output of the configuration for the "config" header
  set(config_header_in ${CMAKE_CURRENT_SOURCE_DIR}/config.hh.in)
  set(config_header_out ${CMAKE_CURRENT_BINARY_DIR}/config.hh)

  # Generate the "config" header that describes our project configuration
  configure_file(${config_header_in} ${config_header_out})

  # Install the "config" header
  install(
    FILES ${config_header_out}
    DESTINATION ${meta_header_install_dir}
    COMPONENT headers)

endfunction()


#################################################
# ign_build_error macro
macro(ign_build_error)
  foreach(str ${ARGN})
    set(msg "\t${str}")
    list(APPEND build_errors ${msg})
  endforeach()
endmacro(ign_build_error)

#################################################
# ign_build_warning macro
macro(ign_build_warning)
  foreach(str ${ARGN})
    set(msg "\t${str}" )
    list(APPEND build_warnings ${msg})
  endforeach(str ${ARGN})
endmacro(ign_build_warning)

#################################################
macro(ign_add_library _name)

  set(LIBS_DESTINATION ${PROJECT_BINARY_DIR}/src)
  set_source_files_properties(${ARGN} PROPERTIES COMPILE_DEFINITIONS "BUILDING_DLL")
  add_library(${_name} SHARED ${ARGN})

endmacro()

#################################################
macro(ign_add_static_library _name)
  add_library(${_name} STATIC ${ARGN})
  target_link_libraries(${_name} ${general_libraries})
endmacro()

#################################################
macro(ign_add_executable _name)
  add_executable(${_name} ${ARGN})
  target_link_libraries(${_name} ${general_libraries})
endmacro()

#################################################
# ign_target_public_include_directories(<target> [include_targets])
#
# Add the INTERFACE_INCLUDE_DIRECTORIES of [include_targets] to the public
# INCLUDE_DIRECTORIES of <target>. This allows us to propagate the include
# directories of <target> along to any other libraries that depend on it.
#
# You MUST pass in targets to include, not directory names. We must not use
# explicit directory names here if we want our package to be relocatable.
function(ign_target_interface_include_directories name)

  foreach(include_target ${ARGN})
    target_include_directories(
      ${name} PUBLIC
      $<TARGET_PROPERTY:${include_target},INTERFACE_INCLUDE_DIRECTORIES>)
  endforeach()

endfunction()

#################################################
macro(ign_install_includes _subdir)
  install(FILES ${ARGN}
    DESTINATION ${IGN_INCLUDE_INSTALL_DIR}/${_subdir} COMPONENT headers)
endmacro()

#################################################
macro(ign_install_library)

  if(${ARGC} GREATER 0)
    message(WARNING "Warning to the developer: ign_install_library no longer "
                    "accepts any arguments. Please remove them from your call.")
  endif()

  set_target_properties(
    ${PROJECT_LIBRARY_TARGET_NAME}
    PROPERTIES
      SOVERSION ${PROJECT_VERSION_MAJOR}
      VERSION ${PROJECT_VERSION_FULL})

  install(
    TARGETS ${PROJECT_LIBRARY_TARGET_NAME}
    EXPORT ${PROJECT_EXPORT_NAME}
    ARCHIVE DESTINATION ${IGN_LIB_INSTALL_DIR}
    LIBRARY DESTINATION ${IGN_LIB_INSTALL_DIR}
    COMPONENT shlib)

endmacro()

#################################################
macro(ign_install_executable _name )
  set_target_properties(${_name} PROPERTIES VERSION ${PROJECT_VERSION_FULL})
  install (TARGETS ${_name} DESTINATION ${IGN_BIN_INSTALL_DIR})
  manpage(${_name} 1)
endmacro()



# This should be migrated to more fine control solution based on set_property APPEND
# directories. It's present on cmake 2.8.8 while precise version is 2.8.7
link_directories(${PROJECT_BINARY_DIR}/test)
include_directories("${PROJECT_SOURCE_DIR}/test/gtest/include")

#################################################
# Enable tests compilation by default
if (NOT DEFINED ENABLE_TESTS_COMPILATION)
  set (ENABLE_TESTS_COMPILATION True)
endif()

#################################################
# Macro to setup supported compiler warnings
# Based on work of Florent Lamiraux, Thomas Moulard, JRL, CNRS/AIST.
include(CheckCXXCompilerFlag)

macro(ign_filter_valid_compiler_options var)
  # Store the current setting for CMAKE_REQUIRED_QUIET
  set(original_cmake_required_quiet ${CMAKE_REQUIRED_QUIET})

  # Make these tests quiet so they don't pollute the cmake output
  set(CMAKE_REQUIRED_QUIET true)

  foreach(flag ${ARGN})
    CHECK_CXX_COMPILER_FLAG(${flag} result${flag})
    if(result${flag})
      set(${var} "${${var}} ${flag}")
    endif()
  endforeach()

  # Restore the old setting for CMAKE_REQUIRED_QUIET
  set(CMAKE_REQUIRED_QUIET ${original_cmake_required_quiet})
endmacro()
