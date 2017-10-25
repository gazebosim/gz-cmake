#!/usr/bin/env python
from __future__ import print_function
import os
import sys
from datetime import datetime

def usage():
    print("""Usage:
\t{0} test_name output_name
""".format(__file__), file=sys.stderr)
    print(sys.argv)
    sys.exit(getattr(os, 'EX_USAGE', 1))

def check_main():
    if (len(sys.argv) < 2):
        usage()
    test_file = sys.argv[1]
    test_name = os.path.basename(test_file).replace('.xml', '')
    junit_string ="""
<?xml version="1.0" encoding="UTF-8"?>
<testsuites tests="1" failures="0" disabled="0" errors="0" timestamp="{1}" time="0" name="AllTests">
  <testsuite name="{0}" tests="1" failures="0" disabled="0" errors="0" time="0">
    <testcase name="make" status="run" time="0" classname="{0}" />
  </testsuite>
</testsuites>
"""
    timestamp = datetime.now().strftime("%Y-%m-%dT%H:%M:%S")
    if not os.path.exists(os.path.dirname(test_file)):
        os.makedirs(os.path.dirname(test_file))
    with open(test_file, 'w') as f:
      f.write(junit_string.format(test_name, timestamp))

if __name__ == '__main__':
    check_main()
