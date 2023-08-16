#!/bin/bash


for p in $(grep -Ev '^(#|$)' ~/.mbsyncrc | grep Path | cut -d' ' -f2)
do
	echo mkdir -p ${p}/Sent.$(date +%Y-%m)/{cur,new,tmp}
done
