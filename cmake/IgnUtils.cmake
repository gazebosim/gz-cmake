
#################################################
# ign_find_package(<PACKAGE_NAME>
#                  [REQUIRED] [EXACT] [QUIET] [PRIVATE] [BUILD_ONLY] [PKGCONFIG_IGNORE]
#                  [VERSION <ver>]
#                  [EXTRA_ARGS <args>]
#                  [PRETTY <name>]
#                  [PURPOSE <"explanation for this dependency">]
#                  [PKGCONFIG <pkgconfig_name>]
#                  [PKGCONFIG_LIB <lib_name>]
#                  [PKGCONFIG_VER_COMPARISON <|>|=|<=|>=])
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
# [REQUIRED]: Optional. If provided, macro will trigger an ignition build_error
#             when the package cannot be found. If not provided, this macro will
#             trigger an ignition build_warning when the package is not found.
#
# [EXACT]: Optional. This will pass on the EXACT option to find_package(~) and
#          also add it to the call to find_dependency(~) in the
#          <project>-config.cmake file.
#
# [QUIET]: Optional. If provided, it will be passed forward to cmake's
#          find_package(~) command. This macro will still print its normal
#          output.
#
# [PRIVATE]: Optional. Use this to indicate that consumers of the project do not
#            need to link against the package, but it must be present on the
#            system, because our project must link against it.
#
# [BUILD_ONLY]: Optional. Use this to indicate that the project only needs this
#               package while building, and it does not need to be available to
#               the consumer of this project at all. Normally this should only
#               apply to (1) a header-only library whose headers are included
#               exclusively in the source files and not included in any public
#               (i.e. installed) project headers, or to (2) a static library
#               dependency.
#
# [PKGCONFIG_IGNORE]: Discouraged. If this option is provided, this package will
#                     not be added to the project's pkgconfig file in any way.
#                     This should only be used in very rare circumstances. Note
#                     that BUILD_ONLY will also prevent a pkgconfig entry from
#                     being produced.
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
# [PURPOSE]: Optional. If provided, the string that follows will be appended to
#            the build_warning or build_error that this function produces when
#            the package could not be found.
#
#  ==========================================================================
#  The following arguments pertain to the automatic generation of your
#  project's pkgconfig file. Ideally, this information should be provided
#  automatically by ignition-cmake through the cmake find-module that is written
#  for your dependency. However, if your package gets distributed with its own
#  cmake config-file or find-module, then it might not automatically set this
#  information. Therefore, we provide the ability to set it through your call to
#  ign_find_package(~). Do not hesitate to ask for help if you need to use these
#  arguments.
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
#                  "modules" by pkgconfig. The string which follows this argument
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

    ign_string_append(PROJECT_CMAKE_DEPENDENCIES "find_dependency(${${PACKAGE_NAME}_dependency_args})" DELIM "\n")

    #------------------------------------
    # Add this library or project to its relevant pkgconfig entry, unless we
    # have been explicitly instructed to ignore it.
    if(NOT ign_find_package_PKGCONFIG_IGNORE)

      # Here we will set up the pkgconfig entry for this package. Ordinarily,
      # these variables should be set by ign_pkg_check_modules[_quiet]. However,
      # that might not be available for third-party dependencies that provide
      # their own find-module or cmake config-module. Therefore, we provide the
      # option of specifying pkgconfig information through the call to
      # ign_find_package.

      # If the caller has specified the arguments PKGCONFIG_LIB or PKGCONFIG,
      # then we will overwrite these pkgconfig variables with the information
      # provided by the caller.
      if(ign_find_package_PKGCONFIG_LIB)
        # Libraries must be prepended with -l
        set(${PACKAGE_NAME}_PKGCONFIG_ENTRY "-l${ign_find_package_PKGCONFIG_LIB}")
        set(${PACKAGE_NAME}_PKGCONFIG_TYPE PROJECT_PKGCONFIG_LIBS)
      elseif(ign_find_package_PKGCONFIG)
        # Modules (a.k.a. packages) can just be provided with the name
        set(${PACKAGE_NAME}_PKGCONFIG_ENTRY "${ign_find_package_PKGCONFIG}")
        set(${PACKAGE_NAME}_PKGCONFIG_TYPE PROJECT_PKGCONFIG_REQUIRES)

        # Add the version requirements to the entry.
        if(ign_find_package_VERSION)
          # Use equivalency by default
          set(comparison "=")

          # If the caller has specified a version comparison operator, use that
          # instead of equivalency.
          if(ign_find_package_PKGCONFIG_VER_COMPARISON)
            set(comparison ${ign_find_package_PKGCONFIG_VER_COMPARISON})
          endif()

          # Append the comparison and the version onto the pkgconfig entry
          set(${PACKAGE_NAME}_PKGCONFIG_ENTRY "${${PACKAGE_NAME}_PKGCONFIG_ENTRY} ${comparison} ${ign_find_package_VERSION}")

        endif()

      endif()

      if(ign_find_package_PRIVATE)
        # If this is a private library or module, add the _PRIVATE suffix
        set(${PACKAGE_NAME}_PKGCONFIG_TYPE ${${PACKAGE_NAME}_PKGCONFIG_TYPE}_PRIVATE)
      endif()

      # Append the entry as a string onto whichever type we selected
      set(${${PACKAGE_NAME}_PKGCONFIG_TYPE} "${${${PACKAGE_NAME}_PKGCONFIG_TYPE}} ${${PACKAGE_NAME}_PKGCONFIG_ENTRY}")

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
# ign_string_append(<output_var> <value_to_append> [DELIM <delimiter>])
#
# <output_var>: The name of the string variable that should be appended to
#
# <value_to_append>: The value that should be appended to the string
#
# [DELIM]: Specify a delimiter to separate the contents with. Default value is a
#          space
#
# Macro to append a value to a string
macro(ign_string_append output_var val)

  #------------------------------------
  # Define the expected arguments
  set(options) # We are not using options yet
  set(oneValueArgs DELIM)
  set(multiValueArgs) # We are not using multiValueArgs yet

  #------------------------------------
  # Parse the arguments
  cmake_parse_arguments(ign_string_append "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if(ign_string_append_DELIM)
    set(delim "${ign_string_append_DELIM}")
  else()
    set(delim " ")
  endif()

  set(${output_var} "${${output_var}}${delim}${val}")

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
#   [EXCLUDE <excluded_headers>]
#   [GENERATED_HEADERS <headers>])
#
# From the current directory, install all header files, including files from the
# "detail" subdirectory. You can optionally specify additional directories
# (besides detail) to also install. You may also specify header files to
# exclude from the installation. This will accept all files ending in *.h and
# *.hh. You may append an additional suffix (like .old or .backup) to prevent
# a file from being included here.
#
# GENERATED_HEADERS should be generated headers which should be included by
# ${IGN_DESIGNATION}.hh. This will only add them to the header, it will not
# generate or install them.
#
# This will also run configure_file on ign_auto_headers.hh.in and config.hh.in
# and install both of them.
function(ign_install_all_headers)

  #------------------------------------
  # Define the expected arguments
  set(options) # We are not using options yet
  set(oneValueArgs) # We are not using oneValueArgs yet
  set(multiValueArgs ADDITIONAL_DIRS EXCLUDE GENERATED_HEADERS)

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
      set(destination "${IGN_INCLUDE_INSTALL_DIR_FULL}/ignition/${IGN_DESIGNATION}")
    else()
      set(destination "${IGN_INCLUDE_INSTALL_DIR_FULL}/ignition/${IGN_DESIGNATION}/${dir}")
    endif()

    install(
      FILES ${headers}
      DESTINATION ${destination}
      COMPONENT headers)

  endforeach()

  # Add generated headers to the list of includes
  foreach(header ${ign_install_all_headers_GENERATED_HEADERS})
      set(ign_headers "${ign_headers}#include <ignition/${IGN_DESIGNATION}/${header}>\n")
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
    DESTINATION ${meta_header_install_dir}/..
    COMPONENT headers)

  # Define the input/output of the configuration for the "config" header
  set(config_header_in ${CMAKE_CURRENT_SOURCE_DIR}/config.hh.in)
  set(config_header_out ${CMAKE_CURRENT_BINARY_DIR}/config.hh)

  if(NOT EXISTS ${config_header_in})
    message(FATAL_ERROR
      "Developer error: You are missing the file [${config_header_in}]! "
      "Did you forget to move it from your project's cmake directory while "
      "migrating to the use of ignition-cmake?")
  endif()

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
macro(ign_add_library lib_name)

  set(LIBS_DESTINATION ${PROJECT_BINARY_DIR}/src)
  add_library(${lib_name} ${ARGN})

  if(IGN_ADD_fPIC_TO_LIBRARIES)
    target_compile_options(${lib_name} PRIVATE -fPIC)
  endif()

  # This generator expression is necessary for multi-configuration generators,
  # such as MSVC on Windows, and also to ensure that our target exports the
  # headers correctly
  target_include_directories(${lib_name}
    PUBLIC
      # This is the publicly installed ignition/math headers directory.
      $<INSTALL_INTERFACE:${IGN_INCLUDE_INSTALL_DIR_FULL}>
      # This is the build directory version of the headers. When exporting the
      # target, this will not be included, because it is tied to the build
      # interface instead of the install interface.
      $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>)

  set(binary_include_dir
    "${CMAKE_BINARY_DIR}/include/ignition/${IGN_DESIGNATION_LOWER}")

  set(implementation_file_name "${binary_include_dir}/detail/Export.hh")

  include(GenerateExportHeader)
  # This macro will generate a header called detail/Export.hh which implements
  # some C-macros that are useful for exporting our libraries. The
  # implementation header does not provide any commentary or explanation for its
  # macros, so we tuck it away in the detail/ subdirectory, and then provide a
  # public-facing header that provides commentary for the macros.
  generate_export_header(${lib_name}
    BASE_NAME ${PROJECT_NAME_NO_VERSION_UPPER}
    EXPORT_FILE_NAME ${implementation_file_name}
    EXPORT_MACRO_NAME DETAIL_IGNITION_${IGN_DESIGNATION_UPPER}_VISIBLE
    NO_EXPORT_MACRO_NAME DETAIL_IGNITION_${IGN_DESIGNATION_UPPER}_HIDDEN
    DEPRECATED_MACRO_NAME IGN_DEPRECATED_ALL_VERSIONS)

  set(install_include_dir
    "${IGN_INCLUDE_INSTALL_DIR_FULL}/ignition/${IGN_DESIGNATION}")

  # Configure the installation of the automatically generated file.
  install(
    FILES "${implementation_file_name}"
    DESTINATION "${install_include_dir}/detail"
    COMPONENT headers)

  # Configure the public-facing header for exporting and deprecating. This
  # header provides commentary for the macros so that developers can know their
  # purpose.
  configure_file(
    "${IGNITION_CMAKE_DIR}/Export.hh.in"
    "${binary_include_dir}/Export.hh")

  # Configure the installation of the public-facing header.
  install(
    FILES "${binary_include_dir}/Export.hh"
    DESTINATION "${install_include_dir}"
    COMPONENT headers)

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
# ign_target_interface_include_directories(<target> [include_targets])
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
    LIBRARY DESTINATION ${IGN_LIB_INSTALL_DIR}
    ARCHIVE DESTINATION ${IGN_LIB_INSTALL_DIR}
    RUNTIME DESTINATION ${IGN_LIB_INSTALL_DIR}
    COMPONENT shlib)

