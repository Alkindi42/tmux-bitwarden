#!/usr/bin/env bash
# shellcheck disable=SC2034

readonly BW_STATUS_LOCKED="locked"
readonly BW_STATUS_UNLOCKED="unlocked"
readonly BW_STATUS_UNAUTHENTICATED="unauthenticated"

tmux_bw_run_with_auth() {
  local fn="$1"
  local result
  local session
  local ret

  session="$(tmux_bw_get_session)" || return 1
  [[ -n "$session" ]] || return 1

  shift

  result="$("$fn" "$session" "$@" 2>&1)"
  ret=$?

  if ((ret != 0)) && {
    [[ "$result" == *"Vault is locked."* ]] ||
      [[ "$result" == *"You are not logged in."* ]]
  }; then
    printf "Unlocking vault...\n" >&2
    tmux_bw_authenticate || return 1

    session="$(tmux_bw_get_session)" || return 1
    [[ -n "$session" ]] || return 1

    printf "Fetching vault...\n" >&2
    result="$("$fn" "$session" "$@")"
    ret=$?
  fi

  printf '%s\n' "$result"
  return "$ret"
}

tmux_bw_authenticate() {
  case "$(tmux_bw_get_status)" in
  "$BW_STATUS_UNAUTHENTICATED")
    tmux_display_message "You are not logged in. Please run 'bw login'."
    return 1
    ;;
  "$BW_STATUS_LOCKED")
    tmux_bw_unlock_and_store_session || return 1
    ;;
  "$BW_STATUS_UNLOCKED") ;;
  *)
    tmux_display_message "Unknown Bitwarden status."
    return 1
    ;;
  esac
}

tmux_bw_has_session() {
  local session
  session="$(tmux_bw_get_session)"
  [[ -n "$session" ]]
}

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

  [[ -n "$new_session" ]] || {
    tmux_display_message "Failed to unlock vault. Please try again."
    return 1
  }

  tmux_bw_set_config "session" "$new_session"
}
