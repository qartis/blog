#!/bin/sh

URL_BASE="http://blog.qartis.com/"
UPDATED_DATE=$(./files/posts.sh | head -n 1 | awk -F '\x1f' '{print $1}')

(

cat <<EOF
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <title>Personal blog of Andrew Fuller</title>
  <id>http://blog.qartis.com/index.xml</id>
  <link href="http://blog.qartis.com/index.xml" rel="self"/>
  <updated>${UPDATED_DATE}T00:00:00Z</updated>
EOF

./files/posts.sh | head -n 5 | awk -F'\x1f' -v URL_BASE=$URL_BASE '{url=URL_BASE$2; printf "<entry><title>%s</title><id>%s</id><link href=\"%s\"/><author><name>Andrew</name></author><updated>%sT00:00:00Z</updated><content>%s</content></entry>", $3, url, url, $1, $3}'

echo "</feed>"

) | xmllint -format -
