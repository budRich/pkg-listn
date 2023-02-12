#!/bin/bash

parse_config() {

  local \
    key val re line \
    cmd_terminal cmd_list_local cmd_list_remote cmd_list_foreign 

  [[ -f $dir_config/settings ]] && {
    re='^\s*([^#][^=[:space:]]+)\s*=\s*(.+)$'
    while read -rs line ; do
      [[ $line =~ $re ]] || continue
      key="${BASH_REMATCH[1]}" val="${BASH_REMATCH[2]}"
      case "$key" in
        install_foreign_command ) _cmd_install_foreign=$val ;;
        install_command         ) _cmd_install=$val         ;;
        remove_foreign_command  ) _cmd_remove_foreign=$val  ;;
        remove_command          ) _cmd_remove=$val          ;;
        list_local              ) cmd_list_local=$val      ;;
        list_remote             ) cmd_list_remote=$val     ;;
        list_foreign            ) cmd_list_foreign=$val    ;;
        terminal_command        ) cmd_terminal=$val        ;;
      esac
    done < "$dir_config/settings"
  }

  : "${_cmd_install:=sudo pacman -S}"
  : "${_cmd_remove:=sudo pacman -R}"
  : "${_cmd_remove_foreign:=sudo pacman -R}"
  : "${_cmd_install_foreign:=}"
  : "${cmd_list_foreign:=echo}"
  : "${cmd_list_local:=pacman -Qq}"
  : "${cmd_list_remote:=pacman -Slq}"
  : "${cmd_terminal:=xterm -name pkg-listn -e }"

  IFS=" " read -ra _cmd_terminal     <<< "$cmd_terminal"
  IFS=" " read -ra _cmd_list_local   <<< "$cmd_list_local"
  IFS=" " read -ra _cmd_list_remote  <<< "$cmd_list_remote"
  IFS=" " read -ra _cmd_list_foreign <<< "$cmd_list_foreign"

  command -v "${_cmd_list_foreign[0]}" >/dev/null || {
    unset -v '_cmd_list_foreign[@]'
    _cmd_list_foreign[0]="echo"
  }
}
