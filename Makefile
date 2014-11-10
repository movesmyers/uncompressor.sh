PREFIX ?= /usr/local

install:
	cp -f uncompressor.sh $(PREFIX)/bin/uncompressor

uninstall:
	rm -f $(PREFIX)/bin/uncompressor
