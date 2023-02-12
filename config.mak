NAME         := pkg-listn
CREATED      := 2023-02-02
UPDATED      := 2023-02-12
VERSION      := 0.1.4
LICENSE      := Unlicense
DESCRIPTION  := Manage Linux packages with textfiles
AUTHOR       := budRich
CONTACT      := https://github.com/budRich/pkg-listn
ORGANISATION := budlabs
USAGE        := $(NAME) [OPTIONS]

MONOLITH     := _$(NAME)

.PHONY: manpage
manpage: $(MANPAGE)

MANPAGE      := $(NAME).1

$(MANPAGE): config.mak $(CACHE_DIR)/help_table.txt
	@$(info making $@)
	uppercase_name=$(NAME)
	uppercase_name=$${uppercase_name^^}
	{
		echo "# $$uppercase_name "           \
				 "$(manpage_section) $(UPDATED)" \
				 "$(ORGANISATION) \"User Manuals\""

	  printf '%s\n' '## NAME' \
								  '$(NAME) - $(DESCRIPTION)' \
	                '## OPTIONS'

	  cat $(CACHE_DIR)/help_table.txt

	} | go-md2man > $@


README.md: $(CACHE_DIR)/help_table.txt
	@$(making $@)
	{
	  cat $(CACHE_DIR)/help_table.txt
	} > $@

.PHONY: install-dev uninstall-dev

install-dev: $(BASE) $(NAME)
	ln -s $(realpath $(NAME)) $(PREFIX)/bin/$(NAME)
	
uninstall-dev: $(PREFIX)/bin/$(NAME)
	rm $^
