#!/bin/bash

set -e

PREFIX_DIR=$(dirname `readlink -f $0`)
. $PREFIX_DIR/get_images.sh

STACK=$1
BRANCH=$2

tags=`get_tags $STACK $BRANCH`

for i in {1..100}; do
 for t in `echo $tags|tr ',' ' '`; do
  [ "$t" = "latest" ] && continue
  $PREFIX_DIR/test_image.sh nicescale/$s $t
 done
done
