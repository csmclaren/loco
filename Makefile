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
		--lua-filter=tools/filter-append-footer.lua \
		--lua-filter=tools/filter-link-stylesheet.lua \
		--metadata title="Loco" \
		--template tools/loco-template.html \
		-o docs/loco.html \
		README.md
	pandoc \
		--lua-filter=tools/filter-append-footer.lua \
		--lua-filter=tools/filter-embed-stylesheet.lua \
		--metadata title="Loco" \
		--template tools/loco-template.html \
		-o docs/loco-standalone.html \
		README.md

set-permissions:
	find . -type d -exec chmod 755 {} \;
	find . -type f -exec chmod 644 {} \;

set-timestamps:
	find . -exec touch {} +
