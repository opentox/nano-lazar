#!/bin/bash
grep_nano_lazar=`ps aux | grep -v grep | grep nano-lazar-start`
grep_mongo=`ps aux | grep -v grep | grep mongod`
grep_rserve=`ps aux | grep -v grep | grep Rserve`
grep_unicorn=`ps aux | grep -v grep | grep unicorn`

# lazar
if [ ${#grep_lazar} -gt 0 ]
then
  PID=`ps ax | grep -v grep | grep nano-lazar-start | awk '{ print $1 }'`
  for i in "${PID}"
  do
    `kill $i`
  done
else
  echo "nano-lazar is stopped."
fi

# mongod
if [ ${#grep_mongo} -gt 0 ]
then
  PID=`ps ax | grep -v grep | grep mongod | awk '{ print $1 }'`
  for i in "${PID}"
  do 
    `sudo kill $i`
  done
else
  echo "MongoDB is not running."
fi

# rserve
if [ ${#grep_rserve} -gt 0 ]
then
  PID=`ps ax | grep -v grep | grep Rserve | awk '{ print $1 }'`
  for i in "${PID}"
  do 
    `kill $i`
  done
else
  echo "Rserve is not running."
fi

# unicorn
if [ ${#grep_unicorn} -gt 0 ]
then
  PID=`ps ax | grep -v grep | grep unicorn | awk '{ print $1 }'`
  `kill ${PID[0]}`
else
  echo "Unicorn is not running."
fi

exit 0
