#!/bin/bash

_name=pkg-listn
: "${XDG_CACHE_HOME:=$HOME/.cache}"
: "${XDG_CONFIG_HOME:=$HOME/.config}"

_script_dir=$(dirname "$(realpath "$0")")
dir_tmp="/tmp/$_name"
dir_cache="$XDG_CACHE_HOME/$_name"

file_home="$_script_dir/arch-pkg" # config file
file_cache="$dir_cache/arch-pkg"  # sorted cache file

# temporary helper files
# dir_tmp is removed when script terminates
file_lock="$dir_tmp/lock"               # lock file is destroyed from terminal
file_tmp="$dir_tmp/tmp"                 # sorted copy of config
file_remove="$dir_tmp/remove"           # list of pkgs in cache, not in config (remove)
file_install="$dir_tmp/install"         # list of pkgs in config, not in cache (install)
file_aur="$dir_tmp/aur"                 # install filtered with only AUR packages
file_official="$dir_tmp/official"       # install filtered with only official packages
file_list_remove="$dir_tmp/list_remove" # succesfully removed, and/or failed installed packages
file_commands="$dir_tmp/commands"       # commands executed in the terminal
file_check="$dir_tmp/check"             # file install+removed concatenated
file_msg="$dir_tmp/msg"                 # content of this file will be echoed in created terminal

[[ -f $file_lock ]] && {
  echo "[ERROR] pkg-parsing in progress, lockfile exists"
  exit 1
}

# trap 'rm -rf "$dir_tmp"/*' EXIT INT HUP

main() {

  mkdir -p "$dir_tmp" "$dir_cache"
  touch "$file_lock"
  touch "$file_cache"

  rm -f "$file_commands"

  while read -rs line ; do
    [[ ! $line || $line =~ ^\s*# ]] && continue
    pkgs+=(${line})
  done < "$file_home" 

  printf '%s\n' "${pkgs[@]}" | sort -u > "$file_tmp"

  entries_unique_to_config | print_uninstalled > "$file_install"

  file_is_not_empty "$file_cache" \
    && entries_unique_to_cache | sed -r 's/^\s*//g' > "$file_remove"

  file_is_not_empty "$file_install" && {
    filter_official | sed -r 's/^\s*//g' > "$file_official"
    filter_aur      | sed -r 's/^\s*//g' > "$file_aur"

    file_is_not_empty "$file_official" && {
      echo "sudo pacman --needed -S - < '$file_official'"
    } >> "$file_commands"

    file_is_not_empty "$file_aur" && {
      echo "yay --needed -S - < '$file_aur'"
    } >> "$file_commands"
  }

  file_is_not_empty "$file_remove" && {
    echo "sudo pacman -Rsu - < '$file_remove'"
  } >> "$file_commands"

  [[ -f "$file_commands" ]] && {
    [[ -f $file_msg ]] \
      && echo "cat '$file_msg' \; '${cmd[@]}'" >> "$file_commands"
    chmod +x "$file_commands"
    cat "$file_commands"
    cid=$(i3term --no-exec --verbose -- bash "$file_commands")

    while i3get -n "$cid" >/dev/null; do sleep 2 ; done

  }

  update_cache_file
}

update_cache_file() {

  file_is_not_empty "$file_install" && {
    while read -rs line ; do
      pacman -Qqs "^${line}\$" >/dev/null || echo "$line" >> "$file_list_remove"
    done < "$file_install"
  }

  file_is_not_empty "$file_remove" && {
    while read -rs line ; do
      pacman -Qqs "^${line}\$" >/dev/null && echo "$line" >> "$file_tmp"
    done < "$file_remove"
  }


  if file_is_not_empty "$file_list_remove" ; then
    comm -23 "$file_tmp" "$file_list_remove"
  else
    cat "$file_tmp"
  fi | sort -u > "$file_cache"
}

print_uninstalled() {
  comm -13 <(pacman -Qq | sort) -
}

entries_unique_to_cache() {
  comm -23 "$file_cache" "$file_tmp"
}

entries_unique_to_config() {
  comm -13 "$file_cache" "$file_tmp"
}

filter_official() {
  comm  -12 <(pacman -Slq | sort) "$file_install"
}

filter_aur() {
  comm -3 "$file_official" "$file_install"
}

file_is_not_empty() {
  local file=$1
  [[ -f $file ]] && grep -q '[^[:space:]]' "$file"
}

main "$@"
