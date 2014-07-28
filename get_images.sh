#!/bin/bash

PREFIX_DIR=$(dirname `readlink -f $0`)
stackfile=$PREFIX_DIR/stacklist.conf

ini_section() {
  INI_FILE=$stackfile
  sed -e 's/[[:space:]]*\=[[:space:]]*/=/g' \
    -e 's/;.*$//' \
    -e 's/[[:space:]]*$//' \
    -e 's/^[[:space:]]*//' \
    -e "s/^\(.*\)=\([^\"']*\)$/\1=\"\2\"/" \
   < $INI_FILE \
   | sed -n -e "s/^\[\(.*\)\]/\1/p"
}

ini_parse() {
  INI_FILE=$stackfile
  for s in `ini_section`; do
   ss=`echo $s|tr '.' '_' | tr '-' '_'`
   for b in `get_branch $s`; do
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

# args: stackname
get_branch() {
  INI_FILE=$stackfile
  stack=$1
  sed -e 's/[[:space:]]*\=[[:space:]]*/=/g' \
    -e 's/;.*$//' \
    -e 's/[[:space:]]*$//' \
    -e 's/^[[:space:]]*//' \
    -e "s/^\(.*\)=\([^\"']*\)$/\1=\"\2\"/" \
   < $INI_FILE \
   | sed -n -e "/^\[$stack\]/,/^\s*\[/{/^[^;].*\=.*/p;}" \
   | sed -n -e "s/^\(.*\)\=.*/\1/p " 
}

# args: stack, branch
get_tags() {
  stack=$1
  branch=$2
  vars=`echo '$'${stack}_$branch|tr '-' '_'|tr '.' '_'`
  eval "avar=$vars"
  echo $avar
}

STACKLIST=`ini_section`
ini_parse

