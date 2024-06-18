.PHONY: all clean-docs make-docs prepare-to-ship

all: prepare-to-ship

clean-docs:
	rm -f docs/README.css
	rm -f docs/README.html
	rm -f docs/README-standalone.html

make-docs:
	curl https://raw.githubusercontent.com/sindresorhus/github-markdown-css/gh-pages/github-markdown.css -o docs/README.css
	pandoc --lua-filter=tools/filter-embed-stylesheet.lua --lua-filter=tools/filter-append-footer.lua --metadata title="Loco" --template tools/README-template.html README.md -o docs/README-standalone.html
	pandoc --lua-filter=tools/filter-link-stylesheet.lua --lua-filter=tools/filter-append-footer.lua --metadata title="Loco" --template tools/README-template.html README.md -o docs/README.html

prepare-to-ship: clean-docs make-docs
	find . -type d -exec chmod 755 {} \;
	find . -type f -exec chmod 644 {} \;
	find . -exec touch {} +
