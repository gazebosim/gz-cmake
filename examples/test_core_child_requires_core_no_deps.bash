#!/bin/bash
TEST_STATUS=0

echo
echo Expect ignition-core_child to require ignition-core_no_deps
pkg-config ignition-core_child --print-requires
if ! pkg-config ignition-core_child --print-requires \
  | grep ignition-core_no_deps
then
  echo oops
  TEST_STATUS=1
fi

echo
echo Expect ignition-core_child to not privately require ignition-core_no_deps
pkg-config ignition-core_child --print-requires-private
if pkg-config ignition-core_child --print-requires-private \
  | grep ignition-core_no_deps
then
  echo oops
  TEST_STATUS=1
fi

echo
echo Expect ignition-core_child_private to privately require ignition-core_no_deps
pkg-config ignition-core_child_private --print-requires-private
if ! pkg-config ignition-core_child_private --print-requires-private \
  | grep ignition-core_no_deps
then
  echo oops
  TEST_STATUS=1
fi

echo
echo Expect ignition-core_child_private to not require ignition-core_no_deps
pkg-config ignition-core_child_private --print-requires
if pkg-config ignition-core_child_private --print-requires \
  | grep ignition-core_no_deps
then
  echo oops
  TEST_STATUS=1
fi

echo
if [[ $TEST_STATUS -eq 0 ]]
then
  echo Successfully detected ignition-core_nodep requirements
  cp core_child_requires_core_nodep_pass.xml ../test_results/core_child_requires_core_nodep.xml
  exit 0
else
  echo Could not detect all ignition-core_nodep requirements correctly
  cp core_child_requires_core_nodep_fail.xml ../test_results/core_child_requires_core_nodep.xml
  exit 1
fi
