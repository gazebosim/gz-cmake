#!/bin/bash
if pkg-config ignition-core_child --print-requires \
  | grep ignition-core_no_deps
then
  echo Successfully detected ignition-core_no_deps requirement
  cp core_child_requires_core_no_deps_pass.xml ../test_results/core_child_requires_core_no_deps.xml
  exit 0
else
  echo Could not detect ignition-core_no_deps requirement
  cp core_child_requires_core_no_deps_fail.xml ../test_results/core_child_requires_core_no_deps.xml
  exit 1
fi

