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
  /bin/echo -ne "Error: $servicetype:$servicevsn:$sid: " 1>&2
  /bin/echo $* 1>&2
  sleep 2
  dockernice service $sid stop
  dockernice service $sid destroy || echo "Error: failed to service $sid destroy!!" 1>&2
  exit 1
}
error() {
  /bin/echo -ne "Error: $servicetype:$servicevsn:$sid: " 1>&2
  /bin/echo $* 1>&2
  exit 1
}
waits() {
  sec=$1
  status=$2
  [ -z "$sec" ] && sec=5
  [ -z "$status" ] && status=running

  count=0
  while [ $count -lt $sec ]; do
    docker top $sid > /dev/null 2>&1
    es=$?
    if [ "$status" = "running" ]; then
      [ $es -eq 0 ] && break
    else
      [ $es -eq 0 ] || break
    fi
    count=$(( count+1 ))
    sleep 1
  done
  [ $count -eq $sec ] &&
  echo "not ensure $status for $sid." &&
  return 1

  return 0
}


iecho lauching docker
dockernice run $servicetype $servicevsn $sname $sid || die "run failed!!"
waits
dockernice prepare $servicetype $servicevsn $sname $sid || die "prepare double failed!!"
dockernice create $servicetype $servicevsn $sname $sid || die "create double failed!!" #|| die "create double failed!!"
sleep 1
waits
iecho exec echo in docker
dockernice exec $sid echo helloworld || die "failed to exec cmd in docker!!"
iecho restart service $sid
dockernice service $sid restart || die "failed to restart service!!"
waits
iecho view running dockers and services
dockernice ps 
iecho start docker
dockernice start $sid || die "failed to start docker!!"
waits
iecho stop docker
dockernice stop $sid || die "failed to stop docker!!"
iecho kill docker
dockernice kill $sid || die "failed to kill docker!!"
waits
iecho 'test docker autorestart'
dockernice service $sid status || die "failed to watch docker!!"
iecho start docker 
dockernice start $sid || die "failed to start docker!!"
iecho start docker again
dockernice start $sid || die "failed to double start docker!!"
waits
iecho reload service
dockernice service $sid reload || die "failed to reload service!!"
waits
iecho restart service
dockernice service $sid restart || die "failed to restart service!!"
waits
iecho stop service $sid 
dockernice service $sid stop || die "failed to stop service!!"
waits 5 stopped
iecho stop service $sid again
dockernice service $sid stop || die "failed to double stop service!!"
waits 5 stopped
iecho status service $sid
dockernice service $sid status && die "service status should return nonzero!!"
iecho start service $sid
dockernice service $sid start || die "failed to start service!!"
iecho start service $sid again
dockernice service $sid start || die "failed to double start service!!"
waits
iecho status service $sid
dockernice service $sid status || die "service status should return zero!!"
iecho remove service $sid
dockernice service $sid destroy && die "remove running service should failed!!"
iecho remove service $sid again
dockernice service $sid stop || die "failed to stop service!!"
dockernice kill $sid
dockernice service $sid destroy || die "failed to remove service!!"
