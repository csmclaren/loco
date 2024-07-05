.PHONY: all clean-docs make-docs set-permissions set-timestamps

all: clean-docs make-docs set-permissions set-timestamps

clean-docs:
	rm -f docs/loco.css
	rm -f docs/loco.html
	rm -f docs/loco-standalone.html

make-docs:
	curl \
		-o docs/loco.css \
		https://raw.githubusercontent.com/sindresorhus/github-markdown-css/gh-pages/github-markdown.css
	pandoc \
		--from gfm \
		--lua-filter=tools/pandoc/filter-append-html-footer.lua \
		--lua-filter=tools/pandoc/filter-link-stylesheet.lua \
		--metadata title="Loco" \
		--output docs/loco.html \
		--template tools/pandoc/template.html \
		--to html \
		README.md
	pandoc \
		--from gfm \
		--lua-filter=tools/pandoc/filter-append-html-footer.lua \
		--lua-filter=tools/pandoc/filter-embed-stylesheet.lua \
		--metadata filter_embed_stylesheet_fpath="docs/loco.css" \
		--metadata title="Loco" \
		--output docs/loco-standalone.html \
		--template tools/pandoc/template.html \
		--to html \
		README.md

set-permissions:
	find . -type d -exec chmod 755 {} \;
	find . -type f -exec chmod 644 {} \;

set-timestamps:
	find . -exec touch {} +
