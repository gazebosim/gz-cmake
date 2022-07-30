
#################################################
# gz_find_package(<PACKAGE_NAME>
#                 [REQUIRED] [PRIVATE] [EXACT] [QUIET] [CONFIG] [BUILD_ONLY] [PKGCONFIG_IGNORE]
#                 [COMPONENTS <components_of_PACKAGE_NAME>]
#                 [OPTIONAL_COMPONENTS <components_of_PACKAGE_NAME>]
#                 [REQUIRED_BY <components_of_project>]
#                 [PRIVATE_FOR <components_of_project>]
#                 [VERSION <ver>]
#                 [EXTRA_ARGS <args>]
#                 [PRETTY <name>]
#                 [PURPOSE <"explanation for this dependency">]
#                 [PKGCONFIG <pkgconfig_name>]
#                 [PKGCONFIG_LIB <lib_name>]
#                 [PKGCONFIG_VER_COMPARISON  <  >  =  <=  >= ])
#
# This is a wrapper for the standard cmake find_package which behaves according
# to the conventions of the Gazebo library. In particular, we do not quit
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
# [REQUIRED]: Optional. If provided, macro will trigger a Gazebo build_error
#             when the package cannot be found. If not provided, this macro will
#             trigger a Gazebo build_warning when the package is not found.
#             To specify that something is required by some set of components
#             (rather than the core library), use REQUIRED_BY.
#
# [PRIVATE]: Optional. Use this to indicate that consumers of the project do not
#            need to link against the package, but it must be present on the
#            system, because our project must link against it.
#
# [EXACT]: Optional. This will pass on the EXACT option to find_package(~) and
#          also add it to the call to find_dependency(~) in the
#          <project>-config.cmake file.
#
# [QUIET]: Optional. If provided, it will be passed forward to cmake's
#          find_package(~) command. This macro will still print its normal
#          output, except there will be no warning if the package is missing,
#          unless REQUIRED or REQUIRED_BY is specified.
#
# [CONFIG]: Optional. If provided, it will be passed forward to cmake's
#          find_package(~) command. This will trigger Config mode search rather than
#          Module mode.
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
# [COMPONENTS]: Optional. If provided, the list that follows it will be passed
#               to find_package(~) to indicate which components of PACKAGE_NAME
#               are considered to be dependencies of either this project
#               (specified by REQUIRED) or this project's components (specified
#               by REQUIRED_BY). This is effectively the same as the
#               find_package( ... COMPONENTS <components>) argument.
#
# [REQUIRED_BY]: Optional. If provided, the list that follows it must indicate
#                which library components require the dependency. Note that if
#                REQUIRED is specified, then REQUIRED_BY does NOT need to be
#                specified for any components which depend on the core library,
#                because their dependence on this package will effectively be
#                inherited from the core library. This will trigger a build
#                warning to tell the user which component requires this
#                dependency.
#
# [PRIVATE_FOR]: Optional. If provided, the list that follows it must indicate
#                which library components depend on this package privately (i.e.
#                the package should not be included in its list of interface
#                libraries). This is only relevant for components that follow
#                the REQUIRED_BY command. Note that the PRIVATE argument does
#                not apply to components specified by REQUIRED_BY. This argument
#                MUST be given for components whose private dependencies have
#                been specified with REQUIRED_BY.
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
#  automatically by gz-cmake through the cmake find-module that is written
#  for your dependency. However, if your package gets distributed with its own
#  cmake config-file or find-module, then it might not automatically set this
#  information. Therefore, we provide the ability to set it through your call to
#  gz_find_package(~). These arguments can also be used to overwrite the
#  pkg-config entries that get generated by the gz-cmake find-module for the
#  package. Do not hesitate to ask for help if you need to use these arguments.
#
# [PKGCONFIG]: Optional. If provided, the string that follows will be used to
#              specify a "required package" for pkgconfig. Note that the option
#              PKGCONFIG_LIB has higher precedence than this option.
#
# [PKGCONFIG_LIB]: Optional. Use this to indicate that the package should be
#                  considered a "library" by pkgconfig. This is used for
#                  libraries which do not come with *.pc metadata, such as
#                  system libraries, libm, libdl, or librt. Generally you should
#                  leave this out, because most packages will be considered
#                  "modules" by pkgconfig. The string which follows this
#                  argument will be used as the library name, and the string
#                  that follows a PKGCONFIG argument will be ignored, so the
#                  PKGCONFIG argument can be left out when using this argument.
#
# [PKGCONFIG_VER_COMPARISON]: Optional. If provided, pkgconfig will be told how
#                             the available version of this package must compare
#                             to the specified version. Acceptable values are
#                             =, <, >, <=, >=. Default will be =. If no version
#                             is provided using VERSION, then this will be left
#                             out, whether or not it is provided.
#
macro(ign_find_package PACKAGE_NAME)
  # TODO(chapulina) Enable warnings after all libraries have migrated.
  # message(WARNING "ign_find_package is deprecated, use gz_find_package instead.")

  set(options REQUIRED PRIVATE EXACT QUIET CONFIG BUILD_ONLY PKGCONFIG_IGNORE)
  set(oneValueArgs VERSION PRETTY PURPOSE EXTRA_ARGS PKGCONFIG PKGCONFIG_LIB PKGCONFIG_VER_COMPARISON)
  set(multiValueArgs REQUIRED_BY PRIVATE_FOR COMPONENTS OPTIONAL_COMPONENTS)
  _gz_cmake_parse_arguments(gz_find_package "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  set(gz_find_package_skip_parsing true)
  gz_find_package(${PACKAGE_NAME})
endmacro()
macro(gz_find_package PACKAGE_NAME_)
  set(PACKAGE_NAME ${PACKAGE_NAME_})  # Allow for variable rebinds

  # Deprecated, remove skip parsing logic in version 4
  if (NOT gz_find_package_skip_parsing)
    #------------------------------------
    # Define the expected arguments
    set(options REQUIRED PRIVATE EXACT QUIET CONFIG BUILD_ONLY PKGCONFIG_IGNORE)
    set(oneValueArgs VERSION PRETTY PURPOSE EXTRA_ARGS PKGCONFIG PKGCONFIG_LIB PKGCONFIG_VER_COMPARISON)
    set(multiValueArgs REQUIRED_BY PRIVATE_FOR COMPONENTS OPTIONAL_COMPONENTS)

    #------------------------------------
    # Parse the arguments
    _gz_cmake_parse_arguments(gz_find_package "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  endif()

  #------------------------------------
  # Construct the arguments to pass to find_package
  set(${PACKAGE_NAME}_find_package_args ${PACKAGE_NAME})

  if(gz_find_package_VERSION)
    list(APPEND ${PACKAGE_NAME}_find_package_args ${gz_find_package_VERSION})
  endif()

  if(gz_find_package_QUIET)
    list(APPEND ${PACKAGE_NAME}_find_package_args QUIET)
  endif()

  if(gz_find_package_EXACT)
    list(APPEND ${PACKAGE_NAME}_find_package_args EXACT)
  endif()

  if(gz_find_package_CONFIG)
    list(APPEND ${PACKAGE_NAME}_find_package_args CONFIG)
  endif()

  if(gz_find_package_COMPONENTS)
    list(APPEND ${PACKAGE_NAME}_find_package_args COMPONENTS ${gz_find_package_COMPONENTS})
  endif()

  if(gz_find_package_OPTIONAL_COMPONENTS)
    list(APPEND ${PACKAGE_NAME}_find_package_args OPTIONAL_COMPONENTS ${gz_find_package_OPTIONAL_COMPONENTS})
  endif()

  if(gz_find_package_EXTRA_ARGS)
    list(APPEND ${PACKAGE_NAME}_find_package_args ${gz_find_package_EXTRA_ARGS})
  endif()


  #------------------------------------
  # Call find_package with the provided arguments

  # TODO(CH3): Deprecated. Remove on tock.
  if(${PACKAGE_NAME} MATCHES "^Ign")

    # NOTE(CH3): Deliberately use QUIET since we expect Ign to fail
    find_package(${${PACKAGE_NAME}_find_package_args} QUIET)

    if(NOT ${PACKAGE_NAME}_FOUND)
      # Try Gz prepended version instead!
      string(REGEX REPLACE "^Ign(ition)?" "Gz" PACKAGE_NAME_GZ ${PACKAGE_NAME})

      set(${PACKAGE_NAME_GZ}_find_package_args ${${PACKAGE_NAME}_find_package_args})
      list(POP_FRONT ${PACKAGE_NAME_GZ}_find_package_args)
      list(PREPEND ${PACKAGE_NAME_GZ}_find_package_args ${PACKAGE_NAME_GZ})

      find_package(${${PACKAGE_NAME_GZ}_find_package_args})
      if(${PACKAGE_NAME_GZ}_FOUND)

        message(DEPRECATION "Ign prefixed package name [${PACKAGE_NAME}] is deprecated! Automatically using the Gz prefix instead: [${PACKAGE_NAME_GZ}]")
        set(PACKAGE_NAME ${PACKAGE_NAME_GZ})

      endif()

    endif()
  else()

    # TODO(CH3): On removal on tock, unindent this and just have this line!!
    find_package(${${PACKAGE_NAME}_find_package_args})

  endif()


  #------------------------------------
  # Figure out which name to print
  if(gz_find_package_PRETTY)
    set(${PACKAGE_NAME}_pretty ${gz_find_package_PRETTY})
  else()
    set(${PACKAGE_NAME}_pretty ${PACKAGE_NAME})
  endif()


  if(${PACKAGE_NAME}_FOUND)

    message(STATUS "Looking for ${${PACKAGE_NAME}_pretty} - found\n")

  else()

    message(STATUS "Looking for ${${PACKAGE_NAME}_pretty} - not found\n")

    #------------------------------------
    # Construct the warning/error message to produce
    set(${PACKAGE_NAME}_msg "Missing dependency [${${PACKAGE_NAME}_pretty}]")

    if(gz_find_package_COMPONENTS)
      _gz_list_to_string(comp_str gz_find_package_COMPONENTS DELIM ", ")
      set(${PACKAGE_NAME}_msg "${${PACKAGE_NAME}_msg} (Components: ${comp_str})")
    endif()

    if(DEFINED gz_find_package_PURPOSE)
      set(${PACKAGE_NAME}_msg "${${PACKAGE_NAME}_msg} - ${gz_find_package_PURPOSE}")
    endif()

    #------------------------------------
    # If the package is unavailable, tell the user.
    if(gz_find_package_REQUIRED)

      # If it was required by the project, we will create an error.
      gz_build_error(${${PACKAGE_NAME}_msg})

    elseif(gz_find_package_REQUIRED_BY)

      foreach(component ${gz_find_package_REQUIRED_BY})

        if(NOT SKIP_${component})
          # Otherwise, if it was only required by some of the components, create
          # a warning about which components will not be available, unless the
          # user explicitly requested that it be skipped
          gz_build_warning("Skipping component [${component}]: ${${PACKAGE_NAME}_msg}.\n    ^~~~~ Set SKIP_${component}=true in cmake to suppress this warning.\n ")

          # Create a variable to indicate that we need to skip the component
          set(INTERNAL_SKIP_${component} true)

          # Track the missing dependencies
          gz_string_append(${component}_MISSING_DEPS "${${PACKAGE_NAME}_pretty}" DELIM ", ")
        endif()

      endforeach()

    else()
      if(NOT gz_find_package_QUIET)
        gz_build_warning(${${PACKAGE_NAME}_msg})
      endif()
    endif()

  endif()


  #------------------------------------
  # Add this package to the list of dependencies that will be inserted into the
  # find-config file, unless the invoker specifies that it should not be added.
  # Also, add this package or library as an entry to the pkgconfig file that we
  # will produce for our project.
  if( ${PACKAGE_NAME}_FOUND
      AND (gz_find_package_REQUIRED OR gz_find_package_REQUIRED_BY)
      AND NOT gz_find_package_BUILD_ONLY)

    # Set up the arguments we want to pass to the find_dependency invokation for
    # our Gazebo project. We always need to pass the name of the dependency.
    #
    # NOTE: We escape the dollar signs because we want those variable
    #       evaluations to be a part of the string that we produce. It is going
    #       to be put into a *-config.cmake file. Those variables determine
    #       whether the find_package(~) call will be REQUIRED and/or QUIET.
    #
    # TODO: When we migrate to cmake-3.9+, this can be removed because calling
    #       find_dependency(~) will automatically forward these properties.
    set(${PACKAGE_NAME}_dependency_args "${PACKAGE_NAME}")

    # If a version is provided here, we should pass that as well.
    if(gz_find_package_VERSION)
      gz_string_append(${PACKAGE_NAME}_dependency_args ${gz_find_package_VERSION})
    endif()

    # If we have specified the exact version, we should provide that as well.
    if(gz_find_package_EXACT)
      gz_string_append(${PACKAGE_NAME}_dependency_args EXACT)
    endif()

    # If we have specified to use CONFIG mode, we should provide that as well.
    if(gz_find_package_CONFIG)
      gz_string_append(${PACKAGE_NAME}_dependency_args CONFIG)
    endif()

    # NOTE (MXG): 7 seems to be the number of escapes required to get
    # "${gz_package_required}" and "${gz_package_quiet}" to show up correctly
    # as strings in the final config-file outputs. It is unclear to me why the
    # escapes get collapsed exactly three times, so it is possible that any
    # changes to this script could cause a different number of escapes to be
    # necessary. Please use caution when modifying this script.
    gz_string_append(${PACKAGE_NAME}_dependency_args "\\\\\\\${gz_package_quiet} \\\\\\\${gz_package_required}")

    # If we have specified components of the dependency, mention those.
    if(gz_find_package_COMPONENTS)
      gz_string_append(${PACKAGE_NAME}_dependency_args "COMPONENTS ${gz_find_package_COMPONENTS}")
    endif()

    # If there are any additional arguments for the find_package(~) command,
    # forward them along.
    if(gz_find_package_EXTRA_ARGS)
      gz_string_append(${PACKAGE_NAME}_dependency_args "${gz_find_package_EXTRA_ARGS}")
    endif()

    # TODO: When we migrate to cmake-3.9+ bring back find_dependency(~) because
    #       at that point it will be able to support COMPONENTS and EXTRA_ARGS
#    set(${PACKAGE_NAME}_find_dependency "find_dependency(${${PACKAGE_NAME}_dependency_args})")

    set(${PACKAGE_NAME}_find_dependency "find_package(${${PACKAGE_NAME}_dependency_args})")


    if(gz_find_package_REQUIRED)
      # If this is REQUIRED, add it to PROJECT_CMAKE_DEPENDENCIES
      gz_string_append(PROJECT_CMAKE_DEPENDENCIES "${${PACKAGE_NAME}_find_dependency}" DELIM "\n")
    endif()

    if(gz_find_package_REQUIRED_BY)

      # Identify which components are privately requiring this package
      foreach(component ${gz_find_package_PRIVATE_FOR})
        set(${component}_${PACKAGE_NAME}_PRIVATE true)
      endforeach()

      # If this is required by some components, add it to the
      # ${component}_CMAKE_DEPENDENCIES variables that are specific to those
      # componenets
      foreach(component ${gz_find_package_REQUIRED_BY})
        if(NOT ${component}_${PACKAGE_NAME}_PRIVATE)
          gz_string_append(${component}_CMAKE_DEPENDENCIES "${${PACKAGE_NAME}_find_dependency}" DELIM "\n")
        endif()
      endforeach()

    endif()

    #------------------------------------
    # Add this library or project to its relevant pkgconfig entry, unless we
    # have been explicitly instructed to ignore it.
    if(NOT gz_find_package_PKGCONFIG_IGNORE)

      # Here we will set up the pkgconfig entry for this package. Ordinarily,
      # these variables should be set by the gz-cmake custom find-module for
      # the package which should use gz_pkg_check_modules[_quiet] or
      # gz_pkg_config_library_entry. However, that will not be performed by
      # third-party dependencies that provide their own find-module or their own
      # cmake config-module. Therefore, we provide the option of specifying
      # pkgconfig information through the call to gz_find_package. This also
      # allows callers of gz_find_package(~) to overwrite the default
      # pkg-config entry that gets generated by the gz-cmake find-modules.

      # If the caller has specified the arguments PKGCONFIG_LIB or PKGCONFIG,
      # then we will overwrite these pkgconfig variables with the information
      # provided by the caller.
      if(gz_find_package_PKGCONFIG_LIB)

        # Libraries must be prepended with -l
        set(${PACKAGE_NAME}_PKGCONFIG_ENTRY "-l${gz_find_package_PKGCONFIG_LIB}")
        set(${PACKAGE_NAME}_PKGCONFIG_TYPE PKGCONFIG_LIBS)

      elseif(gz_find_package_PKGCONFIG)

        # Modules (a.k.a. packages) can just be specified by their package
        # name without any prefixes like -l
        set(${PACKAGE_NAME}_PKGCONFIG_ENTRY "${gz_find_package_PKGCONFIG}")
        set(${PACKAGE_NAME}_PKGCONFIG_TYPE PKGCONFIG_REQUIRES)

        # Add the version requirements to the entry.
        if(gz_find_package_VERSION)
          # Use equivalency by default
          set(comparison "=")

          # If the caller has specified a version comparison operator, use that
          # instead of equivalency.
          if(gz_find_package_PKGCONFIG_VER_COMPARISON)
            set(comparison ${gz_find_package_PKGCONFIG_VER_COMPARISON})
          endif()

          # Append the comparison and the version onto the pkgconfig entry
          set(${PACKAGE_NAME}_PKGCONFIG_ENTRY "${${PACKAGE_NAME}_PKGCONFIG_ENTRY} ${comparison} ${gz_find_package_VERSION}")

        endif()

      endif()

      if(NOT ${PACKAGE_NAME}_PKGCONFIG_ENTRY)

        # The find-module has not provided a default pkg-config entry for this
        # package, and the caller of gz_find_package(~) has not explicitly
        # provided pkg-config information. The caller has also not specified
        # PKGCONFIG_IGNORE. This means that the requirements of this package
        # will be unintentionally omitted from the auto-generated
        # gz-<project>.pc file. This is probably an oversight in our build
        # system scripts, so we will emit a warning about this.
        message(AUTHOR_WARNING
          " -- THIS MESSAGE IS INTENDED FOR GZ-${GZ_DESIGNATION_UPPER} AUTHORS --\n"
          "    (IF YOU SEE THIS, PLEASE REPORT IT)\n"
          "Could not find pkg-config information for ${PACKAGE_NAME}. "
          "It was not provided by the find-module for the package, nor was it "
          "explicitly passed into the call to gz_find_package(~). This is "
        "most likely an error in this project's use of gz-cmake.")

      else()

        # We have pkg-config information for this package

        if(gz_find_package_REQUIRED)

          if(gz_find_package_PRIVATE)
            # If this is a private library or module, use the _PRIVATE suffix
            set(PROJECT_${PACKAGE_NAME}_PKGCONFIG_TYPE ${${PACKAGE_NAME}_PKGCONFIG_TYPE}_PRIVATE)
          else()
            # Otherwise, use the plain type
            set(PROJECT_${PACKAGE_NAME}_PKGCONFIG_TYPE ${${PACKAGE_NAME}_PKGCONFIG_TYPE})
          endif()

          # Append the entry as a string onto the project-wide variable for
          # whichever requirement type we selected
          gz_string_append(PROJECT_${PROJECT_${PACKAGE_NAME}_PKGCONFIG_TYPE} ${${PACKAGE_NAME}_PKGCONFIG_ENTRY})

        endif()

        if(gz_find_package_REQUIRED_BY)

          # For each of the components that requires this package, append its
          # entry as a string onto the component-specific variable for whichever
          # requirement type we selected
          foreach(component ${gz_find_package_REQUIRED_BY})

            if(${component}_${PACKAGE_NAME}_PRIVATE)
              # If this is a private library or module, use the _PRIVATE suffix
              set(${component}_${PACKAGE_NAME}_PKGCONFIG_TYPE ${component}_${${PACKAGE_NAME}_PKGCONFIG_TYPE}_PRIVATE)
            else()
              # Otherwise, use the plain type
              set(${component}_${PACKAGE_NAME}_PKGCONFIG_TYPE ${component}_${${PACKAGE_NAME}_PKGCONFIG_TYPE})
            endif()

            # Append the entry as a string onto the component-specific variable
            # for whichever required type we selected
            gz_string_append(${${component}_${PACKAGE_NAME}_PKGCONFIG_TYPE} ${${PACKAGE_NAME}_PKGCONFIG_ENTRY})

          endforeach()

        endif()

      endif()

    endif()

  endif()

endmacro()

#################################################
# gz_string_append(<output_var> <value_to_append> [DELIM <delimiter>])
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
  # TODO(chapulina) Enable warnings after all libraries have migrated.
  # message(WARNING "ign_string_append is deprecated, use gz_string_append instead.")

  set(options)
  set(oneValueArgs DELIM)
  set(multiValueArgs)
  _gz_cmake_parse_arguments(gz_string_append "PARENT_SCOPE;${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  set(gz_string_append_skip_parsing true)
  gz_string_append(${output_var} ${val})

  if(gz_string_append_PARENT_SCOPE)
    set(${output_var} ${${output_var}} PARENT_SCOPE)
  endif()
endmacro()
macro(gz_string_append output_var val)

  # Deprecated, remove skip parsing logic in version 4
  if (NOT gz_string_append_skip_parsing)
    #------------------------------------
    # Define the expected arguments
    # NOTE: options cannot be set to PARENT_SCOPE alone, so we put it explicitly
    # into cmake_parse_arguments(~). We use a semicolon to concatenate it with
    # this options variable, so all other options should be specified here.
    set(options)
    set(oneValueArgs DELIM)
    set(multiValueArgs)

    #------------------------------------
    # Parse the arguments
    _gz_cmake_parse_arguments(gz_string_append "PARENT_SCOPE;${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  endif()

  if(gz_string_append_DELIM)
    set(delim "${gz_string_append_DELIM}")
  else()
    set(delim " ")
  endif()

  if( (NOT ${output_var}) OR (${output_var} STREQUAL "") )
    # If ${output_var} is blank, just set it to equal ${val}
    set(${output_var} "${val}")
  else()
    # If ${output_var} already has a value in it, append ${val} with the
    # delimiter in-between.
    set(${output_var} "${${output_var}}${delim}${val}")
  endif()

  if(gz_string_append_PARENT_SCOPE)
    set(${output_var} "${${output_var}}" PARENT_SCOPE)
  endif()

endmacro()

#################################################
# Macro to turn a list into a string
# Internal to gz-cmake.
macro(_gz_list_to_string _output _input_list)

  set(${_output})
  foreach(_item ${${_input_list}})
    # Append each item, and forward any extra options to gz_string_append, such
    # as DELIM or PARENT_SCOPE
    gz_string_append(${_output} "${_item}" ${ARGN})
  endforeach(_item)

endmacro()

#################################################
# gz_get_libsources_and_unittests(<lib_srcs> <tests>)
#
# Grab all the files ending in "*.cc" from either the "src/" subdirectory or the
# current subdirectory if "src/" does not exist. They will be collated into
# library source files <lib_sources_var> and unittest source files <tests_var>.
#
# These output variables can be consumed directly by gz_create_core_library(~),
# gz_add_component(~), gz_build_tests(~), and gz_build_executables(~).
function(ign_get_libsources_and_unittests lib_sources_var tests_var)
  # TODO(chapulina) Enable warnings after all libraries have migrated.
  # message(WARNING "ign_get_libsources_and_unittests is deprecated, use gz_get_libsources_and_unittests instead.")

  gz_get_libsources_and_unittests(${lib_sources_var} ${tests_var})

  set(${lib_sources_var} ${${lib_sources_var}} PARENT_SCOPE)
  set(${tests_var} ${${tests_var}} PARENT_SCOPE)
endfunction()
function(gz_get_libsources_and_unittests lib_sources_var tests_var)

  # Glob all the source files
  if(EXISTS ${CMAKE_CURRENT_LIST_DIR}/src)

    # Prefer files in the src/ subdirectory
    file(GLOB source_files RELATIVE "${CMAKE_CURRENT_LIST_DIR}" "src/*.cc")
    file(GLOB test_files RELATIVE "${CMAKE_CURRENT_LIST_DIR}" "src/*_TEST.cc")

  else()

    # If src/ doesn't exist, then use the current directory
    file(GLOB source_files RELATIVE "${CMAKE_CURRENT_LIST_DIR}" "*.cc")
    file(GLOB test_files RELATIVE "${CMAKE_CURRENT_LIST_DIR}" "*_TEST.cc")

  endif()

  # Sort the files alphabetically
  if(source_files)
    list(SORT source_files)
  endif()

  if(test_files)
    list(SORT test_files)
  endif()

  # Initialize the test list
  set(tests)

  # Remove the unit tests from the list of source files
  foreach(test_file ${test_files})

    # Remove from the source_files list.
    list(REMOVE_ITEM source_files ${test_file})

    # Append to the list of tests.
    list(APPEND tests ${test_file})

  endforeach()

  # Return the lists that have been created.
  set(${lib_sources_var} ${source_files} PARENT_SCOPE)
  set(${tests_var} ${tests} PARENT_SCOPE)

endfunction()

#################################################
# gz_get_sources(<sources>)
#
# From the current directory, grab all the source files and place them into
# <sources>. Remove their paths to make them suitable for passing into
# gz_add_[library/tests].
function(ign_get_sources sources_var)
  # TODO(chapulina) Enable warnings after all libraries have migrated.
  # message(WARNING "ign_get_sources is deprecated, use gz_get_sources instead.")

  gz_get_sources(${sources_var})

  set(${sources_var} ${${sources_var}} PARENT_SCOPE)
endfunction()
function(gz_get_sources sources_var)

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
# gz_install_all_headers(
#   [EXCLUDE_FILES <excluded_headers>]
#   [EXCLUDE_DIRS  <dirs>]
#   [GENERATED_HEADERS <headers>]
#   [COMPONENT] <component>)
#
# From the current directory, install all header files, including files from all
# subdirectories (recursively). You can optionally specify directories or files
# to exclude from installation (the names must be provided relative to the current
# source directory).
#
# This will accept all files ending in *.h and *.hh. You may append an
# additional suffix (like .old or .backup) to prevent a file from being included.
#
# GENERATED_HEADERS should be generated headers which should be included by
# ${GZ_DESIGNATION}.hh. This will only add them to the header, it will not
# generate or install them.
#
# This will also run configure_file on gz_auto_headers.hh.in and config.hh.in
# and install them. This will NOT install any other files or directories that
# appear in the ${CMAKE_CURRENT_BINARY_DIR}.
#
# If the COMPONENT option is specified, this will skip over configuring a
# config.hh file since it would be redundant with the core library.
#
function(ign_install_all_headers)
  # TODO(chapulina) Enable warnings after all libraries have migrated.
  # message(WARNING "ign_install_all_headers is deprecated, use gz_install_all_headers instead.")

  set(options)
  set(oneValueArgs COMPONENT)
  set(multiValueArgs EXCLUDE_FILES EXCLUDE_DIRS GENERATED_HEADERS)
  _gz_cmake_parse_arguments(gz_install_all_headers "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  set(gz_install_all_headers_skip_parsing true)
  gz_install_all_headers()
endfunction()
function(gz_install_all_headers)

  # Deprecated, remove skip parsing logic in version 4
  if (NOT gz_install_all_headers_skip_parsing)
    #------------------------------------
    # Define the expected arguments
    set(options)
    set(oneValueArgs COMPONENT)
    set(multiValueArgs EXCLUDE_FILES EXCLUDE_DIRS GENERATED_HEADERS)

    #------------------------------------
    # Parse the arguments
    _gz_cmake_parse_arguments(gz_install_all_headers "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  endif()

  #------------------------------------
  # Build the list of directories
  file(GLOB_RECURSE all_files LIST_DIRECTORIES TRUE RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "*")
  list(SORT all_files)

  set(directories)
  foreach(f ${all_files})
    # Check if this file is a directory
    if(IS_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${f})

      # Check if it is in the list of excluded directories
      list(FIND gz_install_all_headers_EXCLUDE_DIRS ${f} f_index)

      set(append_file TRUE)
      foreach(subdir ${gz_install_all_headers_EXCLUDE_DIRS})

        # Check if ${f} contains ${subdir} as a substring
        string(FIND ${f} ${subdir} pos)

        # If ${subdir} is a substring of ${f} at the very first position, then
        # we should not include anything from this directory. This makes sure
        # that if a user specifies "EXCLUDE_DIRS foo" we will also exclude
        # the directories "foo/bar/..." and so on. We will not, however, exclude
        # a directory named "bar/foo/".
        if(${pos} EQUAL 0)
          set(append_file FALSE)
          break()
        endif()

      endforeach()

      if(append_file)
        list(APPEND directories ${f})
      endif()

    endif()
  endforeach()

  # Append the current directory to the list
  list(APPEND directories ".")

  #------------------------------------
  # Install all the non-excluded header directories along with all of their
  # non-excluded headers
  foreach(dir ${directories})

    # GLOB all the header files in dir
    file(GLOB headers RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "${dir}/*.h" "${dir}/*.hh" "${dir}/*.hpp")
    list(SORT headers)

    # Remove the excluded headers
    if(headers)
      foreach(exclude ${gz_install_all_headers_EXCLUDE_FILES})
        list(REMOVE_ITEM headers ${exclude})
      endforeach()
    endif()

    # Add each header, prefixed by its directory, to the auto headers variable
    foreach(header ${headers})
      set(gz_headers "${gz_headers}#include <${PROJECT_INCLUDE_DIR}/${header}>\n")
    endforeach()

    if("." STREQUAL ${dir})
      set(destination "${GZ_INCLUDE_INSTALL_DIR_FULL}/${PROJECT_INCLUDE_DIR}")
    else()
      set(destination "${GZ_INCLUDE_INSTALL_DIR_FULL}/${PROJECT_INCLUDE_DIR}/${dir}")
    endif()

    install(
      FILES ${headers}
      DESTINATION ${destination}
      COMPONENT headers)

  endforeach()

  # Add generated headers to the list of includes
  foreach(header ${gz_install_all_headers_GENERATED_HEADERS})
      set(gz_headers "${gz_headers}#include <${PROJECT_INCLUDE_DIR}/${header}>\n")
  endforeach()

  set(ign_headers ${gz_headers})  # TODO(CH3): Deprecated. Remove on tock.

  if(gz_install_all_headers_COMPONENT)

    set(component_name ${gz_install_all_headers_COMPONENT})

    # Define the install directory for the component meta header
    set(meta_header_install_dir ${GZ_INCLUDE_INSTALL_DIR_FULL}/${PROJECT_INCLUDE_DIR}/${component_name})

    # Define the input/output of the configuration for the component "master" header
    set(master_header_in ${GZ_CMAKE_DIR}/gz_auto_headers.hh.in)
    set(master_header_out ${CMAKE_CURRENT_BINARY_DIR}/${component_name}.hh)

  else()

    # Define the install directory for the core master meta header
    set(meta_header_install_dir ${GZ_INCLUDE_INSTALL_DIR_FULL}/${PROJECT_INCLUDE_DIR})

    # Define the input/output of the configuration for the core "master" header
    set(master_header_in ${GZ_CMAKE_DIR}/gz_auto_headers.hh.in)
    set(master_header_out ${CMAKE_CURRENT_BINARY_DIR}/../${GZ_DESIGNATION}.hh)

  endif()

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

  if(NOT gz_install_all_headers_COMPONENT)

    # Produce an error if the config file is missing
    #
    # TODO: Maybe we should have a generic config.hh.in file that we fall back
    # on if the project does not have one for itself?
    if(NOT EXISTS ${config_header_in})
      message(FATAL_ERROR
        "Developer error: You are missing the file [${config_header_in}]! "
        "Did you forget to move it from your project's cmake directory while "
        "migrating to the use of gz-cmake?")
    endif()

    # Generate the "config" header that describes our project configuration
    configure_file(${config_header_in} ${config_header_out})

    # Install the "config" header
    install(
      FILES ${config_header_out}
      DESTINATION ${meta_header_install_dir}
      COMPONENT headers)

  endif()

endfunction()


#################################################
# gz_build_error macro
macro(ign_build_error)
  # TODO(chapulina) Enable warnings after all libraries have migrated.
  # message(WARNING "ign_build_error is deprecated, use gz_build_error instead.")

  foreach(str ${ARGN})
    set(msg "\t${str}")
    list(APPEND build_errors ${msg})
  endforeach()
endmacro(ign_build_error)
macro(gz_build_error)
  foreach(str ${ARGN})
    set(msg "\t${str}")
    list(APPEND build_errors ${msg})
  endforeach()
endmacro(gz_build_error)

#################################################
# gz_build_warning macro
macro(ign_build_warning)
  # TODO(chapulina) Enable warnings after all libraries have migrated.
  # message(WARNING "ign_build_warning is deprecated, use gz_build_warning instead.")

  foreach(str ${ARGN})
    list(APPEND build_warnings "${str}")
  endforeach(str ${ARGN})
endmacro(ign_build_warning)
macro(gz_build_warning)
  foreach(str ${ARGN})
    list(APPEND build_warnings "${str}")
  endforeach(str ${ARGN})
endmacro(gz_build_warning)

#################################################
# _gz_check_known_cxx_standards(<11|14|17>)
#
# Creates a fatal error if the variable passed in does not represent a supported
# version of the C++ standard.
#
# NOTE: This function is meant for internal gz-cmake use
#
function(_gz_check_known_cxx_standards standard)

  list(FIND GZ_KNOWN_CXX_STANDARDS ${standard} known)
  if(${known} EQUAL -1)
    message(FATAL_ERROR
      "You have specified an unsupported standard: ${standard}. "
      "Accepted values are: ${GZ_KNOWN_CXX_STANDARDS}.")
  endif()

endfunction()

#################################################
# _gz_handle_cxx_standard(<function_prefix>
#                          <target_name>
#                          <pkgconfig_cflags_variable>)
#
# Handles the C++ standard argument for gz_create_core_library(~) and
# gz_add_component(~).
#
# NOTE: This is only meant for internal gz-cmake use.
#
macro(_gz_handle_cxx_standard prefix target pkgconfig_cflags)

  if(${prefix}_CXX_STANDARD)
    _gz_check_known_cxx_standards(${${prefix}_CXX_STANDARD})
  endif()

  if(${prefix}_PRIVATE_CXX_STANDARD)
    _gz_check_known_cxx_standards(${${prefix}_PRIVATE_CXX_STANDARD})
  endif()

  if(${prefix}_INTERFACE_CXX_STANDARD)
    _gz_check_known_cxx_standards(${${prefix}_INTERFACE_CXX_STANDARD})
  endif()

  if(${prefix}_CXX_STANDARD
      AND (${prefix}_PRIVATE_CXX_STANDARD
           OR ${prefix}_INTERFACE_CXX_STANDARD))
    message(FATAL_ERROR
      "If CXX_STANDARD has been specified, then you are not allowed to specify "
      "PRIVATE_CXX_STANDARD or INTERFACE_CXX_STANDARD. Please choose to either "
      "specify CXX_STANDARD alone, or else specify some combination of "
      "PRIVATE_CXX_STANDARD and INTERFACE_CXX_STANDARD")
  endif()

  if(${prefix}_CXX_STANDARD)
    set(${prefix}_INTERFACE_CXX_STANDARD ${${prefix}_CXX_STANDARD})
    set(${prefix}_PRIVATE_CXX_STANDARD ${${prefix}_CXX_STANDARD})
  endif()

  if(${prefix}_INTERFACE_CXX_STANDARD)
    target_compile_features(${target} INTERFACE ${GZ_CXX_${${prefix}_INTERFACE_CXX_STANDARD}_FEATURES})
    gz_string_append(${pkgconfig_cflags} "-std=c++${${prefix}_INTERFACE_CXX_STANDARD}")
  endif()

  if(${prefix}_PRIVATE_CXX_STANDARD)
    target_compile_features(${target} PRIVATE ${GZ_CXX_${${prefix}_PRIVATE_CXX_STANDARD}_FEATURES})
  endif()

endmacro()

#################################################
# gz_create_core_library(SOURCES <sources>
#                         [CXX_STANDARD <11|14|17>]
#                         [PRIVATE_CXX_STANDARD <11|14|17>]
#                         [INTERFACE_CXX_STANDARD <11|14|17>]
#                         [GET_TARGET_NAME <output_var>]
#                         [LEGACY_PROJECT_PREFIX <prefix>])
#
# This function will produce the "core" library for your project. There is no
# need to specify a name for the library, because that will be determined by
# your project information.
#
# SOURCES: Required. Specify the source files that will be used to generate the
#          library.
#
# [GET_TARGET_NAME]: Optional. The variable that follows this argument will be
#                    set to the library target name that gets produced by this
#                    function. The target name will always be
#                    ${PROJECT_LIBRARY_TARGET_NAME}.
#
# [LEGACY_PROJECT_PREFIX]: Optional. The variable that follows this argument will be
#                          used as a prefix for the legacy cmake config variables
#                          <prefix>_LIBRARIES and <prefix>_INCLUDE_DIRS.
#
# If you need a specific C++ standard, you must also specify it in this
# function in order to ensure that your library's target properties get set
# correctly. The following is a breakdown of your choices:
#
# [CXX_STANDARD]: This library must compile using the specified standard, and so
#                 must any libraries which link to it.
#
# [PRIVATE_CXX_STANDARD]: This library must compile using the specified standard,
#                         but libraries which link to it do not need to.
#
# [INTERFACE_CXX_STANDARD]: Any libraries which link to this library must compile
#                           with the specified standard.
#
# Most often, you will want to use CXX_STANDARD, but there may be cases in which
# you want a finer degree of control. If your library must compile with a
# different standard than what is required by dependent libraries, then you can
# specify both PRIVATE_CXX_STANDARD and INTERFACE_CXX_STANDARD without any
# conflict. However, both of those arguments conflict with CXX_STANDARD, so you
# are not allowed to use either of them if you use the CXX_STANDARD argument.
#
function(ign_create_core_library)
  # TODO(chapulina) Enable warnings after all libraries have migrated.
  # message(WARNING "ign_create_core_library is deprecated, use gz_create_core_library instead.")

  set(options INTERFACE)
  set(oneValueArgs INCLUDE_SUBDIR LEGACY_PROJECT_PREFIX CXX_STANDARD PRIVATE_CXX_STANDARD INTERFACE_CXX_STANDARD GET_TARGET_NAME)
  set(multiValueArgs SOURCES)
  cmake_parse_arguments(gz_create_core_library "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  set(gz_create_core_library_skip_parsing true)
  gz_create_core_library()

  if(gz_create_core_library_GET_TARGET_NAME)
    set(${gz_create_core_library_GET_TARGET_NAME} ${${gz_create_core_library_GET_TARGET_NAME}} PARENT_SCOPE)
  endif()
endfunction()
function(gz_create_core_library)

  # Deprecated, remove skip parsing logic in version 4
  if (NOT gz_create_core_library_skip_parsing)
    #------------------------------------
    # Define the expected arguments
    set(options INTERFACE)
    set(oneValueArgs INCLUDE_SUBDIR LEGACY_PROJECT_PREFIX CXX_STANDARD PRIVATE_CXX_STANDARD INTERFACE_CXX_STANDARD GET_TARGET_NAME)
    set(multiValueArgs SOURCES)

    #------------------------------------
    # Parse the arguments
    cmake_parse_arguments(gz_create_core_library "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  endif()

  if(gz_create_core_library_SOURCES)
    set(sources ${gz_create_core_library_SOURCES})
  elseif(NOT gz_create_core_library_INTERFACE)
    message(FATAL_ERROR "You must specify SOURCES for gz_create_core_library(~)!")
  endif()

  if(gz_create_core_library_INTERFACE)
    set(interface_option INTERFACE)
    set(property_type INTERFACE)
  else()
    set(interface_option) # Intentionally blank
    set(property_type PUBLIC)
  endif()

  #------------------------------------
  # Create the target for the core library, and configure it to be installed
  _gz_add_library_or_component(
    LIB_NAME ${PROJECT_LIBRARY_TARGET_NAME}
    INCLUDE_DIR "${PROJECT_INCLUDE_DIR}"
    EXPORT_BASE GZ_${GZ_DESIGNATION_UPPER}
    SOURCES ${sources}
    ${interface_option})

  # These generator expressions are necessary for multi-configuration generators
  # such as MSVC on Windows. They also ensure that our target exports its
  # headers correctly
  target_include_directories(${PROJECT_LIBRARY_TARGET_NAME}
    ${property_type}
      # This is the publicly installed headers directory.
      "$<INSTALL_INTERFACE:${GZ_INCLUDE_INSTALL_DIR_FULL}>"
      # This is the in-build version of the core library headers directory.
      # Generated headers for the core library get placed here.
      "$<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/include>"
      # Generated headers for the core library might also get placed here.
      "$<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/core/include>")

  # We explicitly create these directories to avoid false-flag compiler warnings
  file(MAKE_DIRECTORY
    "${PROJECT_BINARY_DIR}/include"
    "${PROJECT_BINARY_DIR}/core/include")

  if(EXISTS "${PROJECT_SOURCE_DIR}/include")
    target_include_directories(${PROJECT_LIBRARY_TARGET_NAME}
      ${property_type}
        # This is the build directory version of the headers. When exporting the
        # target, this will not be included, because it is tied to the build
        # interface instead of the install interface.
        "$<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>")
  endif()

  if(EXISTS "${PROJECT_SOURCE_DIR}/core/include")
    target_include_directories(${PROJECT_LIBRARY_TARGET_NAME}
      ${property_type}
        # This is the include directories for projects that put the core library
        # contents into its own subdirectory.
        "$<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/core/include>")
  endif()


  #------------------------------------
  # Adjust variables if a specific C++ standard was requested
  _gz_handle_cxx_standard(gz_create_core_library
    ${PROJECT_LIBRARY_TARGET_NAME} PROJECT_PKGCONFIG_CFLAGS)


  #------------------------------------
  # Handle cmake and pkgconfig packaging
  if(gz_create_core_library_INTERFACE)
    set(project_pkgconfig_core_lib) # Intentionally blank
  else()
    set(project_pkgconfig_core_lib "-l${PROJECT_NAME_LOWER}")
  endif()

  # Export and install the core library's cmake target and package information
  _gz_create_cmake_package(LEGACY_PROJECT_PREFIX ${gz_create_core_library_LEGACY_PROJECT_PREFIX})

  # Generate and install the core library's pkgconfig information
  _gz_create_pkgconfig()


  #------------------------------------
  # Pass back the target name if they ask for it.
  if(gz_create_core_library_GET_TARGET_NAME)
    set(${gz_create_core_library_GET_TARGET_NAME} ${PROJECT_LIBRARY_TARGET_NAME} PARENT_SCOPE)
  endif()

endfunction()

#################################################
# gz_add_component(<component>
#                   SOURCES <sources> | INTERFACE
#                   [DEPENDS_ON_COMPONENTS <components...>]
#                   [INCLUDE_SUBDIR <subdirectory_name>]
#                   [GET_TARGET_NAME <output_var>]
#                   [INDEPENDENT_FROM_PROJECT_LIB]
#                   [PRIVATELY_DEPENDS_ON_PROJECT_LIB]
#                   [INTERFACE_DEPENDS_ON_PROJECT_LIB]
#                   [CXX_STANDARD <11|14|17>]
#                   [PRIVATE_CXX_STANDARD <11|14|17>]
#                   [INTERFACE_CXX_STANDARD <11|14|17>])
#
# This function will produce a "component" library for your project. This is the
# recommended way to produce plugins or library modules.
#
# <component>: Required. Name of the component. The final name of this library
#              and its target will be gz-<project><major_ver>-<component>
#
# SOURCES: Required (unless INTERFACE is specified). Specify the source files
#          that will be used to generate the library.
#
# INTERFACE: Indicate that this is an INTERFACE library which does not require
#            any source files. This is required if SOURCES is not specified.
#
# [DEPENDS_ON_COMPONENTS]: Specify a list of other components of this package
#                          that this component depends on. This argument should
#                          be considered mandatory whenever there are
#                          inter-component dependencies in an Gazebo package.
#
# [INCLUDE_SUBDIR]: Optional. If specified, the public include headers for this
#                   component will go into "ignition/<project>/<subdirectory_name>/".
#                   If not specified, they will go into "ignition/<project>/<component>/"
#
# [GET_TARGET_NAME]: Optional. The variable that follows this argument will be
#                    set to the library target name that gets produced by this
#                    function. The target name will always be
#                    ${PROJECT_LIBRARY_TARGET_NAME}-<component>.
#
# [INDEPENDENT_FROM_PROJECT_LIB]:
#     Optional. Specify this if you do NOT want this component to automatically
#     be linked to the core library of this project. The default behavior is to
#     be publically linked.
#
# [PRIVATELY_DEPENDS_ON_PROJECT_LIB]:
#     Optional. Specify this if this component privately depends on the core
#     library of this project (i.e. users of this component do not need to
#     interface with the core library). The default behavior is to be publicly
#     linked.
#
# [INTERFACE_DEPENDS_ON_PROJECT_LIB]:
#     Optional. Specify this if the component's interface depends on the core
#     library of this project (i.e. users of this component need to interface
#     with the core library), but the component itself does not need to link to
#     the core library.
#
# See the documentation of gz_create_core_library(~) for more information about
# specifying the C++ standard. If your component publicly depends on the core
# library, then you probably do not need to specify the standard, because it
# will get inherited from the core library.
function(ign_add_component component_name)
  # TODO(chapulina) Enable warnings after all libraries have migrated.
  # message(WARNING "ign_add_component is deprecated, use gz_add_component instead.")

  set(options INTERFACE INDEPENDENT_FROM_PROJECT_LIB PRIVATELY_DEPENDS_ON_PROJECT_LIB INTERFACE_DEPENDS_ON_PROJECT_LIB)
  set(oneValueArgs INCLUDE_SUBDIR GET_TARGET_NAME)
  set(multiValueArgs SOURCES DEPENDS_ON_COMPONENTS)
  cmake_parse_arguments(gz_add_component "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  set(gz_add_component_skip_parsing true)
  gz_add_component(${component_name})

  # Pass the component's target name back to the caller if requested
  if(gz_add_component_GET_TARGET_NAME)
    set(${gz_add_component_GET_TARGET_NAME} ${${gz_add_component_GET_TARGET_NAME}} PARENT_SCOPE)
  endif()
endfunction()
function(gz_add_component component_name)

  # Deprecated, remove skip parsing logic in version 4
  if (NOT gz_add_component_skip_parsing)
    #------------------------------------
    # Define the expected arguments
    set(options INTERFACE INDEPENDENT_FROM_PROJECT_LIB PRIVATELY_DEPENDS_ON_PROJECT_LIB INTERFACE_DEPENDS_ON_PROJECT_LIB)
    set(oneValueArgs INCLUDE_SUBDIR GET_TARGET_NAME)
    set(multiValueArgs SOURCES DEPENDS_ON_COMPONENTS)

    #------------------------------------
    # Parse the arguments
    cmake_parse_arguments(gz_add_component "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  endif()

  if(POLICY CMP0079)
    cmake_policy(SET CMP0079 NEW)
  endif()

  if(gz_add_component_SOURCES)
    set(sources ${gz_add_component_SOURCES})
  elseif(NOT gz_add_component_INTERFACE)
    message(FATAL_ERROR "You must specify SOURCES for gz_add_component(~)!")
  endif()

  if(gz_add_component_INCLUDE_SUBDIR)
    set(include_subdir ${gz_add_component_INCLUDE_SUBDIR})
  else()
    set(include_subdir ${component_name})
  endif()

  if(gz_add_component_INTERFACE)
    set(interface_option INTERFACE)
    set(property_type INTERFACE)
  else()
    set(interface_option) # Intentionally blank
    set(property_type PUBLIC)
  endif()

  # Set the name of the component's target
  set(component_target_name ${PROJECT_LIBRARY_TARGET_NAME}-${component_name})

  # Pass the component's target name back to the caller if requested
  if(gz_add_component_GET_TARGET_NAME)
    set(${gz_add_component_GET_TARGET_NAME} ${component_target_name} PARENT_SCOPE)
  endif()

  # Create an upper case version of the component name, to be used as an export
  # base name.
  string(TOUPPER ${component_name} component_name_upper)
  # hyphen is not supported as macro name, replace it by underscore
  string(REPLACE "-" "_" component_name_upper ${component_name_upper})

  #------------------------------------
  # Create the target for this component, and configure it to be installed
  _gz_add_library_or_component(
    LIB_NAME ${component_target_name}
    INCLUDE_DIR "${PROJECT_INCLUDE_DIR}/${include_subdir}"
    EXPORT_BASE GZ_${GZ_DESIGNATION_UPPER}_${component_name_upper}
    SOURCES ${sources}
    ${interface_option})

  if(gz_add_component_INDEPENDENT_FROM_PROJECT_LIB  OR
     gz_add_component_PRIVATELY_DEPENDS_ON_PROJECT_LIB)

    # If we are not linking this component to the core library, then we need to
    # add these include directories to this component library directly. This is
    # not needed if we link to the core library, because that will pull in these
    # include directories automatically.
    target_include_directories(${component_target_name}
      ${property_type}
        # This is the publicly installed gz/math headers directory.
        "$<INSTALL_INTERFACE:${GZ_INCLUDE_INSTALL_DIR_FULL}>"
        # This is the in-build version of the core library's headers directory.
        # Generated headers for this component might get placed here, even if
        # the component is independent of the core library.
        "$<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/include>")

      file(MAKE_DIRECTORY "${PROJECT_BINARY_DIR}/include")

  endif()

  if(EXISTS "${PROJECT_SOURCE_DIR}/${component_name}/include")

    target_include_directories(${component_target_name}
      ${property_type}
        # This is the in-source version of the component-specific headers
        # directory. When exporting the target, this will not be included,
        # because it is tied to the build interface instead of the install
        # interface.
        "$<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/${component_name}/include>")

  endif()

  target_include_directories(${component_target_name}
    ${property_type}
      # This is the in-build version of the component-specific headers
      # directory. Generated headers for this component might end up here.
      "$<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/${component_name}/include>")

  file(MAKE_DIRECTORY "${PROJECT_BINARY_DIR}/${component_name}/include")

  #------------------------------------
  # Adjust variables if a specific C++ standard was requested
  _gz_handle_cxx_standard(gz_add_component
    ${component_target_name} ${component_name}_PKGCONFIG_CFLAGS)


  #------------------------------------
  # Adjust the packaging variables based on how this component depends (or not)
  # on the core library.
  if(gz_add_component_PRIVATELY_DEPENDS_ON_PROJECT_LIB)

    target_link_libraries(${component_target_name}
      PRIVATE ${PROJECT_LIBRARY_TARGET_NAME})

  endif()

  if(gz_add_component_INTERFACE_DEPENDS_ON_PROJECT_LIB)

    target_link_libraries(${component_target_name}
      INTERFACE ${PROJECT_LIBRARY_TARGET_NAME})

  endif()

  if(NOT gz_add_component_INDEPENDENT_FROM_PROJECT_LIB AND
     NOT gz_add_component_PRIVATELY_DEPENDS_ON_PROJECT_LIB AND
     NOT gz_add_component_INTERFACE_DEPENDS_ON_PROJECT_LIB)

    target_link_libraries(${component_target_name}
      ${property_type} ${PROJECT_LIBRARY_TARGET_NAME})

  endif()

  if(NOT gz_add_component_INDEPENDENT_FROM_PROJECT_LIB)

    # Add the core library as a cmake dependency for this component
    # NOTE: It seems we need to triple-escape "${gz_package_required}" and
    #       "${gz_package_quiet}" here.
    gz_string_append(${component_name}_CMAKE_DEPENDENCIES
      "if(NOT ${PKG_NAME}_CONFIG_INCLUDED)\n  find_package(${PKG_NAME} ${PROJECT_VERSION_FULL_NO_SUFFIX} EXACT \\\${gz_package_quiet} \\\${gz_package_required})\nendif()" DELIM "\n")

    # Choose what type of pkgconfig entry the core library belongs to
    set(lib_pkgconfig_type ${component_name}_PKGCONFIG_REQUIRES)
    if(gz_add_component_PRIVATELY_DEPENDS_ON_PROJECT_LIB
        AND NOT gz_add_component_INTERFACE_DEPENDS_ON_PROJECT_LIB)
      set(lib_pkgconfig_type ${lib_pkgconfig_type}_PRIVATE)
    endif()

    gz_string_append(${lib_pkgconfig_type} "${PKG_NAME} = ${PROJECT_VERSION_FULL_NO_SUFFIX}")

  endif()

  if(gz_add_component_DEPENDS_ON_COMPONENTS)
    gz_string_append(${component_name}_CMAKE_DEPENDENCIES
      "find_package(${PKG_NAME} ${PROJECT_VERSION_FULL_NO_SUFFIX} EXACT \\\${gz_package_quiet} \\\${gz_package_required} COMPONENTS ${gz_add_component_DEPENDS_ON_COMPONENTS})" DELIM "\n")
  endif()

  #------------------------------------
  # Set variables that are needed by cmake/gz-component-config.cmake.in
  set(component_pkg_name ${component_target_name})
  if(gz_add_component_INTERFACE)
    set(component_pkgconfig_lib)
  else()
    set(component_pkgconfig_lib "-l${component_pkg_name}")
  endif()
  set(component_cmake_dependencies ${${component_name}_CMAKE_DEPENDENCIES})
  # This next set is redundant, but it serves as a reminder that this input
  # variable is used in config files
  set(component_name ${component_name})

  # ... and by cmake/pkgconfig/gz-component.pc.in
  set(component_pkgconfig_requires ${${component_name}_PKGCONFIG_REQUIRES})
  set(component_pkgconfig_requires_private ${${component_name}_PKGCONFIG_REQUIRES_PRIVATE})
  set(component_pkgconfig_lib_deps ${${component_name}_PKGCONFIG_LIBS})
  set(component_pkgconfig_lib_deps_private ${${component_name}_PKGCONFIG_LIBS_PRIVATE})
  set(component_pkgconfig_cflags ${${component_name}_PKGCONFIG_CFLAGS})

  # Export and install the cmake target and package information
  _gz_create_cmake_package(COMPONENT ${component_name})

  # Generate and install the pkgconfig information for this component
  _gz_create_pkgconfig(COMPONENT ${component_name})


  #------------------------------------
  # Add this component to the "all" target
  target_link_libraries(${PROJECT_LIBRARY_TARGET_NAME}-all INTERFACE ${lib_name})
  get_property(all_known_components TARGET ${PROJECT_LIBRARY_TARGET_NAME}-all
    PROPERTY INTERFACE_IGN_ALL_KNOWN_COMPONENTS)
  if(NOT all_known_components)
    set_property(TARGET ${PROJECT_LIBRARY_TARGET_NAME}-all
      PROPERTY INTERFACE_IGN_ALL_KNOWN_COMPONENTS "${component_target_name}")
  else()
    set_property(TARGET ${PROJECT_LIBRARY_TARGET_NAME}-all
      PROPERTY INTERFACE_IGN_ALL_KNOWN_COMPONENTS "${all_known_components};${component_target_name}")
  endif()
endfunction()

#################################################
# Creates the `all` target. This function is private to gz-cmake.
function(_gz_create_all_target)

  add_library(${PROJECT_LIBRARY_TARGET_NAME}-all INTERFACE)

  install(
    TARGETS ${PROJECT_LIBRARY_TARGET_NAME}-all
    EXPORT ${PROJECT_LIBRARY_TARGET_NAME}-all
    LIBRARY DESTINATION ${GZ_LIB_INSTALL_DIR}
    ARCHIVE DESTINATION ${GZ_LIB_INSTALL_DIR}
    RUNTIME DESTINATION ${GZ_BIN_INSTALL_DIR}
    COMPONENT libraries)

endfunction()

#################################################
# Exports the `all` target. This function is private to gz-cmake.
function(_gz_export_target_all)

  # find_all_pkg_components is used as a variable in gz-all-config.cmake.in
  set(find_all_pkg_components "")
  get_property(all_known_components TARGET ${PROJECT_LIBRARY_TARGET_NAME}-all
    PROPERTY INTERFACE_IGN_ALL_KNOWN_COMPONENTS)

  if(all_known_components)
    foreach(component ${all_known_components})
      gz_string_append(find_all_pkg_components "find_dependency(${component} ${PROJECT_VERSION_FULL_NO_SUFFIX} EXACT)" DELIM "\n")
    endforeach()
  endif()

  _gz_create_cmake_package(ALL)

endfunction()

#################################################
# Used internally by _gz_add_library_or_component to report argument errors
macro(_gz_add_library_or_component_arg_error missing_arg)

  message(FATAL_ERROR "gz-cmake developer error: Must specify "
                      "${missing_arg} to _gz_add_library_or_component!")

endmacro()

#################################################
# This is only meant for internal use by gz-cmake. If you are a consumer
# of gz-cmake, please use gz_create_core_library(~) or
# gz_add_component(~) instead of this.
#
# _gz_add_library_or_component(LIB_NAME <lib_name>
#                               INCLUDE_DIR <dir_name>
#                               EXPORT_BASE <export_base>
#                               SOURCES <sources>)
#
macro(_gz_add_library_or_component)

  # NOTE: The following local variables are used in the Export.hh.in file, so if
  # you change their names here, you must also change their names there:
  # - include_dir
  # - export_base
  # - lib_name
  #
  # - _gz_export_base

  #------------------------------------
  # Define the expected arguments
  set(options INTERFACE)
  set(oneValueArgs LIB_NAME INCLUDE_DIR EXPORT_BASE)
  set(multiValueArgs SOURCES)

  #------------------------------------
  # Parse the arguments
  cmake_parse_arguments(_gz_add_library "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if(_gz_add_library_LIB_NAME)
    set(lib_name ${_gz_add_library_LIB_NAME})
  else()
    _gz_add_library_or_component_arg_error(LIB_NAME)
  endif()

  if(NOT _gz_add_library_INTERFACE)
    if(_gz_add_library_SOURCES)
      set(sources ${_gz_add_library_SOURCES})
    else()
      _gz_add_library_or_component_arg_error(SOURCES)
    endif()
  else()
    set(sources)
  endif()

  if(_gz_add_library_INCLUDE_DIR)
    set(include_dir ${_gz_add_library_INCLUDE_DIR})
  else()
    _gz_add_library_or_component_arg_error(INCLUDE_DIR)
  endif()

  if(_gz_add_library_EXPORT_BASE)
    set(export_base ${_gz_add_library_EXPORT_BASE})
  else()
    _gz_add_library_or_component_arg_error(EXPORT_BASE)
  endif()

  # check that export_base has no invalid symbols
  string(REPLACE "-" "_" export_base_replaced ${export_base})
  if(NOT ${export_base} STREQUAL ${export_base_replaced})
      message(FATAL_ERROR
        "export_base has a hyphen which is not"
        "supported by macros used for visibility")
  endif()

  #------------------------------------
  # Create the library target

  message(STATUS "Configuring library: ${lib_name}")

  if(_gz_add_library_INTERFACE)
    add_library(${lib_name} INTERFACE)
  else()
    add_library(${lib_name} ${sources})
  endif()

  #------------------------------------
  # Add fPIC if we are supposed to
  if(GZ_ADD_fPIC_TO_LIBRARIES AND NOT _gz_add_library_INTERFACE)
    target_compile_options(${lib_name} PRIVATE -fPIC)
  endif()

  if(NOT _gz_add_library_INTERFACE)

    #------------------------------------
    # Generate export macro headers
    # Note: INTERFACE libraries do not need the export header
    set(binary_include_dir
      "${CMAKE_BINARY_DIR}/include/${include_dir}")

    set(implementation_file_name "${binary_include_dir}/detail/Export.hh")

    include(GenerateExportHeader)
    # This macro will generate a header called detail/Export.hh which implements
    # some C-macros that are useful for exporting our libraries. The
    # implementation header does not provide any commentary or explanation for its
    # macros, so we tuck it away in the detail/ subdirectory, and then provide a
    # public-facing header that provides commentary for the macros.
    generate_export_header(${lib_name}
      BASE_NAME ${export_base}
      EXPORT_FILE_NAME ${implementation_file_name}
      EXPORT_MACRO_NAME DETAIL_${export_base}_VISIBLE
      NO_EXPORT_MACRO_NAME DETAIL_${export_base}_HIDDEN
      DEPRECATED_MACRO_NAME GZ_DEPRECATED_ALL_VERSIONS)

    set(install_include_dir
      "${GZ_INCLUDE_INSTALL_DIR_FULL}/${include_dir}")

    # Configure the installation of the automatically generated file.
    install(
      FILES "${implementation_file_name}"
      DESTINATION "${install_include_dir}/detail"
      COMPONENT headers)

    # Configure the public-facing header for exporting and deprecating. This
    # header provides commentary for the macros so that developers can know their
    # purpose.

    # TODO(CH3): Remove this on ticktock
    # This is to allow IGNITION_ prefixed export macros to generate in Export.hh
    # _using_gz_export_base is used in Export.hh.in's configuration!
    string(REGEX REPLACE "^GZ_" "IGNITION_" _gz_export_base ${export_base})

    configure_file(
      "${GZ_CMAKE_DIR}/Export.hh.in"
      "${binary_include_dir}/Export.hh")

    # Configure the installation of the public-facing header.
    install(
      FILES "${binary_include_dir}/Export.hh"
      DESTINATION "${install_include_dir}"
      COMPONENT headers)

    set_target_properties(
      ${lib_name}
      PROPERTIES
        SOVERSION ${PROJECT_VERSION_MAJOR}
        VERSION ${PROJECT_VERSION_FULL})

  endif()

  #------------------------------------
  # Configure the installation of the target

  install(
    TARGETS ${lib_name}
    EXPORT ${lib_name}
    LIBRARY DESTINATION ${GZ_LIB_INSTALL_DIR}
    ARCHIVE DESTINATION ${GZ_LIB_INSTALL_DIR}
    RUNTIME DESTINATION ${GZ_BIN_INSTALL_DIR}
    COMPONENT libraries)

endmacro()

#################################################
macro(ign_add_executable _name)
  # TODO(chapulina) Enable warnings after all libraries have migrated.
  # message(WARNING "ign_add_executable is deprecated, use gz_add_executable instead.")
  gz_add_executable(${_name} ${ARGN})
endmacro()
macro(gz_add_executable _name)
  add_executable(${_name} ${ARGN})
  target_link_libraries(${_name} ${general_libraries})
endmacro()

#################################################
# gz_target_interface_include_directories(<target> [include_targets])
#
# Add the INTERFACE_INCLUDE_DIRECTORIES of [include_targets] to the public
# INCLUDE_DIRECTORIES of <target>. This allows us to propagate the include
# directories of <target> along to any other libraries that depend on it.
#
# You MUST pass in targets to include, not directory names. We must not use
# explicit directory names here if we want our package to be relocatable.
function(ign_target_interface_include_directories name)
  # TODO(chapulina) Enable warnings after all libraries have migrated.
  # message(WARNING "ign_target_interface_include_directories is deprecated, use gz_target_interface_include_directories instead.")

  gz_target_interface_include_directories(name)
endfunction()
function(gz_target_interface_include_directories name)

  foreach(include_target ${ARGN})
    target_include_directories(
      ${name} PUBLIC
      $<TARGET_PROPERTY:${include_target},INTERFACE_INCLUDE_DIRECTORIES>)
  endforeach()

endfunction()

#################################################
macro(ign_install_includes _subdir)
  # TODO(chapulina) Enable warnings after all libraries have migrated.
  # message(WARNING "ign_install_includes is deprecated, use gz_install_includes instead.")
  gz_install_includes(${_subdir} ${ARGN})
endmacro()
macro(gz_install_includes _subdir)
  install(FILES ${ARGN}
    DESTINATION ${GZ_INCLUDE_INSTALL_DIR}/${_subdir} COMPONENT headers)
endmacro()

#################################################
macro(ign_install_executable _name )
  # TODO(chapulina) Enable warnings after all libraries have migrated.
  # message(WARNING "ign_install_executable is deprecated, use gz_install_executable instead.")
  gz_install_executable(${_name} ${ARGN})
endmacro()
macro(gz_install_executable _name)
  set_target_properties(${_name} PROPERTIES VERSION ${PROJECT_VERSION_FULL})
  install (TARGETS ${_name} DESTINATION ${GZ_BIN_INSTALL_DIR})
  manpage(${_name} 1)
endmacro()

#################################################
# Macro to setup supported compiler warnings
# Based on work of Florent Lamiraux, Thomas Moulard, JRL, CNRS/AIST.
# Internal to gz-cmake
macro(_gz_filter_valid_compiler_options var)

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
# gz_build_executables(SOURCES <sources>
#                       [PREFIX <prefix>]
#                       [LIB_DEPS <library_dependencies>]
#                       [INCLUDE_DIRS <include_dependencies>]
#                       [EXEC_LIST <output_var>]
#                       [EXCLUDE_PROJECT_LIB])
#
# Build executables for an Gazebo project. Arguments are as follows:
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
#                      link to your project's core library. On Windows, this
#                      will also skip the step of copying the runtime library
#                      into your executable's directory.
#
macro(ign_build_executables)
  # TODO(chapulina) Enable warnings after all libraries have migrated.
  # message(WARNING "ign_build_executables is deprecated, use gz_build_executables instead.")

  set(options EXCLUDE_PROJECT_LIB)
  set(oneValueArgs PREFIX EXEC_LIST)
  set(multiValueArgs SOURCES LIB_DEPS INCLUDE_DIRS)
  if(gz_build_executables_EXEC_LIST)
    set(${gz_build_executables_EXEC_LIST} "")
  endif()
  _gz_cmake_parse_arguments(gz_build_executables "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  set(gz_build_executables_skip_parsing true)
  gz_build_executables(${PACKAGE_NAME})
endmacro()
macro(gz_build_executables)

  # Deprecated, remove skip parsing logic in version 4
  if (NOT gz_build_executables_skip_parsing)
    #------------------------------------
    # Define the expected arguments
    set(options EXCLUDE_PROJECT_LIB)
    set(oneValueArgs PREFIX EXEC_LIST)
    set(multiValueArgs SOURCES LIB_DEPS INCLUDE_DIRS)

    if(gz_build_executables_EXEC_LIST)
      set(${gz_build_executables_EXEC_LIST} "")
    endif()

    #------------------------------------
    # Parse the arguments
    _gz_cmake_parse_arguments(gz_build_executables "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  endif()

  foreach(exec_file ${gz_build_executables_SOURCES})

    get_filename_component(BINARY_NAME ${exec_file} NAME_WE)
    set(BINARY_NAME ${gz_build_executables_PREFIX}${BINARY_NAME})

    add_executable(${BINARY_NAME} ${exec_file})

    if(gz_build_executables_EXEC_LIST)
      list(APPEND ${gz_build_executables_EXEC_LIST} ${BINARY_NAME})
    endif()

    if(NOT gz_build_executables_EXCLUDE_PROJECT_LIB)
      target_link_libraries(${BINARY_NAME} ${PROJECT_LIBRARY_TARGET_NAME})
    endif()

    if(gz_build_executables_LIB_DEPS)
      target_link_libraries(${BINARY_NAME} ${gz_build_executables_LIB_DEPS})
    endif()

    target_include_directories(${BINARY_NAME}
      PRIVATE
        ${PROJECT_SOURCE_DIR}
        ${PROJECT_BINARY_DIR}
        ${gz_build_executables_INCLUDE_DIRS})

  endforeach()

endmacro()

#################################################
# gz_build_tests(TYPE <test_type>
#                 SOURCES <sources>
#                 [LIB_DEPS <library_dependencies>]
#                 [INCLUDE_DIRS <include_dependencies>]
#                 [TEST_LIST <output_var>])
#
# Build tests for a Gazebo project. Arguments are as follows:
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
# EXCLUDE_PROJECT_LIB: Pass this argument if you do not want your tests to
#                      link to your project's core library. On Windows, this
#                      will also skip the step of copying the runtime library
#                      into your executable's directory.
#
macro(ign_build_tests)
  # TODO(chapulina) Enable warnings after all libraries have migrated.
  # message(WARNING "ign_build_tests is deprecated, use gz_build_tests instead.")

  set(options SOURCE EXCLUDE_PROJECT_LIB) # NOTE: DO NOT USE "SOURCE", we're adding it here to catch typos
  set(oneValueArgs TYPE TEST_LIST)
  set(multiValueArgs SOURCES LIB_DEPS INCLUDE_DIRS)
  _gz_cmake_parse_arguments(gz_build_tests "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  set(gz_build_tests_skip_parsing true)
  gz_build_tests(${PACKAGE_NAME})
endmacro()
macro(gz_build_tests)

  # Deprecated, remove skip parsing logic in version 4
  if (NOT gz_build_tests_skip_parsing)
    #------------------------------------
    # Define the expected arguments
    set(options SOURCE EXCLUDE_PROJECT_LIB) # NOTE: DO NOT USE "SOURCE", we're adding it here to catch typos
    set(oneValueArgs TYPE TEST_LIST)
    set(multiValueArgs SOURCES LIB_DEPS INCLUDE_DIRS)

    #------------------------------------
    # Parse the arguments
    _gz_cmake_parse_arguments(gz_build_tests "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  endif()

  if(NOT gz_build_tests_TYPE)
    # If you have encountered this error, you are probably migrating to the
    # new gz-cmake system. Be sure to also provide a SOURCES argument
    # when calling gz_build_tests.
    message(FATAL_ERROR "Developer error: You must specify a TYPE for your tests!")
  endif()

  if(gz_build_tests_SOURCE)

    # We have encountered cases where someone accidentally passes a SOURCE
    # argument instead of a SOURCES argument into gz_build_tests, and the macro
    # didn't report any problem with it. Adding this warning should make it more
    # clear when that particular typo occurs.
    message(AUTHOR_WARNING
      "Your script has specified SOURCE for gz_build_tests, which is not an "
      "option. Did you mean to specify SOURCES (note the plural)?")

  endif()

  set(TEST_TYPE ${gz_build_tests_TYPE})

  if(BUILD_TESTING)

    if(NOT DEFINED gz_build_tests_SOURCES)
      message(STATUS "No tests have been specified for ${TEST_TYPE}")
    else()
      list(LENGTH gz_build_tests_SOURCES num_tests)
      message(STATUS "Adding ${num_tests} ${TEST_TYPE} tests")
    endif()

    if(NOT gz_build_tests_EXCLUDE_PROJECT_LIB)
      gz_build_executables(
        PREFIX "${TEST_TYPE}_"
        SOURCES ${gz_build_tests_SOURCES}
        LIB_DEPS gtest gtest_main ${gz_build_tests_LIB_DEPS}
        INCLUDE_DIRS ${gz_build_tests_INCLUDE_DIRS}
        EXEC_LIST test_list)
    else()
      gz_build_executables(
        PREFIX "${TEST_TYPE}_"
        SOURCES ${gz_build_tests_SOURCES}
        LIB_DEPS gtest gtest_main ${gz_build_tests_LIB_DEPS}
        INCLUDE_DIRS ${gz_build_tests_INCLUDE_DIRS}
        EXEC_LIST test_list
        EXCLUDE_PROJECT_LIB)
    endif()

    if(gz_build_tests_TEST_LIST)
      set(${gz_build_tests_TEST_LIST} ${test_list})
    endif()

    # Find the Python interpreter for running the
    # check_test_ran.py script
    include(GzPython)

    # Build all the tests
    foreach(target_name ${test_list})

      if(USE_LOW_MEMORY_TESTS)
        target_compile_options(${target_name} PRIVATE -DUSE_LOW_MEMORY_TESTS=1)
      endif()

      add_test(NAME ${target_name} COMMAND
        ${target_name} --gtest_output=xml:${CMAKE_BINARY_DIR}/test_results/${target_name}.xml)

      if(UNIX)
        # gtest requies pthread when compiled on a Unix machine
        target_link_libraries(${target_name} pthread)
      endif()

      target_compile_definitions(${target_name} PRIVATE
        "TESTING_PROJECT_SOURCE_DIR=\"${PROJECT_SOURCE_DIR}\"")

      set_tests_properties(${target_name} PROPERTIES TIMEOUT 240)

      if(Python3_Interpreter_FOUND)
        # Check that the test produced a result and create a failure if it didn't.
        # Guards against crashed and timed out tests.
        add_test(check_${target_name} ${Python3_EXECUTABLE} ${GZ_CMAKE_TOOLS_DIR}/check_test_ran.py
          ${CMAKE_BINARY_DIR}/test_results/${target_name}.xml)
      endif()
    endforeach()

  else()

    message(STATUS "Testing is disabled -- skipping ${TEST_TYPE} tests")

  endif()

endmacro()

#################################################
# _gz_cmake_parse_arguments(<prefix> <options> <oneValueArgs> <multiValueArgs> [ARGN])
#
# Set <prefix> to match the prefix that is given to cmake_parse_arguments(~).
# This should also match the name of the function or macro that called it.
#
# NOTE: This should only be used by functions inside of gz-cmake specifically.
# Other Gazebo projects should not use this macro.
#
macro(_gz_cmake_parse_arguments prefix options oneValueArgs multiValueArgs)

  cmake_parse_arguments(${prefix} "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if(${prefix}_UNPARSED_ARGUMENTS)

    # The user passed in some arguments that we don't currently recognize. We'll
    # emit a warning so they can check whether they're using the correct version
    # of gz-cmake.
    message(AUTHOR_WARNING
      "\nThe build script has specified some unrecognized arguments for ${prefix}(~):\n"
      "${${prefix}_UNPARSED_ARGUMENTS}\n"
      "Either the script has a typo, or it is using an unexpected version of gz-cmake. "
      "The version of gz-cmake currently being used is ${gz-cmake${GZ_CMAKE_VERSION_MAJOR}_VERSION}\n")

  endif()

endmacro()
