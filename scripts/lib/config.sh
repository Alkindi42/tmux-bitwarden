#!/usr/bin/env bash
# shellcheck disable=SC2034

readonly BW_CONFIG_PREFIX="@bw"

# UI configuration
readonly BW_CONFIG_KEY_UI="ui"
readonly BW_CONFIG_KEY_SPLIT_SIZE="ui-split-size"
readonly BW_CONFIG_KEY_POPUP_WIDTH="ui-popup-width"
readonly BW_CONFIG_KEY_POPUP_HEIGHT="ui-popup-height"

readonly BW_CONFIG_DEFAULT_UI="popup"
readonly BW_CONFIG_DEFAULT_SPLIT_SIZE="20"
readonly BW_CONFIG_DEFAULT_POPUP_WIDTH="80%"
readonly BW_CONFIG_DEFAULT_POPUP_HEIGHT="80%"

# Key binding configuration
readonly BW_CONFIG_KEY_KEY="key"
readonly BW_CONFIG_DEFAULT_KEY="b"

# Cache configuration
readonly BW_CONFIG_KEY_CACHE="cache"
readonly BW_CONFIG_KEY_CACHE_TTL="cache-ttl"
readonly BW_CONFIG_KEY_CACHE_FILE="cache-file"

readonly BW_CONFIG_DEFAULT_CACHE="true"
readonly BW_CONFIG_DEFAULT_CACHE_TTL=86400
readonly BW_CONFIG_DEFAULT_CACHE_FILE="${HOME}/.cache/tmux-bitwarden/items.json"

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
