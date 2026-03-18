#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CURRENT_DIR

# shellcheck source=scripts/lib/config.sh
source "$CURRENT_DIR/lib/config.sh"
# shellcheck source=scripts/lib/common.sh
source "$CURRENT_DIR/lib/common.sh"
# shellcheck source=scripts/lib/vault.sh
source "$CURRENT_DIR/lib/vault.sh"
# shellcheck source=scripts/lib/cache.sh
source "$CURRENT_DIR/lib/cache.sh"
# shellcheck source=scripts/lib/session.sh
source "$CURRENT_DIR/lib/session.sh"
# shellcheck source=scripts/lib/actions.sh
source "$CURRENT_DIR/lib/actions.sh"
# shellcheck source=scripts/lib/selector.sh
source "$CURRENT_DIR/lib/selector.sh"

main() {
  local action
  local status
  local item_id
  local selection
  local target_pane_id="$1"

  [[ -n "$target_pane_id" ]] || {
    tmux_display_message "Invalid pane target."
    return 0
  }

  case "$(tmux_bw_get_status)" in
  "$BW_STATUS_UNAUTHENTICATED")
    tmux_display_message "You are not logged in. Please run 'bw login'."
    return 0
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

  if selection="$(tmux_bw_selector)"; then
    status=0
  else
    status=$?
  fi

  case "$status" in
  0) ;;
  "$TMUX_BW_SELECTOR_CANCEL")
    return 0
    ;;
  *)
    tmux_display_message "Selector failed."
    return 1
    ;;
  esac

  {
    IFS= read -r action
    IFS= read -r item_id
  } <<<"$selection"

  [[ -n "$action" && -n "$item_id" ]] || {
    tmux_display_message "Selector returned invalid data."
    return 1
  }

  case "$action" in
  "$BW_PASTE_PASSWORD")
    tmux_bw_paste_password "$item_id" "$target_pane_id" || {
      tmux_display_message "Failed to paste password."
      return 0
    }
    ;;
  "$BW_COPY_PASSWORD")
    tmux_bw_copy_password "$item_id" || {
      tmux_display_message "Failed to copy password to the clipboard."
      return 0
    }
    tmux_display_message "Password copied to the clipboard."
    ;;
  "$BW_PASTE_USERNAME")
    tmux_bw_paste_username "$item_id" "$target_pane_id" || {
      tmux_display_message "Failed to paste username."
      return 0
    }
    ;;
  "$BW_COPY_USERNAME")
    tmux_bw_copy_username "$item_id" || {
      tmux_display_message "Failed to copy username to the clipboard."
      return 0
    }
    tmux_display_message "Username copied to the clipboard."
    ;;
  "$BW_PASTE_TOTP")
    tmux_bw_paste_totp "$item_id" "$target_pane_id" || {
      tmux_display_message "Failed to paste TOTP."
      return 0
    }
    ;;
  "$BW_COPY_TOTP")
    tmux_bw_copy_totp "$item_id" || {
      tmux_display_message "Failed to copy TOTP to the clipboard."
      return 0
    }
    tmux_display_message "TOTP copied to the clipboard."
    ;;
  *)
    tmux_display_message "Unknown action."
    return 0
    ;;
  esac
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
