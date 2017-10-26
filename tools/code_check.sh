#!/bin/sh

# Jenkins will pass -xml, in which case we want to generate XML output
xmlout=0
if test "$1" = "-xmldir" -a -n "$2"; then
  xmlout=1
  xmldir=$2
  mkdir -p $xmldir
  rm -rf $xmldir/*.xml
  # Assuming that Jenkins called, the `build` directory is a sibling to the src dir
  builddir=../build
else
  # This is a heuristic guess; not every developer puts the `build` dir in the src dir
  builddir=./build
fi

if [ $xmlout -eq 1 ]; then
  cat << END > $xmldir/code_check.xml
<?xml version="1.0" encoding="UTF-8"?>
<results>
END
fi

if [ $xmlout -eq 1 ]; then
  cat << END >> $xmldir/code_check.xml
</results>
END
fi
