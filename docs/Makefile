.PHONY: all build clean

all: clean build

build: build/loco.md build/loco.css build/loco.html build/loco-standalone.html build/loco.texi build/loco.info build/README.md

build/loco.md:
	mkdir -p build && \
	pandoc \
		--from gfm \
		--lua-filter=tools/pandoc/filter-append-default-footer.lua \
		--lua-filter=tools/pandoc/filter-toc.lua \
		--metadata filter_toc_exclude_pattern="table%-of%-contents" \
		--metadata title="Loco" \
		--output build/loco.md \
		--to gfm \
		src/loco.md

build/loco.css:
	mkdir -p build && \
	curl \
		-o build/loco.css \
		https://raw.githubusercontent.com/sindresorhus/github-markdown-css/gh-pages/github-markdown.css

build/loco.html:
	mkdir -p build && \
	pandoc \
		--from gfm \
		--lua-filter=tools/pandoc/filter-append-html-footer.lua \
		--lua-filter=tools/pandoc/filter-link-stylesheet.lua \
		--lua-filter=tools/pandoc/filter-toc.lua \
		--metadata filter_link_stylesheet_fpath="loco.css" \
		--metadata filter_toc_exclude_pattern="table%-of%-contents" \
		--metadata title="Loco" \
		--output build/loco.html \
		--template tools/pandoc/template.html \
		--to html \
		src/loco.md

build/loco-standalone.html:
	mkdir -p build && \
	pandoc \
		--from gfm \
		--lua-filter=tools/pandoc/filter-append-html-footer.lua \
		--lua-filter=tools/pandoc/filter-embed-stylesheet.lua \
		--lua-filter=tools/pandoc/filter-toc.lua \
		--metadata filter_embed_stylesheet_fpath="build/loco.css" \
		--metadata filter_toc_exclude_pattern="table%-of%-contents" \
		--metadata title="Loco" \
		--output build/loco-standalone.html \
		--template tools/pandoc/template.html \
		--to html \
		src/loco.md

build/loco.texi:
	mkdir -p build && \
	pandoc \
		--from gfm \
		--lua-filter=tools/pandoc/filter-adjust-header-depths.lua \
		--lua-filter=tools/pandoc/filter-append-default-footer.lua \
		--lua-filter=tools/pandoc/filter-process-kbd.lua \
		--lua-filter=tools/pandoc/filter-strip-headers.lua \
		--lua-filter=tools/pandoc/filter-trim-headers.lua \
		--lua-filter=tools/pandoc/filter-toc.lua \
		--metadata dircategory="Emacs" \
		--metadata direntry="* Loco: (loco).                 A library and minor mode for entering key sequences" \
		--metadata filter_toc_exclude_pattern="table%-of%-contents" \
		--metadata title="Loco" \
		--output build/loco.texi \
		--template tools/pandoc/template.texinfo \
		--to texinfo \
		src/loco.md

build/loco.info: build/loco.texi
	makeinfo --output build/loco.info build/loco.texi

build/README.md:
	mkdir -p build && \
	pandoc \
		--from gfm \
		--lua-filter=tools/pandoc/filter-append-default-footer.lua \
		--lua-filter=tools/pandoc/filter-toc.lua \
		--metadata filter_toc_exclude_pattern="table%-of%-contents" \
		--metadata title="Loco" \
		--output build/README.md \
		--to gfm \
		src/README.md

clean:
	rm -fr build
