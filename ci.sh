#!/bin/bash

prefix_path=`dirname $0`

DAY=`date +%m%d%H`
LOG_DIR=/var/log/ci-log/$DAY
mkdir -p $LOG_DIR
$prefix_path/nicedocker_update.sh > $LOG_DIR/nicedocker_update.log 2>$LOG_DIR/nicedocker_update.log.err
$prefix_path/rebuild_all.sh > $LOG_DIR/rebuild_all.log 2>$LOG_DIR/rebuild_all.log.err
$prefix_path/test_all.sh > $LOG_DIR/test_all.log 2>$LOG_DIR/test_all.log.err

ERR=`cat $LOG_DIR/test_all.log.err | grep '!!'`
[ -n "$ERR" ] && echo "$ERR" | mail -s "nicedocker ci test result" hanwoody@gmail.com

