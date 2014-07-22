#!/bin/bash

for i in apache_php haproxy memcached percona-mysql redis tomcat;do
  echo testing image $i:latest
  echo ------------------------------------------------
  /root/cron/test_image.sh $i latest
  echo
done

