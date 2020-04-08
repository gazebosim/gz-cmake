#!/bin/bash
TEST_STATUS=0

if ! pkg-config ignition-core_child --print-requires \
  | grep ignition-core_no_deps
then
  TEST_STATUS=1
fi

if pkg-config ignition-core_child --print-requires-private \
  | grep ignition-core_no_deps
then
  TEST_STATUS=1
fi

if ! pkg-config ignition-core_child_private --print-requires-private \
  | grep ignition-core_no_deps
then
  TEST_STATUS=1
fi

if pkg-config ignition-core_child_private --print-requires \
  | grep ignition-core_no_deps
then
  TEST_STATUS=1
fi

if [[ $TEST_STATUS ]]
  echo Successfully detected ignition-core_nodep requirements
  cp core_child_requires_core_nodep_pass.xml ../test_results/core_child_requires_core_nodep.xml
  exit 0
else
  echo Could not detect ignition-core_nodep requirements
  cp core_child_requires_core_nodep_fail.xml ../test_results/core_child_requires_core_nodep.xml
  exit 1
fi
