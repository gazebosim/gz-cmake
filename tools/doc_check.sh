#!/bin/sh

if [ -s ignition-doxygen.warn ]; then
  return 1
else
  return 0
fi
