#!/bin/bash
#
# watch-inbox.sh
# Copyright (C) 2020 Olaf Lessenich <xai@linux.com>
#
# Distributed under terms of the MIT license.
#

set -eu

inotifywait -m -q --format '%w%f' -e create -e moved_to $HOME/.mail/{wu,fim}/*/INBOX/new | while read FILE
do
	sender=$(grep -m 1 "^From: " "$FILE" | sed 's/^From: //')
	date=$(grep -m 1 "^Date: " "$FILE" | sed 's/^Date: //')
	subject=$(grep -m 1 "^Subject: " "$FILE" | sed 's/^Subject: //' | decode_mime.pl)

	today=$(date +%Y-%m-%d)
	mailday=$(date -d "$date" +%Y-%m-%d)

	if [ "$mailday" == "$today" ]; then
		date=$(date -d "$date" +%H:%M)
	else
		date=$(date -d "$date" "+%d. %b %H:%M")
	fi

	echo -e "${date}\t${sender}\t${subject}"

	notify-send -t 10000 "New mail from ${sender}" "$date\n$subject" --icon=mail-unread
done
