#!/bin/bash

# usage ./days-since.sh [-q] [days|weeks|months|years] YYYY-MM-DD [HH:MM]
usage() {
  echo "Usage: $0 [-q] [days|weeks|months|years] YYYY-MM-DD [HH:MM]"
  exit 1
}

quiet=0

# Check if the first argument is -q
if [ "$1" == "-q" ]; then
  quiet=1
  shift
fi

# unit is the first argument or years
unit=${1:-years}
date=${2:-2024-11-30}
time=${3:-05:17}

date="$date $time"

old=$(date -d "$date" '+%s')
now=$(date +%s)
diff=$((now - old))

case $unit in
  days)
    result="$((diff / 86400)) days"
    ;;
  weeks)
    weeks=$((diff / 604800))
    days=$(((diff % 604800) / 86400))
    result="$weeks weeks and $days days"
    ;;
  months)
    months=$((diff / 2629743))  # Approximate month length in seconds
    days=$(((diff % 2629743) / 86400))
    result="$months months and $days days"
    ;;
  years)
    years=$((diff / 31556926))  # Approximate year length in seconds
    months=$(((diff % 31556926) / 2629743))
    days=$((((diff % 31556926) % 2629743) / 86400))
    result="$years years, $months months, and $days days"
    ;;
  *)
    usage
    ;;
esac

if [ $quiet -eq 1 ]; then
  echo "$result"
else
  echo "$result since $date"
fi
