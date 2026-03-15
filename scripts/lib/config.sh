#!/usr/bin/env bash

readonly BW_CONFIG_PREFIX="@bw"

# Config keys
readonly BW_CONFIG_KEY_UI="ui"
readonly BW_CONFIG_KEY_SPLIT_SIZE="split-size"
readonly BW_CONFIG_KEY_POPUP_WIDTH="popup-width"
readonly BW_CONFIG_KEY_POPUP_HEIGHT="popup-height"

# Default values
readonly BW_CONFIG_DEFAULT_UI="popup"
readonly BW_CONFIG_DEFAULT_SPLIT_SIZE="20"
readonly BW_CONFIG_DEFAULT_POPUP_WIDTH="80%"
readonly BW_CONFIG_DEFAULT_POPUP_HEIGHT="80%"

tmux_bw_set_config() {
  local name="$1"
  local value="$2"

  tmux set-option -gq "${BW_CONFIG_PREFIX}-${name}" "${value}"
}

tmux_bw_get_config() {
  local name="$1"

  tmux show-option -gqv "${BW_CONFIG_PREFIX}-$name"
}

# Get config value or fallback to default
tmux_bw_get_config_or_default() {
  local option="$1"
  local default_value="$2"
  local config_value

  config_value="$(tmux_bw_get_config "$option")"

  if [[ -z "$config_value" ]]; then
    printf '%s\n' "$default_value"
  else
    printf '%s\n' "$config_value"
  fi
}
