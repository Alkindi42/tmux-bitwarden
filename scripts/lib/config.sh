#!/usr/bin/env bash

readonly TMUX_PREFIX="@bw"

tmux_bw_set_option() {
  local name="$1"
  local value="$2"

  tmux set-option -gq "${TMUX_PREFIX}-${name}" "${value}"
}

tmux_bw_get_config() {
  local name="$1"

  tmux show-option -gqv "${TMUX_PREFIX}-$name"
}

# Get tmux option
tmux_bw_get_config_or_default() {
  local option="$1"
  local default_value="$2"
  local option_value

  option_value="$(tmux_bw_get_config "$option")"

  if [[ -z "$option_value" ]]; then
    echo "$default_value"
  else
    echo "$option_value"
  fi
}
