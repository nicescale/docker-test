#!/bin/bash

PREFIX_DIR=$(dirname `readlink -f $0`)
. $PREFIX_DIR/get_images.sh
JENKINS_TPL=$PREFIX_DIR/jenkins.tpl

JENKINS_CLI=$JENKINS_HOME/war/WEB-INF/jenkins-cli.jar

need_restart=false
for s in $STACKLIST; do
  for b in `get_branch $s`; do
    echo "> generate jenkins config.xml for $s:$b"
    JOB_DIR=/var/jenkins_home/jobs/docker-$s-$b
    if [ ! -d $JOB_DIR ]; then
      mkdir $JOB_DIR
      sed -n -e "s/{stack}/$s/gp" -e "s/{branch}/$b/gp" $JENKINS_TPL > $JOB_DIR/config.xml
      need_restart=true
    fi
  done
done

$need_restart &&
java -jar $JENKINS_CLI restart
