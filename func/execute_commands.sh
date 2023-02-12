#!/bin/bash

execute_commands() {

cat << EOB >> "$dir_tmp/cmd"
#!/usr/bin/env bash
trap 'rm $dir_tmp/lock' EXIT INT HUP
sleep .4
cat '$dir_tmp/msg'
printf '%s\n' "" "Press any key except ESC to continue." ""
read -rsn1 key 
[[ \$key = $'\u1b' ]] && {
  read -rsn2 -t 0.001 key
  [[ \$key ]] || exit
}
EOB

  local command

  echo "The commands below will get executed:" >> "$dir_tmp/msg"

  for command in "${_commands_to_execute[@]}"; do
    echo "  $command" >> "$dir_tmp/msg"
    printf '%s\n' \
      'echo -e "\n\n"' \
      "echo $command"  \
      "$command" >> "$dir_tmp/cmd"
  done

  chmod +x "$dir_tmp/cmd"

  if [[ -t 0 ]] 
    then "$dir_tmp/cmd"
    else "${_cmd_terminal[@]}" "$dir_tmp/cmd"
  fi

  while [[ -f $dir_tmp/lock ]]; do sleep .5 ; done
  touch "$dir_tmp/lock"
}
