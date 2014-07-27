#!/bin/bash

current_dir=`pwd`
prefix_path=`dirname $0`
stackfile=$current_dir/$prefix_path/stacklist.conf
JENKINS_TPL=$current_dir/$prefix_path/jenkins.tpl

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

need_restart=false
for s in $stacklist; do
  for b in `get_branch $stackfile $s`; do
    echo "> generate jenkins config.xml for $s:$b"
    JOB_DIR=/var/jenkins_home/jobs/docker-$s-$b
    if [ ! -d $JOB_DIR ]; then
      mkdir $JOB_DIR
      chown jenkins:jenkins $JOB_DIR
      sed -n -e "s/{stack}/$s/gp" -e "s/{branch}/$b/gp" $JENKINS_TPL > $JOB_DIR/config.xml
      need_restart=true
    fi
  done
done

$need_restart &&
nicedocker service nicescale_ci restart
