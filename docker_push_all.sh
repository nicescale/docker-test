#!/bin/bash

set -e

NICEDOCKER_URL=127.0.0.1:5000
PREFIX_DIR=$(dirname `readlink -f $0`)
source $PREFIX_DIR/get_images.sh

for STACK in $STACKLIST; do
  for BRANCH in `get_branch $STACK`; do
    tags=`get_tags $STACK $BRANCH`
    for t in `echo $tags|tr ',' ' '`; do
      docker tag nicescale/$STACK:$t $NICEDOCKER_URL/nicescale/$STACK:$t
      docker push $NICEDOCKER_URL/nicescale/$STACK:$t
    done
  done
done
