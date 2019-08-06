#!/bin/sh

# This file can be downloaded (such as through curl) and used in CI to check
# that there are no doxygen warnings. For example, if you're using bitbucket
# pipelines then you can add the following line to your bitbucket-pipelines.yml
# file:
#   - bash <(curl -s https://bitbucket.org/ignitionrobotics/ign-cmake/raw/02de4e1a3690e0ea37b190f9c35ecf25e6b0e251/tools/doc_check.sh)
if [ -f ignition-doxygen.warn ]; then
  if [ -s ignition-doxygen.warn ]; then
    echo "Error. The following warnings were found in ignition-doxygen.warn."
    cat ignition-doxygen.warn
    exit 1
  else
    echo "Success. No warnings found in ignition-doxygen.warn."
    exit 0
  fi
else
  echo "The ignition-doxygen.warn file does not exist. Skipping doc check."
fi
