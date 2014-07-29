#!/bin/bash

set -e

NICEDOCKER_URL=repo.nicedocker.com:5000
PREFIX_DIR=$(dirname `readlink -f $0`)
source $PREFIX_DIR/get_images.sh

for STACK in $STACKLIST; do
  for BRANCH in `get_branch $STACK`; do
    tags=`get_tags $STACK $BRANCH`
    for t in `echo $tags|tr ',' ' '`; do
      docker pull $NICEDOCKER_URL/nicescale/$STACK:$t
      docker tag $NICEDOCKER_URL/nicescale/$STACK:$t nicescale/$STACK:$t
    done
  done
done
