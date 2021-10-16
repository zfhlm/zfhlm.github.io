#!/bin/sh
A=`ps -C nginx --no-header |wc -l`
if [ $A -eq 0 ]
then
  /usr/local/nginx/sbin/nginx
  sleep 1
  A2=`ps -C nginx --no-header |wc -l`
  if [ $A2 -eq 0 ]
  then
    systemctl stop keepalived
  fi
fi