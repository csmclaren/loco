include meta.mk
export NAME REF REPOSITORY_URL VERSION

export COPYFILE_DISABLE=1

FIND_EXCLUDES  := \
	\( \
		-name '.DS_Store' -o \
		-name '.Spotlight-*' -o \
		-name '.Trashes' -o \
		-name '._*' \
	\) \
	-prune -o \
	-type f \
	-print

SHA256SUM := $(shell command -v sha256sum >/dev/null 2>&1 && printf '%s' 'sha256sum' || printf '%s' 'shasum -a 256')

TAR := tar \
	--format=ustar \
	--group=0 \
	--no-acls --no-mac-metadata --no-xattrs \
	--numeric-owner \
	--options gzip:!timestamp,gzip:compression-level=9 \
	--owner=0 \
	-czf

ZIP := zip -X

ZERO_TIMESTAMP := 197001010000

FILTER_DIR := tools/pandoc-tools/filters
TEMPLATE_DIR := tools/pandoc-tools/templates

.DELETE_ON_ERROR:

.PHONY: all
all: build

.PHONY: build
build: check dist docs

.PHONY: check
check: check-emacs check-headers check-makeinfo check-pandoc

.PHONY: check-emacs
check-emacs:
	@command -v emacs >/dev/null 2>&1 || \
		{ echo "Error: 'emacs' is not installed or not in PATH." >&2; exit 1; }

.PHONY: check-headers
check-headers: | check-emacs
	FILE=$(NAME).el URL=$(REPOSITORY_URL) VERSION=$(VERSION) \
		emacs -Q --batch -l lisp-mnt -l tools/check-headers.el

.PHONY: check-makeinfo
check-makeinfo:
	@command -v makeinfo >/dev/null 2>&1 || \
		{ echo "Error: 'makeinfo' is not installed or not in PATH." >&2; exit 1; }

.PHONY: check-pandoc
check-pandoc:
	@command -v pandoc >/dev/null 2>&1 || \
		{ echo "Error: 'pandoc' is not installed or not in PATH." >&2; exit 1; }

.PHONY: clean
clean:
	$(RM) -f $(NAME).info README.md
	$(RM) -fr dist docs/build

.PHONY: dist
dist: \
	dist/$(NAME)-$(VERSION)-docs.tar.gz \
	dist/$(NAME)-$(VERSION)-docs.zip

dist/$(NAME)-$(VERSION)-docs.tar.gz: dist/.stamps/docs.sha256
	@mkdir -p $(@D)
	cd dist && find docs $(FIND_EXCLUDES) | LC_ALL=C sort | $(TAR) $(abspath $@) -T -

dist/$(NAME)-$(VERSION)-docs.zip: dist/.stamps/docs.sha256
	@mkdir -p $(@D)
	cd dist && find docs $(FIND_EXCLUDES) | LC_ALL=C sort | $(ZIP) -@ $(abspath $@)

.PHONY: dist-docs
dist-docs: dist/.stamps/docs.sha256

dist/.stamps/docs.sha256: \
	$(wildcard $(FILTER_DIR)/*) \
	$(wildcard $(TEMPLATE_DIR)/*) \
	docs/src/$(NAME).md \
	tools/pandoc-tools/css/default.css | check-pandoc
	@mkdir -p $(@D)
	@mkdir -p dist/docs/
	cp tools/pandoc-tools/css/default.css dist/docs/$(NAME)-$(VERSION).css
	pandoc \
		--from gfm \
		--lua-filter=$(FILTER_DIR)/link-stylesheet.lua \
		--lua-filter=$(FILTER_DIR)/process-github-links.lua \
		--lua-filter=$(FILTER_DIR)/replace.lua \
		--lua-filter=$(FILTER_DIR)/toc.lua \
		--metadata filter_link_stylesheet_fpath=$(NAME)-$(VERSION).css \
		--metadata filter_process_github_links.ref=$(REF) \
		--metadata filter_process_github_links.repo=$(NAME) \
		--metadata name=$(NAME) \
		--metadata repository-url=$(REPOSITORY_URL) \
		--metadata version=$(VERSION) \
		--output dist/docs/$(NAME)-$(VERSION).html \
		--template $(TEMPLATE_DIR)/default.html \
		--to html \
		--wrap none \
		docs/src/$(NAME).md
	find dist/docs -type d -exec chmod 755 {} +
	find dist/docs -type f -exec chmod 644 {} +
	TZ=UTC find dist/docs -exec touch -t $(ZERO_TIMESTAMP) {} +
	HASH=$$(cd dist && \
		find docs -type f -print0 \
		| xargs -0 $(SHA256SUM) \
		| LC_ALL=C sort \
		| $(SHA256SUM) \
		| awk '{print $$1}') ; \
	NEW=$$(mktemp); printf '%s\n' "$$HASH" > "$$NEW"; \
	if [ -f $@ ] && cmp -s "$$NEW" $@; then rm -f "$$NEW"; else mv -f "$$NEW" $@; fi

.PHONY: docs
docs: \
	dist-docs \
	docs/build/$(NAME).md \
	docs/build/$(NAME).texi \
	$(NAME).info \
	README.md

docs/build/$(NAME).md: \
	$(wildcard $(FILTER_DIR)/*) \
	docs/src/$(NAME).md | check-pandoc
	@mkdir -p $(@D)
	pandoc \
		--from gfm \
		--lua-filter=$(FILTER_DIR)/replace.lua \
		--lua-filter=$(FILTER_DIR)/toc.lua \
		--metadata name=$(NAME) \
		--metadata repository-url=$(REPOSITORY_URL) \
		--metadata version=$(VERSION) \
		--output $@ \
		--to gfm \
		--wrap none \
		docs/src/$(NAME).md

docs/build/$(NAME).texi: \
	$(wildcard $(FILTER_DIR)/*) \
	docs/src/$(NAME).md | check-pandoc
	@mkdir -p $(@D)
	pandoc \
		--from gfm \
		--lua-filter=$(FILTER_DIR)/adjust-header-depths.lua \
		--lua-filter=$(FILTER_DIR)/process-kbd.lua \
		--lua-filter=$(FILTER_DIR)/strip-headers.lua \
		--lua-filter=$(FILTER_DIR)/trim-headers.lua \
		--lua-filter=$(FILTER_DIR)/toc.lua \
		--output $@ \
		--template $(TEMPLATE_DIR)/default.texinfo \
		--to texinfo \
		--wrap none \
		docs/src/$(NAME).md

$(NAME).info: docs/build/$(NAME).texi | check-makeinfo
	makeinfo --output $@ docs/build/$(NAME).texi

README.md: \
	$(wildcard $(FILTER_DIR)/*) \
	docs/src/README.md | check-pandoc
	pandoc \
		--from gfm \
		--lua-filter=$(FILTER_DIR)/replace.lua \
		--lua-filter=$(FILTER_DIR)/toc.lua \
		--metadata name=$(NAME) \
		--metadata repository-url=$(REPOSITORY_URL) \
		--metadata version=$(VERSION) \
		--output $@ \
		--to gfm \
		--wrap none \
		docs/src/README.md

.PHONY: set-permissions
set-permissions:
	find . -type d -exec chmod 755 {} +
	find . -type f -exec chmod 644 {} +

.PHONY: set-timestamps
set-timestamps:
	find . -path './.git' -prune -o -path './dist' -prune -o -exec touch {} +
