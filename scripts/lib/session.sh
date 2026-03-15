#!/usr/bin/env bash

readonly BW_STATUS_LOCKED="locked"
readonly BW_STATUS_UNLOCKED="unlocked"
readonly BW_STATUS_UNAUTHENTICATED="unauthenticated"

# Get vault status via the Bitwarden CLI
bw_get_status() {
  local session="$1"
  local bw_status

  if [[ -n "$session" ]]; then
    bw_status="$(bw status --session "$session" | jq -r '.status')" || return 1
  else
    bw_status="$(bw status | jq -r '.status')" || return 1
  fi

  printf '%s\n' "$bw_status"
}

# Unlock vault via the Bitwarden CLI
bw_unlock() {
  local session_id

  session_id="$(bw unlock --raw)" || return 1
  printf '%s\n' "$session_id"
}

tmux_bw_get_session() {
  local tmux_session
  tmux_session="$(tmux_bw_get_config "session")"

  if [[ -n "${BW_SESSION:-}" ]]; then
    printf '%s\n' "$BW_SESSION"
  elif [[ -n "$tmux_session" ]]; then
    printf '%s\n' "$tmux_session"
  fi
}

tmux_bw_get_status() {
  local session

  session="$(tmux_bw_get_session)"
  bw_get_status "$session"
}

tmux_bw_unlock_and_store_session() {
  local new_session

  new_session="$(bw_unlock)" || {
    tmux_display_message "Failed to unlock vault. Please try again."
    return 1
  }
  tmux_bw_set_config "session" "$new_session"
}
