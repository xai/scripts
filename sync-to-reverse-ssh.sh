#!/usr/bin/env bash

set -eu

if [ -z "$2" ]
then
	echo "Usage: $0 sourcefs targetfs"
	exit 1
fi

sourcefs="$1"
targetfs="$2"

SSH="ssh -p 2222 root@127.0.0.1"
snaptype="(monthly|weekly)"

current=$(zfs list -H -o name -t snapshot -r $sourcefs | grep "${sourcefs}@" | egrep "$snaptype" | tail -n1)
zfs list -H -o name -t snapshot -r $sourcefs | grep "${sourcefs}@" > local.snaps
$SSH "zfs list -H -o name -t snapshot $targetfs | sed s_${targetfs}_${sourcefs}_" > remote.snaps

lastcommon=$(comm -12 local.snaps remote.snaps | tail -n1)
echo "current: $current"
echo "lastcommon: $lastcommon"

if [ "$lastcommon" == "" ]
then
	echo 'No common snapshot found.'
	exit 1
else
	echo "Last common $snaptype snapshot: $lastcommon"
fi

if [ "$current" == "" ]
then
	echo 'No current $snaptype snapshot found.'
else
	echo "Last current $snaptype snapshot: $current"
	if [ "$current" == "$lastcommon" ]
	then
		echo "Last current $snaptype snapshot already synced."
	else
		echo
		echo "zfs send -RI $lastcommon $current | bzip2 -c | $SSH \"bzcat | zfs recv -Fu ${targetfs}\""
		read -p "Are you sure? " -r

		echo
		if [[ $REPLY =~ ^[Yy]$ ]]
		then
			zfs send -RI $lastcommon $current | bzip2 -c | $SSH "bzcat | zfs recv -Fu ${targetfs}"
		else
			echo "Aborted by user."
		fi
	fi
fi
