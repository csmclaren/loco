.PHONY: all build clean docs set-permissions set-timestamps

all: clean build

build: docs loco.info README.md set-permissions set-timestamps

docs:
	$(MAKE) -C docs build

loco.info: docs
	cp docs/build/loco.info loco.info

README.md: docs
	cp docs/build/loco.md README.md

set-permissions:
	find . -path './_private' -prune -o -type d -exec chmod 755 {} \;
	find . -path './_private' -prune -o -type f -exec chmod 644 {} \;

set-timestamps:
	find . -exec touch {} +

clean:
	$(MAKE) -C docs clean
	rm -f loco.info
	rm -f README.md
