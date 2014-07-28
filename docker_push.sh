#!/bin/bash

STACK=$1
BRANCH=$2
PREFIX_DIR=$(dirname `readlink -f $0`)
. $PREFIX_DIR/get_images.sh

tags=`get_tags $STACK $BRANCH`
for t in `echo $tags|tr ',' ' '`; do
  docker tag nicescale/$STACK:$t 127.0.0.1:5000/nicescale/$STACK:$t
  docker push 127.0.0.1:5000/nicescale/$STACK:$t
done
