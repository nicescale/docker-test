#!/bin/sh

simage=$1
stag=latest
[ -z "$2" ] || stag=$2
tt=`date +%s`
sname=$simage-$tt
sid=$tt

iecho() {
  /bin/echo -e "\n>$*"
}

die() {
  /bin/echo -ne "Error: $simage:$stag:$sid: " 1>&2
  /bin/echo $* 1>&2
  sleep 2
  dockernice stop $sid
  dockernice destroy $sid || echo "Error: failed to service $sid destroy!!" 1>&2
  exit 1
}
error() {
  /bin/echo -ne "Error: $simage:$stag:$sid: " 1>&2
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
      dockernice start $sid 
    else
      [ $es -eq 0 ] || break
      initctl status docker-$sid|grep stop &&
      docker kill $sid
      dockernice stop $sid 
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
dockernice run $simage $stag $sname $sid || die "run failed!!"
waits
dockernice prepare $simage $stag $sname $sid || die "prepare double failed!!"
dockernice create $simage $stag $sname $sid || die "create double failed!!" #|| die "create double failed!!"
sleep 1
waits
iecho exec echo in docker
dockernice exec $sid echo helloworld || die "failed to exec cmd in docker!!"
sleep 3
iecho restart service $sid
dockernice restart $sid || die "failed to restart service!!"
waits
iecho view running dockers and services
dockernice ps 
iecho start docker
docker start $sid || die "failed to start docker!!"
waits
iecho stop docker
docker stop $sid || die "failed to stop docker!!"
iecho kill docker
docker kill $sid || die "failed to kill docker!!"
waits
iecho 'test docker autorestart'
dockernice status $sid || die "failed to watch docker!!"
iecho start docker 
docker start $sid || die "failed to start docker!!"
iecho start docker again
docker start $sid || die "failed to double start docker!!"
waits
iecho reload service
dockernice reload $sid || die "failed to reload service!!"
waits
iecho restart service
dockernice restart $sid || die "failed to restart service!!"
waits
iecho stop service $sid 
dockernice stop $sid || die "failed to stop service!!"
waits 5 stopped
iecho stop service $sid again
dockernice stop $sid || die "failed to double stop service!!"
waits 5 stopped
iecho status service $sid
dockernice status $sid 
es=$?
[ $es -eq 0 ] && die "exit status:$es, service status should return 1!!"
[ $es -eq 2 -o $es -eq 3 ] && die "exit status:$es, service status should return 1!!"

iecho start service $sid
dockernice start $sid || die "failed to start service!!"
iecho start service $sid again
dockernice start $sid || die "failed to double start service!!"
waits
iecho status service $sid
dockernice status $sid || die "exit status:$?, service status should return zero!!"
iecho remove service $sid
dockernice destroy $sid && die "remove running service should failed!!"
iecho remove service $sid again
dockernice stop $sid || die "failed to stop service!!"
docker kill $sid
dockernice destroy $sid || die "failed to remove service!!"

# when exception, then reserve upstart log for troubleshooting
/bin/rm /var/log/upstart/docker-$sid.log
