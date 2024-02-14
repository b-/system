#!/usr/bin/env bash
screen -d -m -S build -L -Logfile ci.log bash -x ./build.sh CI
