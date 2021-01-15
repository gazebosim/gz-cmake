\page developingwithcmake Developing with Ignition CMake

# Developing with Ignition CMake

This tutorial documents various tips and strategies for developing with Ignition CMake.

## Helpful CMake flags

There are several flags that control the results of the CMake tool.
Some of these flags are built into CMake, where some are Ignition CMake specific.

All of the following flags may be set as part of an individual CMake invocation.
Alternatively, the flags may be passed to `colcon` using techniques described later in this document.

### Setting the build type

The `CMAKE_BUILD_TYPE` variable controls the type of binary output from the build stage.
This will have an impact on the flags passed to the compiler and linker.

The available options are:

* `RelWithDebInfo`: Mostly optimized build, but with debug symbols.
* `Debug`: Debug build without optimizations, with debug symbols enabled.
* `Release`: Fully optimized build, no debug symbols.
* `MinSizeRel`: Fully optimized build, minimal binary size
* `Coverage`: Build with additional information required for the [`gcov` analysis tool](https://en.wikipedia.org/wiki/Gcov)
* `Profile`: Use flags that are helpful with the [`gprof` profiling tool](https://en.wikipedia.org/wiki/Gprof)

More information about flags applied can be found in [IgnSetCompilerFlags.cmake](https://github.com/ignitionrobotics/ign-cmake/blob/ign-cmake2/cmake/IgnSetCompilerFlags.cmake)

If left unspecified, `CMAKE_BUILD_TYPE` is set to `RelWithDebInfo`

To change the build type, set the CMake flag:

```
-DCMAKE_BUILD_TYPE=Debug
```

### Creating a compilation database

`CMake` can optionally generate a compilation data base that may be used with a variety of code completion tools.

By default, a compilation database is *not generated*

To enable compilation database generation, set the CMake flag:

```
-DCMAKE_EXPORT_COMPILE_COMMANDS=ON
```

For more information about what the compilation database is, consult the [`clang` documentation](https://clang.llvm.org/docs/JSONCompilationDatabase.html)

Some examples of utilities that can use the compilation database:

* [`coc.vim`](https://github.com/neoclide/coc.nvim): Code completion for VIM
* [`YouCompleteMe`](https://github.com/ycm-core/YouCompleteMe) Code completion for VIM

### Using the ninja build system

Rather than using `make`, it may be desired to use the [Ninja](https://ninja-build.org/) build tool.

By default `make` will be used.

To change the build system type, set the CMake flag:

```
-GNinja
```

### Address sanitizer (ASan)

The `gcc` and `clang` compilers have a set of flags to generate instrumented builds for detecting memory leaks.

By default, address sanitizer is *not used*.

To enable address sanitizer, set all of the following flags:

```
-DCMAKE_CXX_FLAGS="-fsanitize=address -fsanitize=leak -g"
-DCMAKE_C_FLAGS="-fsanitize=address -fsanitize=leak -g"
-DCMAKE_EXE_LINKER_FLAGS="-fsanitize=address -fsanitize=leak"
-DCMAKE_MODULE_LINKER_FLAGS="-fsanitize=address -fsanitize=leak"
```

This will report if memory is leaked during execution of binaries or tests.

More information about address santizier can be found in the [ASan documentation](https://github.com/google/sanitizers/wiki/AddressSanitizer).

Note: Address sanitizer may have an impact on the performance of execution.

### Using CCache

When you are doing frequent rebuilds, you can use a program to cache intermediate compiler results.

First, install [`ccache`](https://ccache.dev/) and configure it to an appropriate cache size for your system:

```
$ sudo apt update && sudo apt install ccache
$ ccache -M10G
Set cache size limit to 10.0 GB
```

Then set the CMake flags:

```
-DCMAKE_C_COMPILER_LAUNCHER=ccache
-DCMAKE_CXX_COMPILER_LAUNCHER=ccache
```

### Enabling/Disabling Documentation

When you are doing frequent rebuilds, it generally doesn't make sense to rebuild documentation each build.

By default, building documentation is *enabled*.

To disable building documentation, set the CMake flag:

```
-DBUILD_DOCS=OFF
```

### Enabling/Disabling Tests

If your intent is to only produce libraries and executables, it is possible to disables tests.

By default, building tests is *enabled*.

To disable building tests, set the CMake flag:

```
-DBUILD_TESTING=OFF
```

### Enabling/Disabling Buildsystem Tests

There are additional tests of the Ignition CMake buildsystem.
It is recommend to run these tests when making modifications to the Ignition CMake codebase.

By default, building buildsystem tests is *disabled*.

To enable building buildsystem tests, set the CMake flags:

```
-DBUILD_TESTING=ON
-DBUILDSYSTEM_TESTING=ON
```

## Developing with Colcon and vcstool

[`colcon`](https://colcon.readthedocs.io/en/released/) is a tool that improves the workflow of building and testing multiple software packages.
As an Ignition collection is composed of multiple packages that are frequently built and tested together, `colcon` eases this workflow.

The basic outline of obtaining Ignition source packages via `vcs` and building with `colcon` is available in the [Ignition source installation documentation](https://ignitionrobotics.org/docs/latest/install_ubuntu_src).

### Passing CMake flags via command line

When performing `colcon` builds, flags may be passed to Ignition CMake to configure the build.

This can be done via the `--cmake-args` flag in `colcon`:

```
colcon build --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=1
```

### Passing colcon mixins via command line

To ease configuration of common flags, `colcon` has a concept of `mixins`, that are flags that "shortcut" groups of behavior.

The set of readily-available defaults is in the [colcon-mixin-repository](https://github.com/colcon/colcon-mixin-repository).

To install:

```
$ colcon mixin add default https://raw.githubusercontent.com/colcon/colcon-mixin-repository/master/index.yaml
$ colcon mixin update default
$ colcon mixin show
```

An example of building with `colcon` with two mixins:
 * [`ccache` mixin](https://github.com/colcon/colcon-mixin-repository/blob/master/ccache.mixin)
 * [`rel-with-db-info` mixin](https://github.com/colcon/colcon-mixin-repository/blob/master/build-type.mixin)

```
colcon build --mixin ccache rel-with-deb-info
```

This will build with the flags applied from the requested mixins.

Colcon allows you to create your own mixins for commonly-reused command line flags.
For more information about creating mixins, consult the [`colcon mixin` documentation](https://colcon.readthedocs.io/en/released/reference/mixin-arguments.html)

### Using a defaults file

It is useful to be able to apply a consistent set of flags across an entire Ignition collection when building.
One mechanism for accomplishing this is a `defaults.yaml` file.
This is a file of configuration options that `colcon` will read to customize the default behavior.
More information about the `defaults.yaml` file can be found in the corresponding [`colcon` documentation](https://colcon.readthedocs.io/en/released/user/configuration.html#defaults-yaml)

For the following, if you do not have `colcon` or `vcs` installed, consult the [Ignition source installation documentation](https://ignitionrobotics.org/docs/latest/install_ubuntu_src).

To try this out, first create an Ignition source workspace:
```
mkdir -p ~/ign_edifice/src
cd ~/ign_edifice/
wget https://raw.githubusercontent.com/ignition-tooling/gazebodistro/master/collection-edifice.yaml
vcs import src < collection-edifice.yaml
```

Then add a `~/ign_edifice/defaults.yaml` file with compilation flags:

```
{
  "build": {
    "merge-install": true,
    "symlink-install": true,
    "cmake-args": [
      "--no-warn-unused-cli",
      "-DCMAKE_EXPORT_COMPILE_COMMANDS=1",
      "-DCMAKE_BUILD_TYPE=RelWithDebInfo",
    ]
  }
}
```

To build with this defaults file, first export the correct environment variable and execute colcon:

```
cd ~/ign_edifice
export COLCON_DEFAULTS_FILE=`pwd`/defaults.yaml
colcon build
```

### Using a defaults file with mixins

Mixins can also be applied via the `defaults.yaml` file:

```
{
  "build": {
    "merge-install": true,
    "symlink-install": true,
    "mixins": [
      "compile-commands",
      "rel-with-deb-info",
    ]
  }
}
```

### Setting a per-workspace defaults file with direnv

Optionally, defaults can be applied user-wide by placing a defaults file at `$COLCON_HOME/defaults.yaml` (which is `~/.colcon/defaults.yaml` by default).

In order to manage per-workspace settings, a tool like [`direnv`](https://direnv.net/) can be used to automate the application of the environment variable.
Once `direnv` is installed and configured with your shell of choice, do the following:

```
$ cd ~/ign_edifice/
# The environment variable will be unset
$ echo $COLCON_DEFAULTS_FILE

$ echo export COLCON_DEFAULTS_FILE=`pwd`/defaults.yaml > .envrc
direnv: error .envrc is blocked, Run `direnv allow` to approve its content
$ direnv allow
direnv: loading ~/ign_edifice/.envrc
direnv: export +COLCON_DEFAULTS_FILE

$ echo $COLCON_DEFAULTS_FILE
~/ign_edifice/defaults.yaml
```

Once this is configured, the environment will be applied each time you navigate to the `~/ign_edifice` directory or its children.
