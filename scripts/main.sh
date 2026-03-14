#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
declare -r CURRENT_DIR

# shellcheck source=/dev/null
source "$CURRENT_DIR/lib/common.sh"
source "$CURRENT_DIR/lib/vault.sh"

get_password() {
  local items=$1
  local key=$2

  password=$(echo "$items" | jq ".\"$key\"")
  echo "${password:1:-1}"
}

main() {
  declare -A TMUX_OPTS=(
    ["@bw-session"]=$(get_tmux_option "@bw-session" "$BW_SESSION")
    ["@bw-copy-to-clipboard"]=$(get_tmux_option "@bw-copy-to-clipboard" "off")
  )

  is_authenticated
  if [[ $? -eq 1 ]]; then
    display_tmux_message "You are not logged in."
    return 1
  fi

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
