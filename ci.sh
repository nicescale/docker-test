#!/bin/bash

cd /root/cron

DAY=`date +%m%d%H`
LOG_DIR=/var/log/ci-log/$DAY
mkdir -p $LOG_DIR
/root/cron/nicedocker_update.sh > $LOG_DIR/nicedocker_update.log 2>$LOG_DIR/nicedocker_update.log.err
/root/cron/rebuild_all.sh > $LOG_DIR/rebuild_all.log 2>$LOG_DIR/rebuild_all.log.err
/root/cron/test_all.sh > $LOG_DIR/test_all.log 2>$LOG_DIR/test_all.log.err

ERR=`cat $LOG_DIR/test_all.log.err | grep '!!'`
[ -n "$ERR" ] && echo "$ERR" | mail -s "nicedocker ci test result" hanwoody@gmail.com

