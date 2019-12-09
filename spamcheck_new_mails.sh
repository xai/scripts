#!/bin/bash

LOGFILE="${HOME}/.spamlog"

for inbox in $(find ~/.mail -type d -name INBOX); do
	for msg in $(find ${inbox}/new -type f); do
		id="$(egrep -m1 '^Message-ID:' $msg)"
		if [ ! -f $LOGFILE ] || [ "$id" != "" ] && ! grep -q "$id" ~/.spamlog; then
			spamcheck ${msg} >> $LOGFILE
		fi
	done
done
