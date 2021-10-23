#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

source "./utils.sh"

is_authenticated() {
  [[ $(bw status | jq '.status') != "\"unauthenticated\"" ]] && true
}

# Get bitwarden items
get_bw_items() {
  local session="$1"
  filter='map({ (.name|tostring): .login.password })|add'

  if [[ -z "$session" ]]; then
    bw list items | jq -r "$filter"
  else
    bw list items --session "$session" | jq -r "$filter"
  fi
}

get_password() {
  local items=$1
  local key=$2

  password=$(echo "$items" | jq ".\"$key\"")
  echo "${password:1:-1}"
}

main() {
  declare -A TMUX_OPTS=(
    ["@bw-session"]=$(get_tmux_option "@bw-session" $BW_SESSION)
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
