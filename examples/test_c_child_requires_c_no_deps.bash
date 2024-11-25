#!/bin/bash
TEST_STATUS=0

echo
echo Expect ignition-c_child to require ignition-c_no_deps
pkg-config ignition-c_child --print-requires
if ! pkg-config ignition-c_child --print-requires \
  | grep ignition-c_no_deps
then
  echo oops
  TEST_STATUS=1
fi

echo
echo Expect ignition-c_child to not privately require ignition-c_no_deps
pkg-config ignition-c_child --print-requires-private
if pkg-config ignition-c_child --print-requires-private \
  | grep ignition-c_no_deps
then
  echo oops
  TEST_STATUS=1
fi

echo
echo Expect ignition-c_child_private to privately require ignition-c_no_deps
pkg-config ignition-c_child_private --print-requires-private
if ! pkg-config ignition-c_child_private --print-requires-private \
  | grep ignition-c_no_deps
then
  echo oops
  TEST_STATUS=1
fi

echo
echo Expect ignition-c_child_private to not require ignition-c_no_deps
pkg-config ignition-c_child_private --print-requires
if pkg-config ignition-c_child_private --print-requires \
  | grep ignition-c_no_deps
then
  echo oops
  TEST_STATUS=1
fi

echo
if [[ $TEST_STATUS -eq 0 ]]
then
  echo Successfully detected ignition-c_nodep requirements
  cp c_child_requires_c_nodep_pass.xml ../test_results/c_child_requires_c_nodep.xml
  exit 0
else
  echo Could not detect all ignition-c_nodep requirements correctly
  cp c_child_requires_c_nodep_fail.xml ../test_results/c_child_requires_c_nodep.xml
  exit 1
fi
