#!/usr/bin/env bash
TEST_STATUS=0

CONFIG_FILE="${EXAMPLE_INSTALL_DIR}/lib/cmake/gz-comp_deps-child/gz-comp_deps-child-config.cmake"

echo
echo "Checking generated gz-comp_deps-child CMake dependencies:"
echo "${CONFIG_FILE}"

EXPECTED_CORE='find_package(gz-comp_deps 0.1.0 EXACT ${gz_package_quiet} ${gz_package_required})'
EXPECTED_COMPONENT='find_package(gz-comp_deps 0.1.0 EXACT ${gz_package_quiet} ${gz_package_required} COMPONENTS parent)'

echo
echo "Expect core dependency:"
grep -nF "${EXPECTED_CORE}" "${CONFIG_FILE}"
if ! grep -qF "${EXPECTED_CORE}" "${CONFIG_FILE}"
then
  echo "oops"
  TEST_STATUS=1
fi

echo
echo "Expect component dependency:"
grep -nF "${EXPECTED_COMPONENT}" "${CONFIG_FILE}"
if ! grep -qF "${EXPECTED_COMPONENT}" "${CONFIG_FILE}"
then
  echo "oops"
  TEST_STATUS=1
fi

if [[ $TEST_STATUS -eq 0 ]]
then
  echo "Successfully detected gz_add_component CMake dependencies"
  exit 0
else
  echo "Could not detect gz_add_component CMake dependencies correctly"
  exit 1
fi
