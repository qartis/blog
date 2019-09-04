#!/bin/sh
echo '<link rel="alternate" type="application/atom+xml" href="/index.xml">'
echo '<style>body{font-size:1.2em}</style>'

./files/posts.sh | awk -F'\x1f' '{printf "<li>%s <a href='%s'>%s</a>\n",$1,$2,$3}'

echo '<hr />'
echo 'Andrew Fuller <a href="mailto:qartis@gmail.com">qartis@gmail.com</a>'
