#!/bin/bash
#
# get-latest-common-snap.sh
# Copyright (C) 2021 Olaf Lessenich <xai@linux.com>
#
# Distributed under terms of the MIT license.
#

set -eu

srcsnaps="$(zfs list -t snapshot -o name -H $1 | sed 's_.\+@_@_')"
targetsnaps="$(zfs list -t snapshot -o name -H $2 | sed 's_.\+@_@_')"
common="$(grep -Fxf <(echo "$srcsnaps") <(echo "$targetsnaps") | tail -n1)"
srclatest="$(echo "$srcsnaps" | tail -n1)"
targetlatest="$(echo "$targetsnaps" | tail -n1)"

echo "${1}${srclatest}"
echo "${2}${targetlatest}"
echo "Common: "$common""

echo "zfs send -RI ${1}${common} ${1}${srclatest} | zfs recv -u ${2}"
