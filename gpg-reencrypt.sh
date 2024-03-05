#!/bin/bash

usage() {
    echo "Usage: gpg-reencrypt.sh [--dry-run] -o old-key-id -n new-key-id [-n another-new-key-id] <file1> [<file2> ...]"
    exit 1
}

old_key_id=""
new_key_ids=()
dry_run=0
files=()

while getopts ":0o:n:" opt; do
  case ${opt} in
    o )
      old_key_id=$OPTARG
      ;;
    n )
      new_key_ids+=("$OPTARG")
      ;;
    0 )
      dry_run=1
      ;;
    \? )
      echo "Invalid option: $OPTARG" 1>&2
      exit 1
      ;;
    : )
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

files=("$@")

if [[ -z "$old_key_id" ]]; then
  echo "Error: -o old-key-id is required" >&2
  exit 1
fi

if [[ ${#new_key_ids[@]} -eq 0 ]]; then
  echo "Error: At least one -n new-key-id is required" >&2
  exit 1
fi

if [[ ${#files[@]} -eq 0 ]]; then
  echo "Error: At least one file is required" >&2
  exit 1
fi

# check if keys and subkeys exist for the old key
oldkey="$(gpg --list-secret-keys --with-colons $old_key_id)"
oldssb="$(echo "$oldkey" | egrep '^ssb' | cut -d: -f5)"
oldsec="$(echo "$oldkey" | egrep '^sec' | cut -d: -f5)"

if [ -z "$oldssb" ] || [ -z "$oldsec" ]; then
	echo "Error: old key not found"
	exit 1
fi

# check that we have at least one key in the new set that we can decrypt with
recipientargs="--recipient $old_key_id"
found_private_key=0
for new_key_id in "${new_key_ids[@]}"; do
    recipientargs="${recipientargs} --recipient $new_key_id"

    newkey="$(gpg --list-secret-keys --with-colons $new_key_id)"
    newssb="$(echo "$newkey" | egrep '^ssb' | cut -d: -f5)"
    newsec="$(echo "$newkey" | egrep '^sec' | cut -d: -f5)"

    if [ -n "$newssb" ] && [ -n "$newsec" ]; then
	found_private_key=1
    fi
done
if [ $found_private_key -eq 0 ]; then
	echo "Error: no private key found for decryption"
	exit 1
fi

for file in "${files[@]}"; do
    if [ ! -f $file ]; then
	echo "File not found: $file"
	continue
    fi
    if file $file | grep -q "encrypted session key" && gpg --pinentry-mode cancel --list-packets $file 2>/dev/null | grep -q $oldssb; then
	echo "Re-encrypting $file"
	if [ $dry_run -eq 1 ]; then
		echo "gpg --batch --yes --output $tmpfile --decrypt $file && gpg --batch --yes ${recipientargs} --encrypt --output $file $tmpfile"
		continue
	fi
	tmpfile=$(mktemp)
	chmod 600 $tmpfile
	gpg --batch --yes --output $tmpfile --decrypt $file && \
	    gpg --batch --yes ${recipientargs} --encrypt --output $file $tmpfile
	rm $tmpfile
	echo
    else
	echo "Skipping $file (not encrypted with $old_key_id)"
    fi
done
