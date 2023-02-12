#!/bin/bash

create_lists() {
  "${_cmd_list_local[@]}" | sort > "$dir_tmp/installed"

  comm -13 "$dir_tmp/installed" "$dir_tmp/sorted" > "$dir_tmp/install"
  # package entries that are unique to the cache file
  # and is installed will get marked for removal
  comm -23 "$dir_cache/packages-cache" "$dir_tmp/sorted"  \
    | comm -12 - "$dir_tmp/installed" > "$dir_tmp/remove"

  [[ -s $dir_tmp/install ||  -s "$dir_tmp/remove" ]] \
    && "${_cmd_list_remote[@]}" | sort > "$dir_tmp/remote"

  [[ -s $dir_tmp/install ]]  \
    && comm -12 "$dir_tmp/install" "$dir_tmp/remote" \
     | tee "$dir_tmp/install-remote"                 \
     | comm -13 - "$dir_tmp/install" > "$dir_tmp/foreign"

  [[ -s $dir_tmp/foreign ]] \
    && comm -12 "$dir_tmp/foreign" <("${_cmd_list_foreign[@]}" | sort) \
     | tee "$dir_tmp/install-foreign"                                  \
     | comm -13 - "$dir_tmp/foreign" > "$dir_tmp/notavailable"

  [[ -s $dir_tmp/remove ]] \
    && comm -12 "$dir_tmp"/remove "$dir_tmp/remote" \
     | tee "$dir_tmp/remove-remote"                 \
     | comm -13 - "$dir_tmp/remove" > "$dir_tmp/remove-foreign"
}
