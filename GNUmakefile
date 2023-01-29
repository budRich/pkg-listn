.PHONY: install install-dev uninstall uninstall-dev

NAME := pkg-listn


install:
	install -Dm755 pkg-listn.bash $(DESTDIR)$(PREFIX)/bin/$(NAME)

install-dev:
	ln -fs pkg-listn.bash $(DESTDIR)$(PREFIX)/bin/$(NAME)

uninstall-dev: uninstall

uninstall:
	rm $(DESTDIR)$(PREFIX)/bin/$(NAME)
