#!/usr/bin/env bash

readonly BW_COPY_PASSWORD="copy-password"
readonly BW_PASTE_PASSWORD="paste-password"

# Copy text to the clipboard
tmux_bw_copy_to_clipboard() {
  local value="$1"
  local os

  os="$(uname)"

  if [[ "$os" == "Darwin" ]] && is_binary_exist "pbcopy"; then
    printf "%s" "$value" | pbcopy
  elif [[ "$os" == "Linux" ]] && is_binary_exist "wl-copy"; then
    printf "%s" "$value" | wl-copy
  elif [[ "$os" == "Linux" ]] && is_binary_exist "xsel"; then
    printf "%s" "$value" | xsel -b
  elif [[ "$os" == "Linux" ]] && is_binary_exist "xclip"; then
    printf "%s" "$value" | xclip -selection clipboard -i
  else
    return 1
  fi
}

tmux_bw_paste_password() {
  local id="$1"
  local target_pane_id="$2"
  local session
  local password

  session="$(tmux_bw_get_session)"
  password="$(bw_get_item_by_id "$session" "$id" | jq -r '.login.password // empty')" || return 1

  [[ -n "$password" ]] || return 1

  tmux send-keys -l -t "$target_pane_id" -- "$password"
}

tmux_bw_copy_password() {
  local id="$1"
  local session
  local password

  session="$(tmux_bw_get_session)"
  password="$(bw_get_item_by_id "$session" "$id" | jq -r '.login.password // empty')" || return 1

  [[ -n "$password" ]] || return 1

  tmux_bw_copy_to_clipboard "$password"
}
