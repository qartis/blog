SHELL := bash -O nullglob

all:
#	if the image syntax is: image:photos/IMG_1234.jpg[alt="Alt text"]
#	cat index.txt | sed -e 's/^\s*image:\(.*\)\[alt="\(.*\)"]\s*$$/![\2](\1)/' | pandoc --template=template.html -t html4 --no-highlight /dev/stdin > index.html
#	if the image syntax is: image:IMG_1234.jpg[Alt text]
	cat index.txt | sed -e 's|^\s*image:\(.*\)\[\(.*\)]\s*$$|<div class="figure"><a href="photos/\1"><img class="block" src="photos/thumbnails/\1" alt="\2"></a><p class="caption">\2</p></div>|' | pandoc --template=template.html -t html4 --no-highlight /dev/stdin > index.html

	cd photos; ../gallery_simplest.py *.jpg *.mov *.MOV *.png *.mp4

.PHONY: clean
clean:
	rm index.html
	cd photos; rm -Rf index.html
	
