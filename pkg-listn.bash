#!/bin/bash

_name=pkg-listn

printf -v _about '%s - version %s\nupdated by budRich %s' \
  "$_name" "0.0.1" "23/2/2"

: "${XDG_CACHE_HOME:=$HOME/.cache}"
: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${XDG_RUNTIME_DIR:=/tmp}"

dir_cache="$XDG_CACHE_HOME/$_name"
dir_config="$XDG_CONFIG_HOME/$_name"
dir_tmp="$XDG_RUNTIME_DIR/$_name"

file_packages="$dir_config/packages"    # user defined pkg list
file_settings="$dir_config/settings"    # config file
file_sorted="$dir_tmp/sorted"           # sorted copy of pkg list
file_cache="$dir_cache/packages-cache"  # sorted cache file
file_lock="$dir_tmp/lock"

set -E
trap '(($? == 98)) && exit 98' ERR

ERX() { >&2 echo  "[ERROR] $*" ; exit 98 ;}
ERR() { >&2 echo  "[WARNING] $*"  ;}
ERM() { >&2 echo  "$*"  ;}

[[ -f $file_lock ]] \
  && ERX "pkg-parsing in progress, lockfile exists"

trap 'rm "$dir_tmp"/*' EXIT INT HUP
mkdir -p "$dir_tmp" "$dir_cache"
touch "$file_lock" "$file_cache"

### parse config 
# DATA_DIR is replaced during installation
# defaults to: /usr/share/pkg-listn
[[ -d DATA_DIR ]] \
  && dir_data='DATA_DIR' \
  || dir_data="$(dirname "$(realpath "$0")")/conf"

[[ -d $dir_config ]] || {
  [[ -d $dir_data ]] || ERX "datadir not found"
  mkdir -p "$dir_config"
  cp -r "$dir_data"/* "$dir_config"
}

[[ $* =~ -v(\s|$) ]] && ERM "$_about" && exit

[[ -f "$file_settings" ]] && {
  re='^\s*([^#][^=[:space:]]+)\s*=\s*(.+)$'
  while read -rs line ; do
    [[ $line =~ $re ]] || continue
    key="${BASH_REMATCH[1]}" val="${BASH_REMATCH[2]}"
    case "$key" in
      pacman_install ) cmd_pacman_install=$val ;;
      pacman_remove  ) cmd_pacman_remove=$val  ;;
      aur_install    ) cmd_aur_install=$val    ;;
      aur_list       ) cmd_aur_list=$val       ;;
      i3term_options ) i3term_options=$val     ;;
    esac
  done < "$file_settings"
  unset -v key val re line
}

: "${cmd_pacman_install:="sudo pacman -S"}"
: "${cmd_pacman_remove:="sudo pacman -R"}"
: "${cmd_aur_install:="yay -S"}"
: "${cmd_aur_list:="yay --aur -Slq"}"
: "${i3term_options:="--instance pkg-listn"}"

IFS=" " read -r -a _cmd_aur_list   <<< "$cmd_aur_list"
IFS=" " read -r -a _i3term_options <<< "$i3term_options"

### parse pkg list
while read -rs line ; do
  [[ ! $line || $line =~ ^\s*# ]] && continue
  echo "$line"
done < "$file_packages" \
  | sed -r 's/\s+/\n/g' | sort -u > "$file_sorted"

### compare lists
comm -13 "$file_cache" "$file_sorted" \
   | comm -23 - <(pacman -Qq | sort)   > "$dir_tmp"/install
comm -23 "$file_cache" "$file_sorted"  > "$dir_tmp"/remove

[[ -s "$dir_tmp"/install ]]  \
  && comm -12 "$dir_tmp"/install <(pacman -Slq | sort) \
   | tee "$dir_tmp"/official \
   | comm -13 - "$dir_tmp"/install > "$dir_tmp"/foreign

[[ -s "$dir_tmp"/foreign ]] \
  && comm -12 "$dir_tmp"/foreign <("${_cmd_aur_list[@]}" | sort) \
   | tee "$dir_tmp"/aur     \
   | comm -13 - "$dir_tmp"/foreign > "$dir_tmp"/notavailable

### set actions
for action in notavailable remove official aur ; do
  [[ -s "$dir_tmp/$action" ]] || continue
  mapfile -t line_of_pkgs < "$dir_tmp/$action"
  case "$action" in
    
    remove   ) commands+=("$cmd_pacman_remove ${line_of_pkgs[*]}") ;;
    official ) commands+=("$cmd_pacman_install ${line_of_pkgs[*]}") ;;
    aur      ) commands+=("$cmd_aur_install ${line_of_pkgs[*]}") ;;
    
    notavailable ) printf '%s\n' \
      "[WARNING]: The following packages was not found in any repositories:" \
      "  ${line_of_pkgs[*]}" "" >> "$dir_tmp/msg"
    ;;
  esac
done

### launch commands
[[ ${commands[*]} ]] && {
  echo "sleep .4" >> "$dir_tmp/cmd"
  echo "cat '$dir_tmp/msg'" >> "$dir_tmp/cmd"
  echo "The commands below will be executed:" >> "$dir_tmp/msg"
  for command in "${commands[@]}"; do
    echo "  $command" >> "$dir_tmp/msg"
    echo "$command"   >> "$dir_tmp/cmd"
  done
  echo >> "$dir_tmp/msg"

  chmod +x "$dir_tmp/cmd"
  cid=$(i3term "${_i3term_options[@]}" -- "$dir_tmp/cmd")
  while i3get -n "$cid" >/dev/null; do sleep 2 ; done
}

### update cache
{
  cat "$dir_tmp/sorted"
  [[ -s "$dir_tmp/remove" ]] && cat "$dir_tmp/remove"
} | sort -u | comm -12 - <(pacman -Qq | sort) > "$file_cache"
