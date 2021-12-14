#!/bin/bash
alertgo_status=`lsof -i:8088`
if [ "$?" = 0 ]
then
  echo "alertgo_status 0"
else
  echo "alertgo_status 1"
  nohup /work/alertgo/alertGoV6 > /work/alertgo/alertGoV6.log 2>&1 &
fi
