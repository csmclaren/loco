.PHONY: all clean-docs make-docs set-permissions set-timestamps

all: clean-docs make-docs set-permissions set-timestamps

clean-docs:
	rm -f README.md
	rm -f docs/build/loco.css
	rm -f docs/build/loco.html
	rm -f docs/build/loco-standalone.html
	rm -f docs/build/loco.texi
	rmdir docs/build || true
	rm -f loco.info

make-docs:
	mkdir -p docs/build
	pandoc \
		--from gfm \
		--lua-filter=tools/pandoc/filter-toc.lua \
		--metadata title="Loco" \
		--output README.md \
		--to gfm \
		docs/src/loco.md
	curl \
		-o docs/build/loco.css \
		https://raw.githubusercontent.com/sindresorhus/github-markdown-css/gh-pages/github-markdown.css
	pandoc \
		--from gfm \
		--lua-filter=tools/pandoc/filter-append-html-footer.lua \
		--lua-filter=tools/pandoc/filter-link-stylesheet.lua \
		--lua-filter=tools/pandoc/filter-toc.lua \
		--metadata filter_link_stylesheet_fpath="loco.css" \
		--metadata title="Loco" \
		--output docs/build/loco.html \
		--template tools/pandoc/template.html \
		--to html \
		docs/src/loco.md
	pandoc \
		--from gfm \
		--lua-filter=tools/pandoc/filter-append-html-footer.lua \
		--lua-filter=tools/pandoc/filter-embed-stylesheet.lua \
		--lua-filter=tools/pandoc/filter-toc.lua \
		--metadata filter_embed_stylesheet_fpath="docs/build/loco.css" \
		--metadata title="Loco" \
		--output docs/build/loco-standalone.html \
		--template tools/pandoc/template.html \
		--to html \
		docs/src/loco.md
	pandoc \
		--from gfm \
		--lua-filter=tools/pandoc/filter-adjust-header-depths.lua \
		--lua-filter=tools/pandoc/filter-process-kbd.lua \
		--lua-filter=tools/pandoc/filter-strip-headers.lua \
		--lua-filter=tools/pandoc/filter-trim-headers.lua \
		--lua-filter=tools/pandoc/filter-toc.lua \
		--metadata dircategory="Emacs" \
		--metadata direntry="* Loco: (loco).                 A library and minor mode for entering key sequences" \
		--metadata title="Loco" \
		--output docs/build/loco.texi \
		--template tools/pandoc/template.texinfo \
		--to texinfo \
		docs/src/loco.md
	makeinfo --output loco.info docs/build/loco.texi

set-permissions:
	find . -type d -exec chmod 755 {} \;
	find . -type f -exec chmod 644 {} \;

set-timestamps:
	find . -exec touch {} +
