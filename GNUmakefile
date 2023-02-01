.PHONY: install install-dev uninstall uninstall-dev

.ONESHELL:
SHELL := /bin/bash

# .DEFAULT_GOAL       := all

NAME        := pkg-listn
PREFIX      ?= /usr
SYSTEMD_DIR := $(DESTDIR)$(PREFIX)/lib/systemd/user

$(NAME): $(NAME).bash
	m4 -DDATA_DIR=$(PREFIX)/share/$(NAME) $< >$@

install: $(NAME)
	install -Dm755 $(NAME) -t $(DESTDIR)$(PREFIX)/bin/
	install -Dm644 conf/*  -t $(DESTDIR)$(PREFIX)/share/$(NAME)
	[[ -e $(DESTDIR)$(PREFIX)/lib/systemd/ ]] && {
		install -Dm644 systemd/pkg-listn.service -t $(SYSTEMD_DIR)
		install -Dm644 systemd/pkg-listn.path    -t $(SYSTEMD_DIR)
	}

	rm $(NAME)

install-dev:
	ln -fs $(realpath $(NAME).bash) $(DESTDIR)$(PREFIX)/bin/$(NAME)

uninstall-dev: uninstall

uninstall:
	rm $(DESTDIR)$(PREFIX)/bin/$(NAME)
	[[ -f $(SYSTEMD_DIR)/pkg-listn.service ]]  && rm $(SYSTEMD_DIR)/pkg-listn.service
	[[ -f $(SYSTEMD_DIR)/pkg-listn.path ]]     && rm $(SYSTEMD_DIR)/pkg-listn.path
	[[ -d $(DESTDIR)$(PREFIX)/share/$(NAME) ]] && rm -rf $(DESTDIR)$(PREFIX)/share/$(NAME)
