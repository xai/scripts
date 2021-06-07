#!/bin/sh
#
# fix-zoom-ics.sh
# Copyright (C) 2021 Olaf Lessenich <xai@linux.com>
#
# Distributed under terms of the MIT license.
#

if grep -q 'BEGIN:VTIMEZONE' $1
then
	>2 echo "VTIMEZONE already present. Quitting."
	return 0
fi

if grep -vq 'METHOD:REQUEST' $1
then
	sed -i '/^BEGIN:VEVENT/i \
METHOD:REQUEST' $1
fi

sed -i '/^BEGIN:VEVENT/i \
BEGIN:VTIMEZONE\
TZID:Europe/Vienna\
X-LIC-LOCATION:Europe/Vienna\
BEGIN:DAYLIGHT\
TZNAME:CEST\
TZOFFSETFROM:+0100\
TZOFFSETTO:+0200\
DTSTART:19810329T020000\
RRULE:FREQ=YEARLY;UNTIL=20370329T010000Z;BYDAY=-1SU;BYMONTH=3\
END:DAYLIGHT\
BEGIN:STANDARD\
TZNAME:CET\
TZOFFSETFROM:+0200\
TZOFFSETTO:+0100\
DTSTART:19961027T030000\
RRULE:FREQ=YEARLY;UNTIL=20361026T010000Z;BYDAY=-1SU;BYMONTH=10\
END:STANDARD\
END:VTIMEZONE' $1
