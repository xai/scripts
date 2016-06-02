#!/bin/bash
#
# Setup as a cronjob: wasserpegel.sh <mail adresses>

# This should give us enough time; shit hits the fan at around 900 (source: 2013).
THRESHOLD1=600
THRESHOLD2=700
THRESHOLD3=800

line=$(wget -O - 'http://www.hnd.bayern.de/pegel/donau_bis_passau/passau-18009000' 2>/dev/null | grep -a 'Letzter Messwert vom' | sed -e 's/.*<b>\(.*\)<\/b>.*<b>\(.*\)<\/b>.*/\1 \2/')

if [ -z $1 ]; then
	# just print current status
	echo $line
	exit 0
fi

level=$(echo $line | awk '{ print $3 }')
MSG=""

if (( "$level" >= $THRESHOLD3 )); then
	MSG="You are in serious trouble really soon! Hurry!"
elif (( "$level" >= $THRESHOLD2 )); then
	MSG="Get yourself ready to evacuate our servers!"
elif (( "$level" >= $THRESHOLD1 )); then
	MSG="Tide is quite high, let's hope for the best!"
fi

if [ ! -z "$MSG" ]; then
	echo -e "${MSG}\n\nWater line Inn:\n$line" | mail -s "[high tide auto-warning] Inn hits $THRESHOLD cm." $@
fi

