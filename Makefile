include meta.mk
export NAME REF REPOSITORY_URL VERSION

FILTER_DIR := tools/pandoc-tools/filters
TEMPLATE_DIR := tools/pandoc-tools/templates

.PHONY: all build check check-emacs check-headers clean docs docs-build-dir set-permissions set-timestamps

all: clean build

build: check docs set-permissions set-timestamps

check: check-headers

check-emacs:
	@command -v emacs >/dev/null 2>&1 || \
		{ echo "Error: 'emacs' is not installed or not in PATH."; exit 1; }

check-headers: check-emacs
	FILE=$(NAME).el URL=$(REPOSITORY_URL) VERSION=$(VERSION) \
		emacs -Q --batch -l lisp-mnt -l tools/check-headers.el

clean:
	$(RM) -f README.md
	$(RM) -f $(NAME).info
	$(RM) -fr docs/build

docs: \
	docs/build/$(NAME).css \
	docs/build/$(NAME).html \
	docs/build/$(NAME).md \
	docs/build/$(NAME).texi \
	$(NAME).info \
	README.md

docs-build-dir:
	mkdir -p docs/build

docs/build/$(NAME).css: tools/pandoc-tools/css/default.css | docs-build-dir
	cp tools/pandoc-tools/css/default.css $@

docs/build/$(NAME).html: docs/src/$(NAME).md | docs-build-dir docs/build/$(NAME).css
	pandoc \
		--from gfm \
		--lua-filter=$(FILTER_DIR)/append-html-footer.lua \
		--lua-filter=$(FILTER_DIR)/link-stylesheet.lua \
		--lua-filter=$(FILTER_DIR)/process-github-links.lua \
		--lua-filter=$(FILTER_DIR)/toc.lua \
		--metadata filter_embed_stylesheet_fpath=docs/build/$(NAME).css \
		--metadata filter_link_stylesheet_fpath=$(NAME).css \
		--metadata filter_process_github_links.ref=$(REF) \
		--metadata filter_process_github_links.repo=$(NAME) \
		--output $@ \
		--template $(TEMPLATE_DIR)/default.html \
		--to html \
		--wrap none \
		docs/src/$(NAME).md

docs/build/$(NAME).md: docs/src/$(NAME).md | docs-build-dir
	pandoc \
		--from gfm \
		--lua-filter=$(FILTER_DIR)/append-default-footer.lua \
		--lua-filter=$(FILTER_DIR)/toc.lua \
		--output $@ \
		--to gfm \
		--wrap none \
		docs/src/$(NAME).md

docs/build/$(NAME).texi: docs/src/$(NAME).md | docs-build-dir
	pandoc \
		--from gfm \
		--lua-filter=$(FILTER_DIR)/adjust-header-depths.lua \
		--lua-filter=$(FILTER_DIR)/append-default-footer.lua \
		--lua-filter=$(FILTER_DIR)/process-kbd.lua \
		--lua-filter=$(FILTER_DIR)/strip-headers.lua \
		--lua-filter=$(FILTER_DIR)/trim-headers.lua \
		--lua-filter=$(FILTER_DIR)/toc.lua \
		--output $@ \
		--template $(TEMPLATE_DIR)/default.texinfo \
		--to texinfo \
		--wrap none \
		docs/src/$(NAME).md

$(NAME).info: docs/build/$(NAME).texi | docs-build-dir
	makeinfo --output $@ docs/build/$(NAME).texi

README.md: docs/src/README.md | docs-build-dir
	pandoc \
		--from gfm \
		--lua-filter=$(FILTER_DIR)/toc.lua \
		--output $@ \
		--to gfm \
		--wrap none \
		docs/src/README.md

set-permissions:
	find . -type d -exec chmod 755 {} +
	find . -type f -exec chmod 644 {} +

set-timestamps:
	find . -path './.git' -prune -o -exec touch {} +
