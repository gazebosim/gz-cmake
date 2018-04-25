#!/bin/bash
no_deps=ignition-$1
child=ignition-$2
if pkg-config ${child} --print-requires \
  | grep ${no_deps}
then
  echo Successfully detected ${no_deps} requirement
  cp core_child_requires_core_no_deps_pass.xml ../test_results/core_child_requires_core_no_deps.xml
  exit 0
else
  echo Could not detect ${no_deps} requirement
  cp core_child_requires_core_no_deps_fail.xml ../test_results/core_child_requires_core_no_deps.xml
  exit 1
fi

