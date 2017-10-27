#!/bin/bash
# Verify that cmake_minimum_required statements have matching version numbers

unset TEST_CMAKE_MIN_REQUIRED_FAILED
# first argument is root of ign-cmake repository
if [[ ! -d "$1"  \
   || ! -a "$1/CMakeLists.txt" \
   || ! -a "$1/cmake/ignition-config.cmake.in" \
   || ! -a "$1/config/ignition-cmake-config.cmake.in" ]]; then
  echo the first argument must be the root of the ign-cmake repository
  export TEST_CMAKE_MIN_REQUIRED_FAILED=1
else
  grep -h '^cmake_minimum_required' \
    $1/CMakeLists.txt \
    $1/cmake/ignition-config.cmake.in \
    $1/config/ignition-cmake-config.cmake.in \
    | uniq -c \
    | awk '{ if ($1 != "3") { exit 1 }}' \
    || \
    export TEST_CMAKE_MIN_REQUIRED_FAILED=1
fi

if test "$2" = "--xml_output_dir"; then
  xml_output_dir=$3
  if [[ ! -a "${xml_output_dir}" ]]; then
    mkdir -p "${xml_output_dir}"
  fi
  if [[ ! -d "${xml_output_dir}" ]]; then
    echo If using --xml_output_dir, the 3rd argument must be a directory.
    exit 1
  fi
  if [[ -z ${TEST_CMAKE_MIN_REQUIRED_FAILED} ]]; then
    cat <<END > ${xml_output_dir}/cmake_minimum_required.xml
<?xml version="1.0" encoding="UTF-8"?>
<testsuites tests="1" failures="0" disabled="0" errors="0" timestamp="$(date '+%Y-%m-%dT%H:%M:%S')" time="0" name="AllTests">
  <testsuite name="cmake_minimum_required" tests="1" failures="0" disabled="0" errors="0" time="0">
    <testcase name="make" status="run" time="0" classname="cmake_minimum_required" />
  </testsuite>
</testsuites>
END
  else
    cat <<END > ${xml_output_dir}/cmake_minimum_required.xml
<?xml version="1.0" encoding="UTF-8"?>
<testsuites tests="1" failures="1" disabled="0" errors="0" timestamp="$(date '+%Y-%m-%dT%H:%M:%S')" time="0" name="AllTests">
  <testsuite name="cmake_minimum_required" tests="1" failures="1" disabled="0" errors="0" time="0">
    <testcase name="make" status="run" time="0" classname="cmake_minimum_required">
      <failure type="Standard" message="cmake_minimum_required version numbers do not match."><![CDATA[
END
  grep -n '^cmake_minimum_required' \
    $1/CMakeLists.txt \
    $1/cmake/ignition-config.cmake.in \
    $1/config/ignition-cmake-config.cmake.in \
    >> ${xml_output_dir}/cmake_minimum_required.xml
    cat <<END >> ${xml_output_dir}/cmake_minimum_required.xml
      ]]></failure>
    </testcase>
  </testsuite>
</testsuites>
END
    exit 1
  fi
else
  echo Verify that cmake_minimum_required statements have matching version numbers
  grep -n '^cmake_minimum_required' \
    $1/CMakeLists.txt \
    $1/cmake/ignition-config.cmake.in \
    $1/config/ignition-cmake-config.cmake.in \
    | sed -e 's@^@  @'
  if [[ -z ${TEST_CMAKE_MIN_REQUIRED_FAILED} ]]; then
    echo --------------------------- Passed ---------------------------
  else
    echo --------------------------- Failed ---------------------------
    exit 1
  fi
fi
