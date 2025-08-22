.PHONY: all build clean

NAME := loco

REF := main

FILTER_DIR := tools/pandoc-tools/filters
TEMPLATE_DIR := tools/pandoc-tools/templates

all: clean build

build: \
	build/$(NAME).md \
	build/$(NAME).css \
	build/$(NAME).html \
	build/$(NAME)-standalone.html \
	build/$(NAME).texi \
	build/$(NAME).info \
	build/README.md

build-dir:
	mkdir -p build

build/$(NAME).md: | build-dir
	pandoc \
		--from gfm \
		--lua-filter=$(FILTER_DIR)/append-default-footer.lua \
		--lua-filter=$(FILTER_DIR)/toc.lua \
		--output $@ \
		--to gfm \
		--wrap none \
		src/$(NAME).md

build/$(NAME).css: | build-dir
	cp tools/pandoc-tools/css/default.css $@

build/$(NAME).html: | build-dir
	pandoc \
		--from gfm \
		--lua-filter=$(FILTER_DIR)/append-html-footer.lua \
		--lua-filter=$(FILTER_DIR)/link-stylesheet.lua \
		--lua-filter=$(FILTER_DIR)/process-github-links.lua \
		--lua-filter=$(FILTER_DIR)/toc.lua \
		--metadata filter_process_github_links.ref=$(REF) \
		--output $@ \
		--template $(TEMPLATE_DIR)/default.html \
		--to html \
		--wrap none \
		src/$(NAME).md

build/$(NAME)-standalone.html: | build-dir
	pandoc \
		--from gfm \
		--lua-filter=$(FILTER_DIR)/append-html-footer.lua \
		--lua-filter=$(FILTER_DIR)/embed-stylesheet.lua \
		--lua-filter=$(FILTER_DIR)/process-github-links.lua \
		--lua-filter=$(FILTER_DIR)/toc.lua \
		--metadata filter_process_github_links.ref=$(REF) \
		--output $@ \
		--template $(TEMPLATE_DIR)/default.html \
		--to html \
		--wrap none \
		src/$(NAME).md

build/$(NAME).texi: | build-dir
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
		src/$(NAME).md

build/$(NAME).info: build/$(NAME).texi
	makeinfo --output $@ build/$(NAME).texi

build/README.md: | build-dir
	pandoc \
		--from gfm \
		--lua-filter=$(FILTER_DIR)/toc.lua \
		--output $@ \
		--to gfm \
		--wrap none \
		src/README.md

clean:
	rm -fr build
