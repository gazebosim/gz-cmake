#!/bin/sh

# This file can be downloaded (such as through curl) and used in CI to check
# that there are no doxygen warnings. For example, if you're using bitbucket
# pipelines then you can add the following line to your bitbucket-pipelines.yml
# file:
#   - bash <(curl -s https://bitbucket.org/ignitionrobotics/ign-cmake/raw/3b2778025650d050d0a85f5170a0aa6b35b68bc7/tools/doc_check.sh)
if [ -s ignition-doxygen.warn ]; then
  exit 0
else
  exit 1
fi
