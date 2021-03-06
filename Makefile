SHELL := bash -O nullglob
POSTS = $(shell files/posts.sh | awk -F'\x1f' '{print $$2}')

ifeq ($(wildcard post.txt),)
.DEFAULT_GOAL := index
else 
.DEFAULT_GOAL := post
endif 

.PHONY: post
post:
	echo "[0|post.txt|post.txt|server|port]" > index.gph
	if [ -f comments.txt ]; then echo "[0|comments.txt|comments.txt|server|port]" >> index.gph; fi
	if [ -f slides.txt ]; then echo "[0|slides.txt|slides.txt|server|port]" >> index.gph; fi
	if [ -d files ]; then echo "[1|files|files/|server|port]" >> index.gph; fi
	if [ -d photos ]; then echo "[1|photos|photos/|server|port]" >> index.gph; fi
	cat post.txt comments.txt | \
		perl -pe 's/\\\n//' | \
		awk '/[-]+(\|[-]+)+/ {print gensub("-", "", "G", $$0); print; next} {print}' | \
		sed -e 's@^\s*image:\(.*.\(jpg\|png\)\)\[\(.*\)]\s*$$@<div class="figure"><a href="photos/\1"><img src="photos/thumbnails/\1" alt="\3"></a><p class="caption">\3</p></div>@' | \
		sed -e 's@^\s*image:\(.*.\(jpg\|png\)\)\s*$$@<div class="figure"><a href="photos/\1"><img src="photos/thumbnails/\1" alt="\1"></a></div>@' | \
		sed -e 's@^\s*imagethumb:\(.*.\(jpg\|png\)\)\[\(.*\)]\s*$$@<div class="figure"><img src="photos/thumbnails/\1" alt="\3"><p class="caption">\3</p></div>@' | \
		sed -e 's@^\s*imagethumb:\(.*.\(jpg\|png\)\)\s*$$@<div class="figure"><img src="photos/thumbnails/\1" alt="\1"></div>@' | \
		sed -e 's@^\s*image:\(.*\).mov\[\(.*\)]\s*$$@<div class="figure"><a href="photos/\1.mov"><img src="photos/thumbnails/\1.jpg" alt="\2"></a><p class="caption">\2</p></div>@' | \
		sed -e 's@^\s*image:\(.*\).mov\s*$$@<div class="figure"><a href="photos/\1.mov"><img src="photos/thumbnails/\1.jpg" alt="\1.mov"></a></div>@' | \
		sed -e 's@^\s*image:\(.*\).mp4\[\(.*\)]\s*$$@<div class="figure"><a href="photos/\1.mp4"><img src="photos/thumbnails/\1.jpg" alt="\2"></a><p class="caption">\2</p></div>@' | \
		sed -e 's@^\s*image:\(.*\).mp4\s*$$@<div class="figure"><a href="photos/\1.mp4"><img src="photos/thumbnails/\1.jpg" alt="\1.mp4"></a></div>@' | \
		pandoc --template=../files/template.html -t html4 -f markdown-smart --no-highlight --lua-filter ../files/filter.lua --extract-media photos /dev/stdin > index.html
	if [ -d photos ]; then cd photos; ../../files/gallery_simplest.py --max-width 600 *.jpg *.mov *.png *.mp4; fi
	if [ -f slides.txt ]; then make slides.html; fi

.PHONY: clean
clean:
	rm -f index.html index.gph
	if [ -d photos ]; then cd photos; rm -Rf index.html; fi

.PHONY: posts
posts:
	for post in $(POSTS); do make -C $$post; done

#mp4:
#	for file in *.mov; do ffmpeg -i $$file -vcodec libx264 -acodec mp3 -movflags +faststart ${file/%.mov/.mp4}; done
#	for file in *.mov; do exiftool -overwrite_original_in_place -tagsFromFile $$file ${file/%.mov/.mp4}; done

.PHONY: index
index:
	./files/gen_gph.sh > index.gph
	./files/gen_html.sh > index.html
	for tag in tags/*; do make -C $$tag; done

auto-orient: #rotate jpegs per EXIF tag
	cd photos; for file in *jpg; do mogrify -auto-orient $$file; done

slides.html: slides.txt ../files/slides-template.html
	pandoc -t dzslides --template ../files/slides-template.html -s slides.txt -f markdown-auto_identifiers --mathjax="files/MathJax-2.7.5/MathJax.js?config=TeX-MML-AM_CHTML" -o slides.html
