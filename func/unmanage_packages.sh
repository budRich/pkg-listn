#!/bin/bash

unmanage_packages() {
  mkdir -p "$XDG_RUNTIME_DIR/pkg-listn"

  tmp_packages="$XDG_RUNTIME_DIR/pkg-listn/tmp-pkg-unmanage"
  tmp_cache="$XDG_RUNTIME_DIR/pkg-listn/tmp-cache-unmanage"

  cp -f "$dir_config/packages" "$tmp_packages"
  cp -f "$dir_cache/packages-cache" "$tmp_cache"

  for pkg in "$@"; do
    sed -i -r '/^\s*'"$pkg"'\s*$/d' "$tmp_cache"
    sed -i -r '/^\s*'"$pkg"'\s*$/d;s/'"$pkg"'//g' "$tmp_packages"
  done

  mv -f "$tmp_cache" "$dir_cache/packages-cache"
  mv -f "$tmp_packages" "$dir_config/packages"
}
