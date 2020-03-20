#!/bin/sh

#[0|post.txt|post.txt|server|port]
#[1|photos|photos/|server|port]

./files/posts.sh | awk -F'\x1f' '{printf "[1|%s %s|%s|server|port]\n",$1,$3,$2}'

if [ -d tags ]; then echo '[1|tags|tags|server|port]'; fi
