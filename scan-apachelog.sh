#!/bin/bash
#
# The MIT License (MIT)
# 
# Copyright (c) 2012 Olaf Lessenich
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

mail_output=false

exclude="(bot|132\.231\.|MnoGoSearch|Baiduspider|BingPreview|ExB Language Crawler|hostgator.com|SemrushBotG${custom_exclude})"

while getopts ":m" opt; do
	case $opt in
		m)
			mail_output=true
			;;
	esac
done
shift $((OPTIND-1))

if [ ! -z $1 ]; then
	LOGFILE=$1
fi

[ ! -f $LOGFILE ] && echo "File not found: $LOGFILE" && exit 1

for file in "${files[@]}"; do

	OUT=$(mktemp --suffix=.txt)
	TMPOUT=$(mktemp --suffix=.txt)

	echo "Logfile: $LOGFILE" > $OUT
	echo "Filter: \"$file\"" >> $OUT
	echo >> $OUT

	echo '----------------------------------------------------------------------' >> $OUT
	grep -h ${file} $LOGFILE | grep -Pv "${exclude}" | \
		while  read i; do
			echo "$i" >> $TMPOUT
		done

		cat $TMPOUT >> $OUT
		echo >> $OUT
		echo '----------------------------------------------------------------------' >> $OUT

		for ip in $(awk '{ print $1 }' < $TMPOUT | sort | uniq); do
			echo >> $OUT
			echo "information about $ip:" >> $OUT
			host $ip >> $OUT
			geoiplookup $ip >> $OUT
		done
		echo >> $OUT

		# remove non-ascii characters
		perl -i -pe 's/[^[:ascii:]]//g' $OUT

		if [ -s $TMPOUT ]; then
			if $mail_output; then
				cat $OUT| mail -s "rone: apache log - ${file}" ${mail_address}
			else
				cat $OUT
			fi
		fi

		[ -f $OUT ] && rm $OUT
		[ -f $TMPOUT ] && rm $TMPOUT
	done

