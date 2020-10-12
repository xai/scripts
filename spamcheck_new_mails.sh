#!/bin/bash

LOGFILE="${HOME}/.spamlog"

#inboxes="$(find ~/.mail -type d -name INBOX)"
inboxes="/home/xai/.mail/wu/olesseni/INBOX"

for inbox in $inboxes; do
	for msg in $(find ${inbox}/new -type f); do
		id="$(egrep -m1 '^Message-ID:' $msg)"
		if [ ! -f $LOGFILE ] || [ "$id" != "" ] && ! grep -q "$id" ~/.spamlog; then
			spamcheck ${msg} >> $LOGFILE
		fi
	done
done
