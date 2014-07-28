#!/bin/bash

STACK=$1
BRANCH=$2
NICEDOCKER_URL=
PREFIX_DIR=$(dirname `readlink -f $0`)
. $PREFIX_DIR/get_images.sh

tags=`get_tags $STACK $BRANCH`
for t in `echo $tags|tr ',' ' '`; do
  docker pull $NICEDOCKER_URL/nicescale/$STACK:$t
  docker tag $NICEDOCKER_URL/nicescale/$STACK:$t nicescale/$STACK:$t
done
