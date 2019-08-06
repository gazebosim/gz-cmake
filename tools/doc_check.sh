#!/bin/sh

# This file can be downloaded (such as through curl) and used in CI to check
# that there are no doxygen warnings. For example, if you're using bitbucket
# pipelines then you can add the following line to your bitbucket-pipelines.yml
# file:
#   - bash <(curl -s https://bitbucket.org/ignitionrobotics/ign-cmake/src/1a4d101cf4c1d3b8232d3da115995c99ea532ae7/tools/doc_check.sh)
if [ -s ignition-doxygen.warn ]; then
  exit 1
else
  exit 0
fi
