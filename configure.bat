
:: NOTE: This script is only meant to be used as part of the ignition developers' CI system
:: Users and developers should build and install this library using cmake and Visual Studio

:: ign-cmake has no dependencies

:: Set configuration variables
@set build_type=Release
@if not "%1"=="" set build_type=%1
echo Configuring for build type %build_type%
echo **********************************************

:: Go to the directory that this file configure.bat file exists in
cd /d %~dp0

:: Create a build directory and configure
md build
cd build
cmake .. -G "NMake Makefiles" -DCMAKE_INSTALL_PREFIX="%WORKSPACE_INSTALL_DIR%" -DBUILD_TESTING:BOOL=False -DCMAKE_BUILD_TYPE="%build_type%"

:: If the caller wants to build and/or install, they should do so after calling this script
