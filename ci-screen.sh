#!/usr/bin/env bash
TAIL=(
    "less"
    "+F"
    )
rm -f ci.log
screen -d -m -S build -L -Logfile ci.log bash -x ./build.sh CI-BUILD
"${TAIL[@]}" ci.log