endmacro()

#################################################
macro(ign_install_executable _name )
  set_target_properties(${_name} PROPERTIES VERSION ${PROJECT_VERSION_FULL})
  install (TARGETS ${_name} DESTINATION ${IGN_BIN_INSTALL_DIR})
  manpage(${_name} 1)
endmacro()

#################################################
# Macro to setup supported compiler warnings
# Based on work of Florent Lamiraux, Thomas Moulard, JRL, CNRS/AIST.
macro(ign_filter_valid_compiler_options var)

  include(CheckCXXCompilerFlag)
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

#################################################
# ign_build_executables(SOURCES <sources>
#                       [PREFIX <prefix>]
#                       [LIB_DEPS <library_dependencies>]
#                       [INCLUDE_DIRS <include_dependencies>]
#                       [EXEC_LIST <output_var>]
#                       [EXCLUDE_PROJECT_LIB])
#
# Build executables for an ignition project. Arguments are as follows:
#
# SOURCES: Required. The names (without a path) of the source files for your
#          executables.
#
# PREFIX: Optional. This will append <prefix> onto each executable name.
#
# LIB_DEPS: Optional. Additional library dependencies that every executable
#           should link to, not including the library build by this project (it
#           will be linked automatically, unless you pass in the
#           EXCLUDE_PROJECT_LIB option).
#
# INCLUDE_DIRS: Optional. Additional include directories that should be visible
#               to all of these executables.
#
# EXEC_LIST: Optional. Provide a variable which will be given the list of the
#            names of the executables generated by this macro. These will also
#            be the names of the targets.
#
# EXCLUDE_PROJECT_LIB: Pass this argument if you do not want your executables to
#                      link to your project's main library. On Windows, this
#                      will also skip the step of copying the runtime library
#                      into your executable's directory.
#
macro(ign_build_executables)

  #------------------------------------
  # Define the expected arguments
  set(options EXCLUDE_PROJECT_LIB)
  set(oneValueArgs PREFIX EXEC_LIST)
  set(multiValueArgs SOURCES LIB_DEPS INCLUDE_DIRS)

  if(ign_build_executables_EXEC_LIST)
    set(${ign_build_executables_EXEC_LIST} "")
  endif()


  #------------------------------------
  # Parse the arguments
  cmake_parse_arguments(ign_build_executables "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  foreach(exec_file ${ign_build_executables_SOURCES})

    string(REGEX REPLACE ".cc" "" BINARY_NAME ${exec_file})
    set(BINARY_NAME ${ign_build_executables_PREFIX}${BINARY_NAME})

    add_executable(${BINARY_NAME} ${exec_file})

    if(ign_build_executables_EXEC_LIST)
      list(APPEND ${ign_build_executables_EXEC_LIST} ${BINARY_NAME})
    endif()

    if(NOT ign_build_executables_EXCLUDE_PROJECT_LIB)
      target_link_libraries(${BINARY_NAME} ${PROJECT_LIBRARY_TARGET_NAME})
    endif()

    if(ign_build_executables_LIB_DEPS)
      target_link_libraries(${BINARY_NAME} ${ign_build_executables_LIB_DEPS})
    endif()

    target_include_directories(${BINARY_NAME}
      PRIVATE
        ${PROJECT_SOURCE_DIR}
        ${PROJECT_SOURCE_DIR}/include
        ${PROJECT_BINARY_DIR}
        ${PROJECT_BINARY_DIR}/include
        ${ign_build_executables_INCLUDE_DIRS})

      if(WIN32 AND NOT ign_build_executables_EXCLUDE_PROJECT_LIB)

        # If we have not installed our project's library yet, then it will not
        # be visible to the executable when we attempt to run it. Therefore, we
        # place a copy of our project's library into the directory that contains
        # the executable. We do not need to do this for any of the test's other
        # dependencies, because the fact that they were found by the build
        # system means they are installed and should be visible when the test is
        # run.

        # Get the full file path to the original dll for this project
        set(dll_original "$<TARGET_FILE:${PROJECT_LIBRARY_TARGET_NAME}>")

        # Get the full file path for where we need to paste the dll for this project
        set(dll_target "$<TARGET_FILE_DIR:${BINARY_NAME}>/$<TARGET_FILE_NAME:${PROJECT_LIBRARY_TARGET_NAME}>")

        # Add the copy_if_different command as a custom command that is tied the target
        # of this test.
        add_custom_command(
          TARGET ${BINARY_NAME}
          COMMAND ${CMAKE_COMMAND}
          ARGS -E copy_if_different ${dll_original} ${dll_target}
          VERBATIM)

      endif()

  endforeach()

endmacro()

#################################################
# ign_build_tests(TYPE <test_type>
#                 SOURCES <sources>
#                 [LIB_DEPS <library_dependencies>]
#                 [INCLUDE_DIRS <include_dependencies>]
#                 [TEST_LIST <output_var>])
#
# Build tests for an ignition project. Arguments are as follows:
#
# TYPE: Required. Preferably UNIT, INTEGRATION, PERFORMANCE, or REGRESSION.
#
# SOURCES: Required. The names (without the path) of the source files for your
#          tests. Each file will turn into a test.
#
# LIB_DEPS: Optional. Additional library dependencies that every test should
#           link to, not including the library built by this project (it will be
#           linked automatically). gtest and gtest_main will also be linked.
#
# INCLUDE_DIRS: Optional. Additional include directories that should be visible
#               to all the tests of this type.
#
# TEST_LIST: Optional. Provide a variable which will be given the list of the
#            names of the tests generated by this macro. These will also be the
#            names of the targets.
#
macro(ign_build_tests)

  #------------------------------------
  # Define the expected arguments
  set(options)
  set(oneValueArgs TYPE)
  set(multiValueArgs SOURCES LIB_DEPS INCLUDE_DIRS)

  #------------------------------------
  # Parse the arguments
  cmake_parse_arguments(ign_build_tests "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if(NOT ign_build_tests_TYPE)
    # If you have encountered this error, you are probably migrating to the
    # new ignition-cmake system. Be sure to also provide a SOURCES argument
    # when calling ign_build_tests.
    message(FATAL_ERROR "Developer error: You must specify a TYPE for your tests!")
  endif()

  set(TEST_TYPE ${ign_build_tests_TYPE})

  if(BUILD_TESTING)

    if(NOT DEFINED ign_build_tests_SOURCES)
      message(STATUS "No tests have been specified for ${TEST_TYPE}")
    else()
      list(LENGTH ign_build_tests_SOURCES num_tests)
      message(STATUS "Adding ${num_tests} ${TEST_TYPE} tests")
    endif()

    ign_build_executables(
      PREFIX "${TEST_TYPE}_"
      SOURCES ${ign_build_tests_SOURCES}
      LIB_DEPS gtest gtest_main ${ign_build_tests_LIB_DEPS}
      INCLUDE_DIRS ${PROJECT_SOURCE_DIR}/test/gtest/include ${ign_build_tests_INCLUDE_DIRS}
      EXEC_LIST test_list)

    if(ign_build_tests_TEST_LIST)
      set(${ign_build_tests_TEST_LIST} ${test_list})
    endif()

    # Find the Python interpreter for running the
    # check_test_ran.py script
    find_package(PythonInterp QUIET)

    # Build all the tests
    foreach(BINARY_NAME ${test_list})

      if(USE_LOW_MEMORY_TESTS)
        target_compile_options(${BINARY_NAME} PRIVATE -DUSE_LOW_MEMORY_TESTS=1)
      endif()

      add_test(${BINARY_NAME} ${CMAKE_CURRENT_BINARY_DIR}/${BINARY_NAME}
               --gtest_output=xml:${CMAKE_BINARY_DIR}/test_results/${BINARY_NAME}.xml)

      if(UNIX)
        # gtest requies pthread when compiled on a Unix machine
        target_link_libraries(${BINARY_NAME} pthread)
      endif()

      set_tests_properties(${BINARY_NAME} PROPERTIES TIMEOUT 240)

      if(PYTHONINTERP_FOUND)
        # Check that the test produced a result and create a failure if it didn't.
        # Guards against crashed and timed out tests.
        add_test(check_${BINARY_NAME} ${PYTHON_EXECUTABLE} ${PROJECT_SOURCE_DIR}/tools/check_test_ran.py
          ${CMAKE_BINARY_DIR}/test_results/${BINARY_NAME}.xml)
      endif()
    endforeach()

  else()

    message(STATUS "Testing is disabled -- skipping ${TEST_TYPE} tests")

  endif()

endmacro()

#################################################
# ign_set_target_public_cxx_standard(<11|14>)
#
# This lets you set the C++ standard required to compile and/or link against
# your project's main library target. Acceptable options for the standard are 11
# and 14.
#
# NOTE: This is a temporary workaround for the first pull request and will be
#       removed in the very next revision of ignition-cmake.
#
macro(ign_set_project_public_cxx_standard standard)

  list(FIND IGN_KNOWN_CXX_STANDARDS ${standard} known)
  if(${known} EQUAL -1)
    message(FATAL_ERROR "Specified invalid standard: ${standard}. Accepted values are: ${IGN_KNOWN_CXX_STANDARDS}.")
  endif()

  target_compile_features(${PROJECT_LIBRARY_TARGET_NAME} PUBLIC ${IGN_CXX_${standard}_FEATURES})

  ign_string_append(PROJECT_PKGCONFIG_CFLAGS "-std=c++${standard}")
  set(PROJECT_PKGCONFIG_CFLAGS ${PROJECT_PKGCONFIG_CFLAGS} PARENT_SCOPE)

endmacro()



