#!/bin/bash

CLEANUP() {
  rm "$dir_tmp"/*
  ((___t)) && >&2 echo "<<< $___cmd" "$(( (10#${EPOCHREALTIME//[!0-9]} - ___t) / 1000 ))ms" #bashbud
}
