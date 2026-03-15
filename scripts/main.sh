#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
declare -r CURRENT_DIR

# shellcheck source=/dev/null
source "$CURRENT_DIR/lib/config.sh"
source "$CURRENT_DIR/lib/common.sh"
source "$CURRENT_DIR/lib/actions.sh"
source "$CURRENT_DIR/lib/session.sh"
source "$CURRENT_DIR/lib/selector.sh"
source "$CURRENT_DIR/lib/vault.sh"

main() {
  local item_id
  local target_pane_id="$1"

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

  item_id="$(tmux_bw_selector)" || return 0

  tmux_bw_action "$item_id" "$target_pane_id" || {
    tmux_display_message "Failed to inject secret."
    return 1
  }
}

main "$@"
