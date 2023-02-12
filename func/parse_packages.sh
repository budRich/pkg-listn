#!/bin/bash

parse_packages() {
  {
    [[ -f "$dir_config/packages" ]] && cat "$dir_config/packages"
    packages.d_is_not_empty && cat "$dir_config/packages.d/"*
  } | sed -r 's/(^\s*|\s*$)//g;/^(#|$)/d;s/\s+/\n/g' | sort -u > "$dir_tmp/sorted"
}
