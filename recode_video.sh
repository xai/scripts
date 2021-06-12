#!/usr/bin/bash
#
# recode_video.sh
# Copyright (C) 2021 Olaf Lessenich <xai@linux.com>
#
# Distributed under terms of the MIT license.
#

set -eu

usage() {
	echo "Usage: $0 inputfile"
}

if [ $# -lt 1 ]
then
	usage
	exit 1
fi

THRESHOLD_BR="2300" # kb/s
FFMPEG_ARGS="-c:a copy -c:v h264_nvenc -preset slow"
TYPE="hw"
ext=""

# use software encoding for smaller files
SOFT=0
ONLYSMALL=0
THRESHOLD_SOFT="80" # MB

if [ "$1" == "-s" ]
then
	SOFT=1
	shift
fi

if [ "$1" == "-o" ]
then
	ONLYSMALL=1
	shift
fi

if [ "$1" == "-mp4" ]
then
	ext="mp4"
	shift
fi

if [ ! -f "$1" ]
then
	usage
	exit 2
fi

bitrate="$(ffmpeg -i "${1}" 2>&1 | sed -n -e 's/^.*bitrate: //p')"
filesize_mb=$(du -m "${1}" | cut -f1)
kbps="$(echo "${bitrate}" | cut -d' ' -f1 | egrep -o '^[0-9]+$')"

if [ "${SOFT}" == "1" ] && [ "${filesize_mb}" -lt "${THRESHOLD_SOFT}" ]
then
	THRESHOLD_BR="2100" # kb/s
	FFMPEG_ARGS="-c:a copy -c:v libx265 -preset slow -x265-params log-level=warning"
	TYPE="sw"	
elif [ "${ONLYSMALL}" == "1" ]
then
	exit 0
fi

if [ "${kbps}" -gt "${THRESHOLD_BR}" ]
then
	echo
	echo "Input File: '${1}'"
	echo "Input Bitrate: ${bitrate}"
	echo "Input Filesize: ${filesize_mb} M"
	input_ext="$(basename "${1}" | rev | cut -d'.' -f1 | rev)"

	if [ -z "${ext}" ]
	then
		ext="${input_ext}"
		target="${1}"
	else
		FFMPEG_ARGS="$(echo "${FFMPEG_ARGS}" | sed 's/-c:a copy/-c:a aac/')"
		target="$(echo "${1}" | sed "s/\.${input_ext}$/\.${ext}/")"
	fi

	tmpfile=$(mktemp --suffix=".${ext}")

	echo "Recoding '${1}' ... (${TYPE}, ${ext}, ${FFMPEG_ARGS})"
	ffmpeg -y -loglevel warning -i "${1}" ${FFMPEG_ARGS} "${tmpfile}"
	
	recoded_bitrate="$(ffmpeg -i "${tmpfile}" 2>&1 | sed -n -e 's/^.*bitrate: //p')"
	recoded_mb=$(du -m "${tmpfile}" | cut -f1)
	if [ "${recoded_mb}" -lt "${filesize_mb}" ]
	then
		echo "Output Bitrate: ${recoded_bitrate}"
		echo "Output Filesize: ${recoded_mb} M"
		echo "Gain: $(echo "100-100*${recoded_mb}/${filesize_mb}" | bc) %"
		cp "${tmpfile}" "${target}"
		if [ "${1}" != "${target}" ]
		then
			rm "${1}"
		fi
	else
		echo "Recoded file is larger (${recoded_mb} M), do nothing"
	fi

	rm "${tmpfile}"
fi

