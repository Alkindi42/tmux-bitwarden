#!/usr/bin/env bash
# shellcheck disable=SC2034

readonly BW_COPY_TOTP="copy-totp"
readonly BW_PASTE_TOTP="paste-totp"
readonly BW_COPY_PASSWORD="copy-password"
readonly BW_PASTE_PASSWORD="paste-password"
readonly BW_PASTE_USERNAME="paste-username"
readonly BW_COPY_USERNAME="copy-username"

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

tmux_bw_get_totp() {
  local id="$1"
  local session
  local value

  session="$(tmux_bw_get_session)" || return 1
  [[ -n "$session" ]] || return 1

  value="$(bw_get_totp "$session" "$id")" || return 1
  [[ -n "$value" ]] || return 1

  printf '%s\n' "$value"
}

tmux_bw_get_value() {
  local id="$1"
  local field="$2"
  local value
  local session

  session="$(tmux_bw_get_session)" || return 1
  [[ -n "$session" ]] || return 1

  value="$(bw_get_item_by_id "$session" "$id" | jq --arg field "$field" -r '.login[$field] // empty')" || return 1
  [[ -n "$value" ]] || return 1

  printf '%s\n' "$value"
}

tmux_bw_paste() {
  local id="$1"
  local target_pane_id="$2"
  local field="$3"

  local value

  value="$(tmux_bw_get_value "$id" "$field")" || return 1
  tmux send-keys -l -t "$target_pane_id" -- "$value"
}

tmux_bw_copy() {
  local id="$1"
  local field="$2"

  local value

  value="$(tmux_bw_get_value "$id" "$field")" || return 1
  tmux_bw_copy_to_clipboard "$value"
}

tmux_bw_paste_password() {
  local id="$1"
  local target_pane_id="$2"
  tmux_bw_paste "$id" "$target_pane_id" "password"
}

tmux_bw_paste_username() {
  local id="$1"
  local target_pane_id="$2"
  tmux_bw_paste "$id" "$target_pane_id" "username"
}

tmux_bw_copy_password() {
  local id="$1"
  tmux_bw_copy "$id" "password"
}

tmux_bw_copy_username() {
  local id="$1"
  tmux_bw_copy "$id" "username"
}

tmux_bw_copy_totp() {
  local id="$1"
  local value

  value="$(tmux_bw_get_totp "$id")" || return 1
  tmux_bw_copy_to_clipboard "$value"
}

tmux_bw_paste_totp() {
  local id="$1"
  local target_pane_id="$2"
  local value

  value="$(tmux_bw_get_totp "$id")" || return 1
  tmux send-keys -l -t "$target_pane_id" -- "$value"
}
