\page install Installation

# Install

These instructions are for installing only Ignition CMake. If you're interested
in using all the Ignition libraries, not only Igniton CMake, check out this
[Ignition installation](https://ignitionrobotics.org/docs/latest/install).

We recommend following the binary install instructions to get up and running as
quickly and painlessly as possible.

The source install instructions should be used if you need the very latest
software improvements, if you need to modify the code, or if you plan to make a
contribution.

## Binary Install

### Ubuntu

On Ubuntu, it's possible to install Ignition CMake as follows:

Add OSRF packages:

    echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list
    sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys D2486D2DD83DB69272AFE98867170598AF249743
    sudo apt update

Install Ignition CMake:

    sudo apt install libignition-cmake<#>-dev

Be sure to replace `<#>` with a number value, such as 1 or 2, depending on
which version you need.

### macOS

On macOS, add OSRF packages:

    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew tap osrf/simulation

Install Ignition CMake:

    brew install ignition-cmake<#>

Be sure to replace `<#>` with a number value, such as 1 or 2, depending on
which version you need.

## Source Install

### Prerequisites

#### Ubuntu Bionic 18.04 or above

Add OSRF packages:

    sudo apt update
    sudo apt -y install wget lsb-release gnupg
    sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list'
    wget http://packages.osrfoundation.org/gazebo.key -O - | apt-key add -
    sudo apt-add-repository -s "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -c -s) main"

Only on Bionic, update the GCC compiler version:

    sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 800 --slave /usr/bin/g++ g++ /usr/bin/g++-8 --slave /usr/bin/gcov gcov /usr/bin/gcov-8

#### Windows 10

1. Install [Conda package management system](https://docs.conda.io/projects/conda/en/latest/user-guide/install/download.html).
   Miniconda suffices.

1. Install [Visual Studio 2019](https://visualstudio.microsoft.com/downloads/).
   The Community version is free for students, open-source contributors, and individuals.
   Check "Desktop development with C++" in the Workloads tab, and uncheck C++ CMake Tools. We will install cmake via Conda.

### Building from source

#### Ubuntu

Clone source code:

    # This checks out the `main` branch. You can append `-b ign-cmake#` (replace # with a number) to checkout a specific version
    git clone http://github.com/ignitionrobotics/ign-cmake

Install dependencies

    sudo apt -y install $(sort -u $(find . -iname 'packages.apt') | tr '\n' ' ')

Build and install as follows:

    cd ign-cmake
    mkdir build
    cd build
    cmake ..
    make -j4
    sudo make install

#### Windows

Open a Visual Studio Command Prompt (search for "x64 Native Tools Command Prompt for VS 2019" in the Windows search near the Start button).
Right-click and run as Administrator.
Optionally, right-click and pin to the task bar for quick access in the future.

If you did not add Conda to your ``PATH`` environment variable during Conda installation, you may need to navigate to the location of ``condabin`` in order to use the `conda` command.
To find ``condabin``, search for "Anaconda Prompt" in the Windows search near the Start button, open it, run ``where conda``, and look for a line containing the directory ``condabin``.

1. Navigate to your ``condabin`` if necessary, and then create and activate a Conda environment:

        conda create -n ign-ws
        conda activate ign-ws

   Once you have activated an environment, a prefix like ``(ign-ws)`` will be prepended to your prompt, and you can use the ``conda`` command outside of ``condabin``.

   You can use ``conda info --envs`` to see all your environments.

   To remove an environment, use``conda env remove --name <env_name>``.

1. Install dependencies

        conda install -c conda-forge colcon-common-extensions git cmake pkg-config

1. Navigate to where you would like to build the library, and then clone the repository.
   We will be using a [colcon](https://colcon.readthedocs.io/en/released/) workspace structure.

        mkdir ign_ws
        cd ign_ws
        mkdir src
        cd src
        # This checks out the `main` branch. You can append `-b ign-cmake#` (replace # with a number) to checkout a specific version
        git clone https://github.com/ignitionrobotics/ign-cmake.git

1. Compile

        # Replace <#> with the numeric version you cloned
        colcon build --cmake-args -DBUILD_TESTING=OFF --merge-install --packages-up-to ignition-cmake<#>

# Documentation

API documentation and tutorials can be accessed at
[https://ignitionrobotics.org/libs/cmake](https://ignitionrobotics.org/libs/cmake)

You can also generate the documentation from a clone of this repository by following these steps.

1. You will need [Doxygen](http://www.doxygen.org/). On Ubuntu Doxygen can be installed using

        sudo apt-get install doxygen

2. Clone the repository

        git clone https://github.com/ignitionrobotics/ign-cmake

3. Configure and build the documentation.

        cd ign-cmake
        mkdir build
        cd build
        cmake ..
        make doc

4. View the documentation by running the following command from the `build` directory.

        firefox doxygen/html/index.html

# Testing

Follow these steps to run tests and static code analysis in your clone of this repository.

1. Follow the [source install instruction](#source-install).

2. Run tests.

        make test

3. Static code checker.

        make codecheck

See the [Writing Tests section of the contributor cmakede](https://ignitionrobotics.org/docs/all/contributing#writing-tests) for help creating or modifying tests.
