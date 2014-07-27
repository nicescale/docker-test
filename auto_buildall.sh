#!/bin/bash

current_dir=`pwd`
prefix_path=`dirname $0`
stackfile=$current_dir/$prefix_path/stacklist.conf

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

stacklist=`ini_section $stackfile`
ini_parse $stackfile

mkdir /tmp/XX
cd /tmp/XX

for s in $stacklist; do
  echo "> stack $s"
  mkdir $s
  for b in `get_branch $stackfile $s`; do
    echo "  > cloning $s:$b"
    tags=`get_tags $s $b`
    first_tag=`echo $tags|cut -f1 -d','`
    rest_tags=`echo $tags|cut -f2- -d','`

    cd $s
    git clone --branch $b https://github.com/nicescale/$s.git $b
    docker build -t nicescale/$s:$first_tag .
    for t in `echo $rest_tags|tr ',' ' '`; do
      docker tag nicescale/$s:$first_tag nicescale/$b:$t
    done
    cd ..
  done
done
