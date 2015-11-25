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


result="$(grep -Pv '(File does not exist:|Permission denied:|Directory index forbidden)' $LOGFILE)"
if [ ! -z "${result}" ]; then
	OUT=$(mktemp)

	echo "Logfile: $LOGFILE" > $OUT
	echo >> $OUT

	echo '----------------------------------------------------------------------' >> $OUT
	printf "%s" "$result" >> $OUT
	echo >> $OUT
	echo '----------------------------------------------------------------------' >> $OUT

	echo >> $OUT

	if $mail_output; then
		cat $OUT | mail -s "rone: apache log - errors" lessenic@fim.uni-passau.de
	else
		cat $OUT
	fi

	[ -f $OUT ] && rm $OUT
fi


