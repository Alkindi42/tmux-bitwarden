#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
declare -r CURRENT_DIR

# shellcheck source=/dev/null
source "$CURRENT_DIR/scripts/lib/config.sh"
source "$CURRENT_DIR/scripts/lib/common.sh"

declare -a REQUIRED_BINARIES=(
  'jq'
  'fzf'
  'bw'
)

main() {
  local key_binding

  for binary in "${REQUIRED_BINARIES[@]}"; do
    if ! is_binary_exist "$binary"; then
      tmux_display_message "Missing required binary: $binary"
      return 1
    fi
  done

  key_binding="$(tmux_bw_get_config_or_default "key" "b")"
  tmux bind-key "$key_binding" run-shell "$CURRENT_DIR/scripts/lib/ui.sh"
}

main "$@"
