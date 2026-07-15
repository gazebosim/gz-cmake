#!/usr/bin/env bash
TEST_STATUS=0

echo
echo Expect correct escaping in cmake config find_package call
EXPECTED_LINE='find_package(gz-c_no_deps ${gz_package_quiet} ${gz_package_required})'
CONFIG_FILE=${EXAMPLE_INSTALL_DIR}/lib/cmake/gz-c_child_private/gz-c_child_private-config.cmake
echo ${EXPECTED_LINE}
grep 'find_package(gz-c_no_deps' ${CONFIG_FILE}
if ! grep -q "${EXPECTED_LINE}" ${CONFIG_FILE}
then
  echo oops
  TEST_STATUS=1
fi

echo
echo Expect gz-c_child to require gz-c_no_deps
pkg-config gz-c_child --print-requires
if ! pkg-config gz-c_child --print-requires \
  | grep gz-c_no_deps
then
  echo oops
  TEST_STATUS=1
fi

echo
echo Expect gz-c_child to not privately require gz-c_no_deps
pkg-config gz-c_child --print-requires-private
if pkg-config gz-c_child --print-requires-private \
  | grep gz-c_no_deps
then
  echo oops
  TEST_STATUS=1
fi

echo
echo Expect gz-c_child_private to privately require gz-c_no_deps
pkg-config gz-c_child_private --print-requires-private
if ! pkg-config gz-c_child_private --print-requires-private \
  | grep gz-c_no_deps
then
  echo oops
  TEST_STATUS=1
fi

echo
echo Expect gz-c_child_private to not require gz-c_no_deps
pkg-config gz-c_child_private --print-requires
if pkg-config gz-c_child_private --print-requires \
  | grep gz-c_no_deps
then
  echo oops
  TEST_STATUS=1
fi

echo
if [[ $TEST_STATUS -eq 0 ]]
then
  echo Successfully detected gz-c_nodep requirements
  cp c_child_requires_c_nodep_pass.xml ../test_results/c_child_requires_c_nodep.xml
  exit 0
else
  echo Could not detect all gz-c_nodep requirements correctly
  cp c_child_requires_c_nodep_fail.xml ../test_results/c_child_requires_c_nodep.xml
  exit 1
fi
