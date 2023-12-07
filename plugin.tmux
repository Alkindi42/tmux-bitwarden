#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
declare -r CURRENT_DIR

# shellcheck source=/dev/null
source "$CURRENT_DIR/scripts/utils.sh"

declare -a REQUIRED_BINARIES=(
  'jq'
  'fzf'
  'bw'
)

main() {
  for binary in "${REQUIRED_BINARIES[@]}"
  do
    if ! is_binary_exist "$binary"
    then
      display_tmux_message "binary $binary does not exist"
      return 1
    fi
  done

  key_binding=$(get_tmux_option "@bw-key" "b")
  tmux bind-key "$key_binding" split-window -l 10 "$CURRENT_DIR/scripts/main.sh"
}

main "$@"
