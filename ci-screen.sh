#!/usr/bin/env bash
DATE-TIME() {
	printf %s "${DATE_TIME-$(date -I)-$(date +"%H-%M")}"
}
DATE_TIME="$(DATE-TIME)"
LOGFILE="$(mktemp "--suffix=${DATE_TIME}.log" ci)"
TAIL=("tail" "-f")
rm -f "${LOGFILE}"
git pull --rebase | tee -a "${LOGFILE}"
screen -d -m -S build -L -Logfile "${LOGFILE}" bash ./build.sh CI_BUILD
# screen returns before the logfile is actually created, so test for race condition
until [[ -f ${LOGFILE} ]]; do
	sleep 0.1s
done
"${TAIL[@]}" "${LOGFILE}"
