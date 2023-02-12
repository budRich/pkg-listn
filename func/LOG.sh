#!/bin/bash #bashbud

[[ $BASHBUD_LOG ]] && {
  [[ -f $BASHBUD_LOG ]] || mkdir -p "${BASHBUD_LOG%/*}"
  exec 3>&2
  __stderr=3
  exec 2>> "$BASHBUD_LOG"
}

ERT() { >&3 echo  "$*"  ;}
