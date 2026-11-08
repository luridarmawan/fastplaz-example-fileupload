#!/bin/bash
if [ -n "$1" ]; then
  PROJECTBASE=$1
  PROJECTFILE=$1.lpr
  echo "Project: "$PROJECTBASE
else
  echo "USAGE:"
  echo "  ./build.sh yourproject"
  exit 0
fi

# is project file exists?
if [ ! -f $PROJECTFILE ]; then
    echo "Project File ($PROJECTFILE) not found!"
    exit 1
fi

TARGET=$(fpc -iTP)-$(fpc -iTO)
mkdir -p lib/$TARGET

fpc $PROJECTFILE -o../../public_html/$PROJECTBASE.bin @extra.cfg

echo Done.... $1
