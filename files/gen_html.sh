#!/bin/sh
<< 'FOO'
echo '<style>
body{font-size:1.2em}
li {
text-overflow: ellipsis;
white-space: nowrap;
overflow: hidden;
}
</style>'
FOO

./files/posts.sh | awk -F'\x1f' '{printf "<li>%s <a href='%s'>%s</a>\n",$1,$2,$3}'
if [ -d tags ]; then echo '<li><a href=tags>tags</a>'; fi
echo '<hr />'
echo 'Andrew Fuller <a href="mailto:qartis@gmail.com">qartis@gmail.com</a>'
