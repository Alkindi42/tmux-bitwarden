#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
declare -r CURRENT_DIR

# shellcheck source=/dev/null
source "$CURRENT_DIR/lib/common.sh"
source "$CURRENT_DIR/lib/session.sh"
source "$CURRENT_DIR/lib/vault.sh"

get_password() {
  local items=$1
  local key=$2

  password=$(echo "$items" | jq ".\"$key\"")
  echo "${password:1:-1}"
}

main() {
  declare -A TMUX_OPTS=(
    ["@bw-session"]=$(tmux_get_option_or_default "session" "$BW_SESSION")
    ["@bw-copy-to-clipboard"]=$(tmux_get_option_or_default "copy-to-clipboard" "off")
  )

  case "$(tmux_bw_get_status)" in
  "$BW_STATUS_UNAUTHENTICATED")
    tmux_display_message "You are not logged in. Please run 'bw login'."
    return 1
    ;;
  "$BW_STATUS_LOCKED")
    tmux_bw_unlock_and_store_session || return 1
    ;;
  "$BW_STATUS_UNLOCKED")
    ;;
  *)
    tmux_display_message "Unknown Bitwarden status."
    return 1
    ;;
  esac

  items=$(get_bw_items "${TMUX_OPTS[@bw-session]}")

  # Choice element
  key=$(echo "$items" | jq --raw-output '.|keys[]' | fzf --no-multi) || return

  password=$(get_password "$items" "$key")

  if [[ "${TMUX_OPTS[@bw-copy-to-clipboard]}" == "on" ]]; then
    cp_to_clipboard "$password"
  else
    # Send the password in the last pane.
    tmux send-keys -t ! "$password"
  fi
}

main "$@"
