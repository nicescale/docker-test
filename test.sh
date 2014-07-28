#!/bin/bash

PREFIX_DIR=$(dirname `readlink -f $0`)
. $PREFIX_DIR/get_images.sh

for s in $STACKLIST; do
  for b in `get_branch $s`; do
    echo $s:$b
    tags=`get_tags $s $b`
    for t in `echo $tags|tr ',' ' '`; do
      [ "$t" = "latest" ] && continue
      $PREFIX_DIR/test_image.sh nicescale/$s $t
    done
  done
done

