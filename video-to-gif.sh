#!/bin/sh

set -e

usage () {
	echo "Usage: $0 <input file> <output file>"
}

if [ ! -f "$1" ] || [ -z "$2" ]; then usage; exit 1; fi

infile=$1
outfile=$2

if [ -f "$outfile" ]; then
	>&2 echo "Error: Output file does already exist: $outfile"
	exit 2
fi

ffmpeg -y -i "$infile" -filter_complex "fps=10,split[v1][v2]; [v1]palettegen=stats_mode=full [palette]; [v2][palette]paletteuse=dither=sierra2_4a" -vsync 0 "$outfile"

