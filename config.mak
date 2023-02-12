NAME         := pkg-listn
CREATED      := 2023-02-02
UPDATED      := 2023-02-12
VERSION      := 0.2.0
LICENSE      := Unlicense
DESCRIPTION  := Manage Linux packages with textfiles
AUTHOR       := budRich
CONTACT      := https://github.com/budRich/pkg-listn
ORGANISATION := budlabs
USAGE        := $(NAME) [OPTIONS]

MONOLITH     := _$(NAME)
SYSTEMD_DIR  := $(DESTDIR)$(PREFIX)/lib/systemd/user

.PHONY: install-dev uninstall-dev install uninstall

install-dev: $(BASE) $(NAME)
	ln -s $(realpath $(NAME)) $(PREFIX)/bin/$(NAME)
	ln -fs $(realpath $(wildcard data/systemd/*)) -t $(HOME)/.config/systemd/user/
	
uninstall-dev:
	rm $(PREFIX)/bin/$(NAME) $(wildcard $(HOME)/.config/systemd/user/$(NAME)*)

install: $(CACHE_DIR)/$(NAME).m4
	install -Dm755 $(CACHE_DIR)/$(NAME).m4 $(DESTDIR)$(PREFIX)/bin/$(NAME)
	install -Dm644 data/config/packages.d/*  -t $(DESTDIR)$(PREFIX)/share/$(NAME)/packages.d
	install -Dm644 data/config/packages      -t $(DESTDIR)$(PREFIX)/share/$(NAME)
	install -Dm644 data/config/settings      -t $(DESTDIR)$(PREFIX)/share/$(NAME)
	[[ -e $(PREFIX)/lib/systemd/ ]] \
		&& install -Dm644 data/systemd/* -t $(SYSTEMD_DIR)

$(CACHE_DIR)/$(NAME).m4: $(MONOLITH)
	m4 -DDATA_DIR=$(PREFIX)/share/$(NAME) $< >$@

uninstall:
	[[ -f $(DESTDIR)$(PREFIX)/bin/$(NAME) ]]   && rm $(DESTDIR)$(PREFIX)/bin/$(NAME)
	[[ -f $(SYSTEMD_DIR)/pkg-listn.service ]]  && rm $(SYSTEMD_DIR)/pkg-listn.service
	[[ -f $(SYSTEMD_DIR)/pkg-listn.path ]]     && rm $(SYSTEMD_DIR)/pkg-listn.path
	[[ -d $(DESTDIR)$(PREFIX)/share/$(NAME) ]] && rm -r $(DESTDIR)$(PREFIX)/share/$(NAME)
