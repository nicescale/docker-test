#!/bin/bash

gfw=cn
[ -n "$1" ] && gfw=$1

softlist="apache_php haproxy memcached percona-mysql redis tomcat"
[ -n "$2" ] && softlist=$2

dd=`date +%s`
tmpdir=/tmp/docker-$dd
mkdir $tmpdir
for i in $softlist;do
  giturl=https://github.com/nicescale/${i}.git
  git clone $giturl $tmpdir/$i
  cd $tmpdir/$i
  [ $gfw == "cn" ] &&
  sed -i "/apt-get update/i run sed -i 's/archive.ubuntu.com/mirrors.sohu.com/' /etc/apt/sources.list" Dockerfile
  docker build -t nicescale/$i .
done

cd /

rm -fr $tmpdir
