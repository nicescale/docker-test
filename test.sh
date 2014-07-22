#!/bin/bash

prefix_path=`dirname $0`
for i in apache_php haproxy memcached percona-mysql redis tomcat;do
  echo testing image $i:latest
  echo ------------------------------------------------
  $prefix_path/test_image.sh $i latest
  echo
done

