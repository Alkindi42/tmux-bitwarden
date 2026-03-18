#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CURRENT_DIR

# shellcheck source=scripts/lib/config.sh
source "$CURRENT_DIR/scripts/lib/config.sh"
# shellcheck source=scripts/lib/common.sh
source "$CURRENT_DIR/scripts/lib/common.sh"

REQUIRED_BINARIES=(
  jq
  fzf
  bw
)

main() {
  local key_binding
  local missing=()

  for binary in "${REQUIRED_BINARIES[@]}"; do
    if ! is_binary_exist "$binary"; then
      missing+=("$binary")
    fi
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    tmux_display_message "Missing required binaries: ${missing[*]}"
    return 0
  fi

  key_binding="$(tmux_bw_get_config_or_default "$BW_CONFIG_KEY_KEY" "$BW_CONFIG_DEFAULT_KEY")"
  tmux bind-key "$key_binding" run-shell "$CURRENT_DIR/scripts/lib/ui.sh"
}

main "$@"
