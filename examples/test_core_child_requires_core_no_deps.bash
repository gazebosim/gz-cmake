#!/bin/bash
TEST_STATUS=0

echo
echo Expect gz-core_child to require gz-core_no_deps
pkg-config gz-core_child --print-requires
if ! pkg-config gz-core_child --print-requires \
  | grep gz-core_no_deps
then
  echo oops
  TEST_STATUS=1
fi

echo
echo Expect gz-core_child to not privately require gz-core_no_deps
pkg-config gz-core_child --print-requires-private
if pkg-config gz-core_child --print-requires-private \
  | grep gz-core_no_deps
then
  echo oops
  TEST_STATUS=1
fi

echo
echo Expect gz-core_child_private to privately require gz-core_no_deps
pkg-config gz-core_child_private --print-requires-private
if ! pkg-config gz-core_child_private --print-requires-private \
  | grep gz-core_no_deps
then
  echo oops
  TEST_STATUS=1
fi

echo
echo Expect gz-core_child_private to not require gz-core_no_deps
pkg-config gz-core_child_private --print-requires
if pkg-config gz-core_child_private --print-requires \
  | grep gz-core_no_deps
then
  echo oops
  TEST_STATUS=1
fi

echo
if [[ $TEST_STATUS -eq 0 ]]
then
  echo Successfully detected gz-core_nodep requirements
  cp core_child_requires_core_nodep_pass.xml ../test_results/core_child_requires_core_nodep.xml
  exit 0
else
  echo Could not detect all gz-core_nodep requirements correctly
  cp core_child_requires_core_nodep_fail.xml ../test_results/core_child_requires_core_nodep.xml
  exit 1
fi
