#!/bin/bash

set_commands_to_execute() {

  local action line_of_pkgs
  declare -a pkg_array

  for action in notavailable remove-remote remove-foreign install-remote install-foreign ; do
    [[ -s $dir_tmp/$action ]] || continue
    mapfile -t pkg_array < "$dir_tmp/$action"
    line_of_pkgs=${pkg_array[*]}
    case "$action" in
      
      remove-remote   ) _commands_to_execute+=("$_cmd_remove $line_of_pkgs")          ;;
      remove-foreign  ) _commands_to_execute+=("$_cmd_remove_foreign $line_of_pkgs")  ;;
      install-remote  ) _commands_to_execute+=("$_cmd_install $line_of_pkgs")         ;;
      install-foreign ) _commands_to_execute+=("$_cmd_install_foreign $line_of_pkgs") ;;
      
      notavailable ) printf '%s\n' \
        "[WARNING]: The following packages was not found in any repositories:" \
        "  $line_of_pkgs" "" >> "$dir_tmp/msg"
      ;;
    esac
  done
}
