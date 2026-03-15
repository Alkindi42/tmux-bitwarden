#!/usr/bin/env bash

readonly TMUX_PREFIX="@bw"

# Copy text to the clipboard
cp_to_clipboard() {
  if [[ "$(uname)" == "Darwin" ]] && is_binary_exist "pbcopy"; then
    echo -n "$1" | pbcopy
  elif [[ "$(uname)" == "Linux" ]] && is_binary_exist "wl-copy"; then
    echo -n "$1" | wl-copy
  elif [[ "$(uname)" == "Linux" ]] && is_binary_exist "xsel"; then
    echo -n "$1" | xsel -b
  elif [[ "$(uname)" == "Linux" ]] && is_binary_exist "xclip"; then
    echo -n "$1" | xclip -i
  else
    return 1
  fi
}

# Check if binary exist
is_binary_exist() {
  local binary=$1

  command -v "$binary" &>/dev/null
  return $?
}

tmux_set_option() {
  local name="$1"
  local value="$2"

  tmux set-option -gq "${TMUX_PREFIX}-${name}" "${value}"
}

tmux_get_option() {
  local name="$1"

  tmux show-option -gqv "${TMUX_PREFIX}-$name"
}

# Get tmux option
tmux_get_option_or_default() {
  local option="$1"
  local default_value="$2"
  local option_value

  option_value="$(tmux_get_option "$option")"

  if [[ -z "$option_value" ]]; then
    echo "$default_value"
  else
    echo "$option_value"
  fi
}

# Display tmux message in status bar
tmux_display_message() {
  local message="$1"
  tmux display-message "tmux-bitwarden: $message"
}
