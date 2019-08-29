#!/bin/sh

(ls */post.txt | while read f; do
	cat $f | awk '/^date: / {printf $2}'
	echo -n '\037'
	echo -n $(dirname $f)
	echo -n '\037'
	cat $f | awk -F'"' '/^title: / {printf $2}'
	echo -n '\037'
	cat $f | 
	echo
done) | sort -r
