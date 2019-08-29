SHELL := bash -O nullglob
#DATE := $(shell cat post.txt | awk '/^date: / {print $$2; exit}')
#TITLE := $(shell cat post.txt | awk -F'"' '/^title: / {print $$2; exit}')
POSTS = $(shell files/posts.sh | awk -F'\x1f' '{print $$2}')



all:
	echo "[0|post.txt|post.txt|server|port]" > index.gph
	if [ -d photos ]; then echo "[1|photos|photos/|server|port]" >> index.gph; fi
	cat post.txt | \
		perl -pe 's/\\\n//' | \
		awk '/[-]+(\|[-]+)+/ {print gensub("-", "", "G", $$0); print; next} {print}' | \
		sed -e 's@^\s*image:\(.*.\(jpg\|png\)\)\[\(.*\)]\s*$$@<div class="figure"><a href="photos/\1"><img src="photos/thumbnails/\1" alt="\3"></a><p class="caption">\3</p></div>@' | \
		sed -e 's@^\s*image:\(.*.\(jpg\|png\)\)\s*$$@<div class="figure"><a href="photos/\1"><img src="photos/thumbnails/\1" alt="\1"></a></div>@' | \
		sed -e 's@^\s*image:\(.*\).mov\[\(.*\)]\s*$$@<div class="figure"><a href="photos/\1.mov"><img src="photos/thumbnails/\1.jpg" alt="\2"></a><p class="caption">\2</p></div>@' | \
		sed -e 's@^\s*image:\(.*\).mov\s*$$@<div class="figure"><a href="photos/\1.mov"><img src="photos/thumbnails/\1.jpg" alt="\1.mov"></a></div>@' | \
		sed -e 's@^\s*image:\(.*\).mp4\[\(.*\)]\s*$$@<div class="figure"><a href="photos/\1.mp4"><img src="photos/thumbnails/\1.jpg" alt="\2"></a><p class="caption">\2</p></div>@' | \
		sed -e 's@^\s*image:\(.*\).mp4\s*$$@<div class="figure"><a href="photos/\1.mp4"><img src="photos/thumbnails/\1.jpg" alt="\1.mp4"></a></div>@' | \
		pandoc --template=../files/template.html -t html4 -f markdown --no-highlight /dev/stdin > index.html
	if [ -d photos ]; then cd photos; ../../files/gallery_simplest.py --max-width 600 *.jpg *.mov *.png *.mp4; fi

.PHONY: clean
clean:
	rm index.html
	if [ -d photos ]; then cd photos; rm -Rf index.html; fi

posts:
	for post in $(POSTS); do make -C $$post all; done

#date:
#	@echo $(DATE)

	
#mp4:
#	for file in *.mov; do ffmpeg -i $$file -vcodec libx264 -acodec mp3 -movflags +faststart ${file/%.mov/.mp4}; done
#	for file in *.mov; do exiftool -overwrite_original_in_place -tagsFromFile $$file ${file/%.mov/.mp4}; done

index:
	./files/gen_gph.sh > index.gph
	./files/gen_html.sh > index.html

auto-orient: #rotate jpegs per EXIF tag
	cd photos; for file in *jpg; do mogrify -auto-orient $$file; done
