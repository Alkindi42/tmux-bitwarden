CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CURRENT_DIR

# shellcheck source=/dev/null
source "$CURRENT_DIR/lib/config.sh"
source "$CURRENT_DIR/lib/common.sh"
source "$CURRENT_DIR/lib/vault.sh"
source "$CURRENT_DIR/lib/cache.sh"
source "$CURRENT_DIR/lib/session.sh"
source "$CURRENT_DIR/lib/actions.sh"
source "$CURRENT_DIR/lib/selector.sh"

main() {
  local action
  local item_id
  local selection
  local target_pane_id="$1"

  [[ -n "$target_pane_id" ]] || {
    tmux_display_message "Invalid pane target."
    return 1
  }

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

  selection="$(tmux_bw_selector)" || return 0
  action="$(printf '%s\n' "$selection" | sed -n '1p')"
  item_id="$(printf '%s\n' "$selection" | sed -n '2p')"

  case "$action" in
  "$BW_PASTE_PASSWORD")
    tmux_bw_paste_password "$item_id" "$target_pane_id" || {
      tmux_display_message "Failed to paste password."
      return 1
    }
    ;;
  "$BW_COPY_PASSWORD")
    tmux_bw_copy_password "$item_id" || {
      tmux_display_message "Failed to copy password to the clipboard."
      return 1
    }
    tmux_display_message "Password copied to the clipboard."
    ;;
  "$BW_PASTE_USERNAME")
    tmux_bw_paste_username "$item_id" "$target_pane_id" || {
      tmux_display_message "Failed to paste username."
      return 1
    }
    ;;
  "$BW_COPY_USERNAME")
    tmux_bw_copy_username "$item_id" || {
      tmux_display_message "Failed to copy username to the clipboard."
      return 1
    }
    tmux_display_message "Username copied to the clipboard."
    ;;
  *)
    tmux_display_message "Unknown action."
    return 1
    ;;
  esac

}

main "$@"
