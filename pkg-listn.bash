#!/bin/bash

_name=pkg-listn

printf -v _about '%s - version %s\nupdated by budRich %s' \
  "$_name" "0.1" "23/2/9"

: "${XDG_CACHE_HOME:=$HOME/.cache}"
: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${XDG_RUNTIME_DIR:=/tmp}"

dir_cache="$XDG_CACHE_HOME/$_name"
dir_config="$XDG_CONFIG_HOME/$_name"
dir_tmp="$XDG_RUNTIME_DIR/$_name"

ERX() { >&2 echo  "[ERROR] $*" ; exit 1 ;}
ERR() { >&2 echo  "[WARNING] $*"  ;}
ERM() { >&2 echo  "$*"  ;}

[[ -f $dir_tmp/lock ]] \
  && ERX "pkg-parsing in progress, lockfile exists"

trap 'rm "$dir_tmp"/*' EXIT INT HUP
mkdir -p "$dir_tmp" "$dir_cache"
touch "$dir_tmp/lock" "$dir_cache/pakages-cache"

### install config
[[ -d $dir_config ]] || {
  # DATA_DIR is replaced during installation
  # defaults to: /usr/share/pkg-listn
  [[ -d DATA_DIR ]] \
    && dir_data='DATA_DIR' \
    || dir_data="$(dirname "$(realpath "$0")")/conf"
  [[ -d $dir_data ]] || ERX "datadir not found"
  mkdir -p "$dir_config"
  cp -r "$dir_data"/* "$dir_config"
}

### commandline options
[[ $* =~ -v(\s|$) ]] && ERM "$_about" && exit

### parse config
[[ -f "$dir_config/settings" ]] && {
  re='^\s*([^#][^=[:space:]]+)\s*=\s*(.+)$'
  while read -rs line ; do
    [[ $line =~ $re ]] || continue
    key="${BASH_REMATCH[1]}" val="${BASH_REMATCH[2]}"
    case "$key" in
      terminal_command        ) cmd_terminal=$val        ;;
      install_foreign_command ) cmd_install_foreign=$val ;;
      install_command         ) cmd_install=$val         ;;
      remove_foreign_command  ) cmd_remove_foreign=$val  ;;
      remove_command          ) cmd_remove=$val          ;;
      list_local              ) cmd_list_local=$val      ;;
      list_remote             ) cmd_list_remote=$val     ;;
      list_foreign            ) cmd_list_foreign=$val    ;;
    esac
  done < "$dir_config/settings"
  unset -v key val re line
}

: "${cmd_install:=sudo pacman -S}"
: "${cmd_remove:=sudo pacman -R}"
: "${cmd_remove_foreign:=sudo pacman -R}"
: "${cmd_install_foreign:=}"
: "${cmd_list_foreign:=echo}"
: "${cmd_list_local:=pacman -Qq}"
: "${cmd_list_remote:=pacman -Slq}"
: "${cmd_terminal:=xterm -name pkg-listn -e }"

IFS=" " read -r -a _cmd_terminal     <<< "$cmd_terminal"
IFS=" " read -r -a _cmd_list_local   <<< "$cmd_list_local"
IFS=" " read -r -a _cmd_list_remote  <<< "$cmd_list_remote"
IFS=" " read -r -a _cmd_list_foreign <<< "$cmd_list_foreign"

command -v "${_cmd_list_foreign[0]}" >/dev/null || {
  unset -v '_cmd_list_foreign[@]'
  _cmd_list_foreign[0]="echo"
}

### create package list (sorted one package/line)
sed -r 's/(^\s*|\s*$)//g;/^(#|$)/d;s/\s+/\n/g' "$dir_config/packages" \
   | sort -u > "$dir_tmp/sorted"

### compare lists
comm -13 <("${_cmd_list_local[@]}" | sort) "$dir_tmp/sorted" \
  > "$dir_tmp"/install
comm -23 "$dir_cache/pakages-cache" "$dir_tmp/sorted" \
  > "$dir_tmp"/remove

[[ -s "$dir_tmp"/install ||  -s "$dir_tmp"/remove ]] \
  && "${_cmd_list_remote[@]}" | sort > "$dir_tmp"/remote

[[ -s "$dir_tmp"/install ]]  \
  && comm -12 "$dir_tmp"/install "$dir_tmp"/remote \
   | tee "$dir_tmp"/install-remote \
   | comm -13 - "$dir_tmp"/install > "$dir_tmp"/foreign

[[ -s "$dir_tmp"/foreign ]] \
  && comm -12 "$dir_tmp"/foreign <("${_cmd_list_foreign[@]}" | sort) \
   | tee "$dir_tmp"/install-foreign     \
   | comm -13 - "$dir_tmp"/foreign > "$dir_tmp"/notavailable

[[ -s "$dir_tmp"/remove ]] \
  && comm -12 "$dir_tmp"/remove "$dir_tmp"/remote \
   | tee "$dir_tmp"/remove-remote                 \
   | comm -13 - "$dir_tmp"/remove > "$dir_tmp"/remove-foreign

### set actions
for action in notavailable remove-remote remove-foreign install-remote install-foreign ; do
  [[ -s "$dir_tmp/$action" ]] || continue
  mapfile -t pkg_array < "$dir_tmp/$action"
  line_of_pkgs=${pkg_array[*]}
  case "$action" in
    
    remove-remote   ) commands+=("$cmd_remove $line_of_pkgs")          ;;
    remove-foreign  ) commands+=("$cmd_remove_foreign $line_of_pkgs")  ;;
    install-remote  ) commands+=("$cmd_install $line_of_pkgs")         ;;
    install-foreign ) commands+=("$cmd_install_foreign $line_of_pkgs") ;;
    
    notavailable ) printf '%s\n' \
      "[WARNING]: The following packages was not found in any repositories:" \
      "  $line_of_pkgs" "" >> "$dir_tmp/msg"
    ;;
  esac
done

### launch commands
[[ ${commands[*]} ]] && {
  printf '%s\n'                             \
    "#!/bin/sh"                             \
    "trap 'rm $dir_tmp/lock' EXIT INT HUP" \
    "sleep .4"                              \
    "cat '$dir_tmp/msg'" >> "$dir_tmp/cmd"

  echo "The commands below will get executed:" >> "$dir_tmp/msg"

  for command in "${commands[@]}"; do
    echo "  $command" >> "$dir_tmp/msg"
    echo "$command"   >> "$dir_tmp/cmd"
  done

  echo  >> "$dir_tmp/msg"
  chmod +x "$dir_tmp/cmd"

  "${_cmd_terminal[@]}" "$dir_tmp/cmd"
  while [[ -f $dir_tmp/lock ]]; do sleep .5 ; done
  touch "$dir_tmp/lock"
}

### update cache
{
  cat "$dir_tmp/sorted"
  [[ -s "$dir_tmp/remove" ]] && cat "$dir_tmp/remove"
} | sort -u | comm -12 - <("${_cmd_list_local[@]}" | sort) > "$dir_cache/pakages-cache"
