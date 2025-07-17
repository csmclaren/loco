.PHONY: all build clean

all: clean build

clean:
	rm -fr build

build: \
	build/loco.md \
	build/loco.css \
	build/loco.html \
	build/loco-standalone.html \
	build/loco.texi \
	build/loco.info \
	build/README.md

build/loco.md:
	mkdir -p build && \
	pandoc \
		--from gfm \
		--lua-filter=tools/pandoc-tools/filters/filter-append-default-footer.lua \
		--lua-filter=tools/pandoc-tools/filters/filter-toc.lua \
		--output build/loco.md \
		--to gfm \
		--wrap none \
		src/loco.md

build/loco.css:
	mkdir -p build && \
	cp tools/pandoc-tools/css/default.css build/loco.css

build/loco.html:
	mkdir -p build && \
	pandoc \
		--from gfm \
		--lua-filter=tools/pandoc-tools/filters/filter-append-html-footer.lua \
		--lua-filter=tools/pandoc-tools/filters/filter-link-stylesheet.lua \
		--lua-filter=tools/pandoc-tools/filters/filter-toc.lua \
		--output build/loco.html \
		--template tools/pandoc-tools/templates/template.html \
		--to html \
		--wrap none \
		src/loco.md

build/loco-standalone.html:
	mkdir -p build && \
	pandoc \
		--from gfm \
		--lua-filter=tools/pandoc-tools/filters/filter-append-html-footer.lua \
		--lua-filter=tools/pandoc-tools/filters/filter-embed-stylesheet.lua \
		--lua-filter=tools/pandoc-tools/filters/filter-toc.lua \
		--output build/loco-standalone.html \
		--template tools/pandoc-tools/templates/template.html \
		--to html \
		--wrap none \
		src/loco.md

build/loco.texi:
	mkdir -p build && \
	pandoc \
		--from gfm \
		--lua-filter=tools/pandoc-tools/filters/filter-adjust-header-depths.lua \
		--lua-filter=tools/pandoc-tools/filters/filter-append-default-footer.lua \
		--lua-filter=tools/pandoc-tools/filters/filter-process-kbd.lua \
		--lua-filter=tools/pandoc-tools/filters/filter-strip-headers.lua \
		--lua-filter=tools/pandoc-tools/filters/filter-trim-headers.lua \
		--lua-filter=tools/pandoc-tools/filters/filter-toc.lua \
		--output build/loco.texi \
		--template tools/pandoc-tools/templates/template.texinfo \
		--to texinfo \
		--wrap none \
		src/loco.md

build/loco.info: build/loco.texi
	makeinfo --output build/loco.info build/loco.texi

build/README.md:
	mkdir -p build && \
	pandoc \
		--from gfm \
		--lua-filter=tools/pandoc-tools/filters/filter-toc.lua \
		--output build/README.md \
		--to gfm \
		--wrap none \
		src/README.md
