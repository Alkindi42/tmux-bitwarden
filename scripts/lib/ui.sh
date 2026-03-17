#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CURRENT_DIR
PLUGIN_SCRIPTS_DIR="$(cd "$CURRENT_DIR/.." && pwd)"
readonly PLUGIN_SCRIPTS_DIR

# shellcheck source=scripts/lib/config.sh
source "$CURRENT_DIR/config.sh"
# shellcheck source=scripts/lib/common.sh
source "$CURRENT_DIR/common.sh"

tmux_bw_open_ui() {
  local ui_mode
  local target_pane_id

  target_pane_id="$(tmux_get_current_pane)"
  ui_mode="$(tmux_bw_get_config_or_default "$BW_CONFIG_KEY_UI" "$BW_CONFIG_DEFAULT_UI")"

  case "$ui_mode" in
  popup)
    tmux_bw_open_popup "$target_pane_id" || return 1
    ;;
  split)
    tmux_bw_open_split "$target_pane_id" || return 1
    ;;
  *)
    tmux_display_message "Unknown UI mode: $ui_mode"
    return 0
    ;;
  esac
}

tmux_bw_open_split() {
  local size
  local target_pane_id="$1"

  size="$(tmux_bw_get_config_or_default "$BW_CONFIG_KEY_SPLIT_SIZE" "$BW_CONFIG_DEFAULT_SPLIT_SIZE")"

  tmux split-window -l "$size" "$PLUGIN_SCRIPTS_DIR/main.sh ${target_pane_id}"
}

tmux_bw_open_popup() {
  local width
  local height
  local target_pane_id="$1"

  width="$(tmux_bw_get_config_or_default "$BW_CONFIG_KEY_POPUP_WIDTH" "$BW_CONFIG_DEFAULT_POPUP_WIDTH")"
  height="$(tmux_bw_get_config_or_default "$BW_CONFIG_KEY_POPUP_HEIGHT" "$BW_CONFIG_DEFAULT_POPUP_HEIGHT")"

  tmux display-popup \
    -E \
    -d '#{pane_current_path}' \
    -w "$width" \
    -h "$height" \
    "$PLUGIN_SCRIPTS_DIR/main.sh ${target_pane_id}"
}

tmux_bw_open_ui
