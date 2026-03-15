#!/usr/bin/env bash

# Get bitwarden items
get_bw_items() {
  local session

  session="$(tmux_bw_get_session)"
  filter='map({ (.name|tostring): .login.password })|add'

  if [[ -z "$session" ]]; then
    bw list items | jq -r "$filter"
  else
    bw list items --session "$session" | jq -r "$filter"
  fi
}
