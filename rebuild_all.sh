#!/bin/bash

begin_time=`date +%s`
softlist="apache_php haproxy memcached percona-mysql redis tomcat"

echo "building new images ..."
/root/cron/build.sh

build_time=`date +%s`
dif=$(( build_time - begin_time ))
echo "building spend $dif seconds"

echo "stop docker registry and start a new..."
docker stop nsregistry-ci
docker rm nsregistry-ci
sleep 2
docker run -d --name nsregistry-ci -p 6090:5000 -p 8088:8088 nicescale/registry-haproxy
sleep 5

echo "remove container ..."
docker ps --all|grep -v Up|grep -v nsregistry|grep -v CONTAINER|grep -v nicerepo|awk '{print $1}'|xargs docker rm

echo "push images to new nsregistry-ci ..."
/root/cron/push.sh 
docker tag centos:6.4 127.0.0.1:6090/centos:6.4
docker tag centos 127.0.0.1:6090/centos
docker push 127.0.0.1:6090/centos
docker tag ubuntu:14.04 127.0.0.1:6090/ubuntu:14.04
docker tag ubuntu 127.0.0.1:6090/ubuntu
docker push 127.0.0.1:6090/ubuntu

echo "remove outdated images..."
docker images|grep -v 0e2bc3bf59d3|grep none|awk '{print $3}'|xargs docker rmi

push_time=`date +%s`
dif=$(( push_time - build_time ))

echo "pushing spend $dif seconds"
