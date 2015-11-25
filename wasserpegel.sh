#!/bin/bash
#
# Setup as a cronjob: wasserpegel.sh <mail adresses>

# This should give us enough time; shit hits the fan at around 900 (source: 2013).
THRESHOLD=700

line=$(wget -O - 'http://www.hnd.bayern.de/pegel/wasserstand/pegel_wasserstand.php?pgnr=18009000&standalone=1' 2>/dev/null | grep 'Letzter Messwert vom' | sed -e 's/.*<b>\(.*\)<\/b>.*<b>\(.*\)<\/b>.*/\1 \2/')
if [ -z $1 ]; then
	echo $line
	exit 0
fi
MSG="$(echo $line | awk '{if($3>='$THRESHOLD') { print $0 }}')"
if [ ! -z "$MSG" ]; then
	echo -e "Water line Inn:\n$MSG\n\nGet yourself ready to evacuate our servers!" | mail -s "[high tide auto-warning] Inn hits $THRESHOLD cm." $@
fi

