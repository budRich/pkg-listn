#!/bin/bash

update_cache_file() {
  {
    cat "$dir_tmp/sorted"
    [[ -s $dir_tmp/remove ]] && cat "$dir_tmp/remove"
  } | sort -u | comm -12 - <("${_cmd_list_local[@]}" | sort) \
    > "$dir_cache/packages-cache"
}
