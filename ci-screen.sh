#!/usr/bin/env bash
rm -f ci.log
screen -d -m -S build -L -Logfile ci.log bash -x ./build.sh CI
tail -f ci.log
