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
iecho remove service $sid 
dockernice service $sid stop || die "failed to stop service!!"
dockernice kill $sid
dockernice service $sid destroy || die "failed to remove service!!"
