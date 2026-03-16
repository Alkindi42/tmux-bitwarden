#!/usr/bin/env bash

# Check if binary exist
is_binary_exist() {
  local binary=$1

  command -v "$binary" &>/dev/null
  return $?
}

# Display tmux message in status bar
tmux_display_message() {
  local message="$1"
  tmux display-message "tmux-bitwarden: $message"
}

tmux_get_current_pane() {
  tmux display-message -p "#{pane_id}"
}
