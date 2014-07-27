#!/bin/bash

PREFIX_DIR=$(dirname `readlink -f $0`)
stackfile=$PREFIX_DIR/stacklist.conf

STACK=$1
BRANCH=$2

ini_section() {
  INI_FILE=$1
  sed -e 's/[[:space:]]*\=[[:space:]]*/=/g' \
    -e 's/;.*$//' \
    -e 's/[[:space:]]*$//' \
    -e 's/^[[:space:]]*//' \
    -e "s/^\(.*\)=\([^\"']*\)$/\1=\"\2\"/" \
   < $INI_FILE \
   | sed -n -e "s/^\[\(.*\)\]/\1/p"
}

ini_parse() {
  INI_FILE=$1
  for s in `ini_section $INI_FILE`; do
   ss=`echo $s|tr '.' '_' | tr '-' '_'`
   for b in `get_branch $INI_FILE $s`; do
    bb=`echo $b|tr '.' '_' | tr '-' '_'`
    eval `sed -e 's/[[:space:]]*\=[[:space:]]*/=/g' \
      -e 's/;.*$//' \
      -e 's/[[:space:]]*$//' \
      -e 's/^[[:space:]]*//' \
      -e "s/^\(.*\)=\([^\"']*\)$/\1=\2/" \
    < $INI_FILE \
    | sed -n -e "/^\[$s\]/,/^\s*\[/{/^[^;].*\=.*/p;}" \
    | grep $b \
    | sed -n -e "s/^.*\=\(.*\)/${ss}_${bb}\=\1/p"`
   done
  done
}

get_branch() {
  INI_FILE=$1
  stack=$2
  sed -e 's/[[:space:]]*\=[[:space:]]*/=/g' \
    -e 's/;.*$//' \
    -e 's/[[:space:]]*$//' \
    -e 's/^[[:space:]]*//' \
    -e "s/^\(.*\)=\([^\"']*\)$/\1=\"\2\"/" \
   < $INI_FILE \
   | sed -n -e "/^\[$stack\]/,/^\s*\[/{/^[^;].*\=.*/p;}" \
   | sed -n -e "s/^\(.*\)\=.*/\1/p " 
}

get_tags() {
  stack=$1
  branch=$2
  vars=`echo '$'${stack}_$branch|tr '-' '_'|tr '.' '_'`
  eval "avar=$vars"
  echo $avar
}

ini_parse $stackfile

tags=`get_tags $STACK $BRANCH`
for t in `echo $tags|tr ',' ' '`; do
  docker tag nicescale/$STACK:$t 127.0.0.1:5000/nicescale/$STACK:$t
  docker push 127.0.0.1:5000/nicescale/$STACK:$t
done
