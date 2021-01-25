#!/bin/bash

LOCKFILE="${HOME}/.spam.lock"
LOGFILE="${HOME}/.spamlog"

lockfile -r 0 ${LOCKFILE} || exit 0

#inboxes="$(find ~/.mail -type d -name INBOX)"
inboxes="/home/xai/.mail/wu/olesseni/INBOX"

for inbox in $inboxes; do
	for msg in $(find ${inbox}/new -type f); do
		id="$(egrep -m1 '^Message-ID:' $msg | sha1sum | cut -d' ' -f1)"
		if [ ! -f $LOGFILE ] || [ "$id" != "" ] && ! grep -q "$id" ~/.spamlog; then
			spamcheck ${msg} >> $LOGFILE
		fi
	done
done

rm -f ${LOCKFILE}
