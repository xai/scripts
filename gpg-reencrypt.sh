#!/bin/bash

# Usage: gpg-reencrypt.sh <old-pub-key> <new-pub-key> <file1> [<file2> ...]

usage() {
    echo "Usage: gpg-reencrypt.sh [--dry-run] old-ssb old- <file1> [<file2> ...]"
    exit 1
}

# -n is an alias for --dry-run
if [ "$1" = "--dry-run" ] || [ "$1" = "-n" ]; then
	DRY_RUN=1
	shift
fi

if [ $# -lt 3 ]; then
    usage
fi

OLD_KEY_ID=$1
NEW_KEY_ID=$2
shift 2

# check if keys and subkeys exist
OLDKEY="$(gpg --list-secret-keys --with-colons $OLD_KEY_ID)"
OLDSSB="$(echo "$OLDKEY" | egrep '^ssb' | cut -d: -f5)"
OLDSEC="$(echo "$OLDKEY" | egrep '^sec' | cut -d: -f5)"

# echo "OLDSEC: $OLDSEC"
# echo "OLDSSB: $OLDSSB"

if [ -z "$OLDSSB" ] || [ -z "$OLDSEC" ]; then
	echo "Error: old key not found"
	exit 1
fi

NEWKEY="$(gpg --list-secret-keys --with-colons $NEW_KEY_ID)"
NEWSSB="$(echo "$NEWKEY" | egrep '^ssb' | cut -d: -f5)"
NEWSEC="$(echo "$NEWKEY" | egrep '^sec' | cut -d: -f5)"

# echo "NEWSEC: $NEWSEC"
# echo "NEWSSB: $NEWSSB"

if [ -z "$NEWSSB" ] || [ -z "$NEWSEC" ]; then
	echo "Error: new key not found"
	exit 1
fi

for file in "$@"; do
    if [ ! -f $file ]; then
	echo "File not found: $file"
	continue
    fi
    if file $file | grep -q "encrypted session key" && gpg --pinentry-mode cancel --list-packets $file 2>/dev/null | grep -q $OLDSSB; then
	echo "Re-encrypting $file"
	if [ -n "$DRY_RUN" ]; then
		continue
	fi
	tmpfile=$(mktemp)
	chmod 600 $tmpfile
	gpg --batch --yes --output $tmpfile --decrypt $file && \
	    gpg --batch --yes --recipient $NEW_KEY_ID --recipient $OLD_KEY_ID --encrypt --output $file $tmpfile
	rm $tmpfile
	echo
    else
	echo "Skipping $file (not encrypted with $OLD_KEY_ID)"
    fi
done
