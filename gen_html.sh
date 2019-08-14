#!/bin/sh
ls */post.txt | while read f; do
	echo -n "<li>"
	cat $f | awk '/^date: / {printf $2}'
	echo -n " "
	echo -n "<a href='$(dirname $f)'>"
	cat $f | awk -F'"' '/^title: / {printf $2}'
	echo "</a>"
done
