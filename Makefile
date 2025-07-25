.PHONY: all build clean docs set-permissions set-timestamps

all: clean build

build: docs loco.info README.md set-permissions set-timestamps

docs:
	$(MAKE) -C docs build

loco.info: docs
	cp docs/build/$@ $@

README.md: docs
	cp docs/build/$@ $@

set-permissions:
	find . -type d -exec chmod 755 {} +
	find . -type f -exec chmod 644 {} +

set-timestamps:
	find . -path './.git' -prune -o -exec touch {} +

clean:
	$(MAKE) -C docs clean
	rm -f loco.info
	rm -f README.md
