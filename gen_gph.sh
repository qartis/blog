#!/bin/sh

#[0|post.txt|post.txt|server|port]
#[1|photos|photos/|server|port]

ls */post.txt | while read f; do
	echo -n "[1|"
	cat $f | awk '/^date: / {printf $2}'
	echo -n " "
	cat $f | awk -F'"' '/^title: / {printf $2}'
	echo -n "|"
	echo -n $(dirname $f)
	echo -n "|server|port]"
	echo
done
