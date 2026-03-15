#!/usr/bin/env bash

tmux_bw_action() {
  local id="$1"
  local target_pane_id="$2"
  local session
  local password

  session="$(tmux_bw_get_session)"
  password="$(bw_get_item_by_id "$session" "$id" | jq -r ".login.password // empty")" || return 1

  [[ -n "$password" ]] || return 1

  tmux send-keys -l -t "${target_pane_id}" -- "$password"
}
