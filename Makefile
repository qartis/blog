SHELL := bash -O nullglob
#DATE := $(shell cat index.txt | awk '/^title: / && NR<5 {print $$2}')
#TITLE := $(shell cat post.txt | awk -F'"' '/^title: / {print $2}')

all:
	echo "[0|post.txt|post.txt|server|port]" > index.gph
	if [ -d photos ]; then echo "[1|photos|photos/|server|port]" >> index.gph; fi

	cat post.txt | \
		awk '/[-]+(\|[-]+)+/ {print gensub("-", "", "G", $$0); print; next} {print}' | \
		sed -e 's@^\s*image:\(.*.\(jpg\|png\)\)\[\(.*\)]\s*$$@<div class="figure"><a href="photos/\1"><img src="photos/thumbnails/\1" alt="\3"></a><p class="caption">\3</p></div>@' | \
		sed -e 's@^\s*image:\(.*.\(jpg\|png\)\)\s*$$@<div class="figure"><a href="photos/\1"><img src="photos/thumbnails/\1" alt="\1"></a></div>@' | \
		sed -e 's@^\s*image:\(.*\).mov\[\(.*\)]\s*$$@<div class="figure"><a href="photos/\1.mov"><img src="photos/thumbnails/\1.jpg" alt="\2"></a><p class="caption">\2</p></div>@' | \
		sed -e 's@^\s*image:\(.*\).mov\s*$$@<div class="figure"><a href="photos/\1.mov"><img src="photos/thumbnails/\1.jpg" alt="\1.mov"></a></div>@' | \
		sed -e 's@^\s*image:\(.*\).mp4\[\(.*\)]\s*$$@<div class="figure"><a href="photos/\1.mp4"><img src="photos/thumbnails/\1.jpg" alt="\2"></a><p class="caption">\2</p></div>@' | \
		sed -e 's@^\s*image:\(.*\).mp4\s*$$@<div class="figure"><a href="photos/\1.mp4"><img src="photos/thumbnails/\1.jpg" alt="\1.mp4"></a></div>@' | \
		pandoc --template=../template.html -t html4 -f markdown-auto_identifiers --no-highlight /dev/stdin > index.html
	if [ -d photos ]; then cd photos; ../../gallery_simplest.py --max-width 600 *.jpg *.mov *.png *.mp4; fi

date:
	@echo $(DATE)

.PHONY: clean
clean:
	rm index.html
	cd photos; rm -Rf index.html
	
#mp4:
#	for file in *.mov; do ffmpeg -i $$file -vcodec libx264 -acodec mp3 -movflags +faststart ${file/%.mov/.mp4}; done
#	for file in *.mov; do exiftool -overwrite_original_in_place -tagsFromFile $$file ${file/%.mov/.mp4}; done

index:
	./gen_gph.sh | sort -r > index.gph
	./gen_html.sh | sort -r > index.html
