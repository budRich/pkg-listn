#!/bin/bash

install_config() {
  local dir_data
  [[ -d $dir_config ]] || {
    # DATA_DIR is replaced during installation
    # defaults to: /usr/share/pkg-listn
    [[ -d DATA_DIR ]] \
      && dir_data='DATA_DIR' \
      || dir_data="$(dirname "$(realpath "$0")")/data/config"
    [[ -d $dir_data ]] || ERX "'$dir_data' not found."
    mkdir -p "$dir_config"
    cp -r "$dir_data"/* "$dir_config"
  }
}
