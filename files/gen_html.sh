#!/bin/sh
echo '<link rel="alternate" type="application/atom+xml" href="/index.xml">'

./files/posts.sh | awk -F'\x1f' '{printf "<li>%s <a href='%s'>%s</a>\n",$1,$2,$3}'
