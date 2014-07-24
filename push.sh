#!/bin/bash

softlist="apache_php haproxy memcached percona-mysql redis tomcat registry-haproxy"
[ -n "$1" ] && softlist=$1
for i in $softlist;do
  docker tag nicescale/$i 127.0.0.1:6090/nicescale/$i
  docker tag nicescale/$i 127.0.0.1:5000/nicescale/$i
  docker push 127.0.0.1:6090/nicescale/$i
done
