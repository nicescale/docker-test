#!/bin/sh

servicetype=$1
servicevsn=latest
[ -z "$2" ] || servicevsn=$2
tt=`date +%s`
sname=$servicetype-$tt
sid=$tt

iecho() {
  /bin/echo -e "\n>$*"
}

die() {
  /bin/echo -ne "Error: $servicetype:$servicevsn: " 1>&2
  /bin/echo $* 1>&2
  sleep 4
  dockernice service $sid stop
  dockernice service $sid destroy || echo "Error: failed to service $sid destroy!!" 1>&2
  exit 1
}
error() {
  /bin/echo -ne "Error: $servicetype:$servicevsn: " 1>&2
  /bin/echo $* 1>&2
  exit 1
}

iecho lauching docker
dockernice run $servicetype $servicevsn $sname $sid || die "run error!!"
sleep 2
dockernice prepare $servicetype $servicevsn $sname $sid || die "prepare double failed!!"
sleep 2
dockernice create $servicetype $servicevsn $sname $sid || error "create double failed!!" #|| die "create double failed!!"
sleep 2
iecho exec echo in docker
dockernice exec $sid echo helloworld || die "failed to exec cmd in docker!!"
iecho restart service $sid
dockernice service $sid restart || die "failed to restart service!!"
sleep 2
iecho view running dockers and services
dockernice ps 
iecho start docker
dockernice start $sid || die "failed to start docker!!"
sleep 2
iecho stop docker
dockernice stop $sid || die "failed to stop docker!!"
iecho kill docker
dockernice kill $sid || die "failed to kill docker!!"
sleep 1
iecho 'test docker autorestart'
dockernice service $sid status || die "failed to watch docker!!"
iecho start docker 
dockernice start $sid || die "failed to start docker!!"
sleep 1
iecho start docker again
dockernice start $sid || die "failed to double start docker!!"
sleep 2
iecho reload service
dockernice service $sid reload || die "failed to reload service!!"
sleep 2
iecho restart service
dockernice service $sid restart || die "failed to restart service!!"
sleep 2
iecho stop service $sid 
dockernice service $sid stop || die "failed to stop service!!"
iecho stop service $sid again
sleep 1
dockernice service $sid stop || die "failed to double stop service!!"
iecho status service $sid
sleep 1
dockernice service $sid status && die "service status should return nonzero!!"
iecho start service $sid
dockernice service $sid start || die "failed to start service!!"
iecho start service $sid again
dockernice service $sid start || die "failed to double start service!!"
sleep 1
iecho status service $sid
dockernice service $sid status || die "service status should return zero!!"
iecho remove service $sid
dockernice service $sid destroy && die "remove running service should failed!!"
iecho remove service $sid again
dockernice service $sid stop || die "failed to stop service!!"
dockernice kill $sid
dockernice service $sid destroy || die "failed to remove service!!"
