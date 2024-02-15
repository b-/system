#!/usr/bin/env bash
TAIL=("tail" "-f")
rm -f ci.log
screen -d -m -S build -L -Logfile ci.log bash ./build.sh CI_BUILD
"${TAIL[@]}" ci.log
