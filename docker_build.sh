#!/bin/bash

STACK=$1
BRANCH=$2

PREFIX_DIR=$(dirname `readlink -f $0`)
. $PREFIX_DIR/get_images.sh


tags=`get_tags $STACK $BRANCH`
first_tag=`echo $tags|cut -f1 -d','`
rest_tags=`echo $tags|cut -f2- -d','`

docker build -t nicescale/$STACK:$first_tag .
for t in `echo $rest_tags|tr ',' ' '`; do
  docker tag nicescale/$STACK:$first_tag nicescale/$STACK:$t
done
