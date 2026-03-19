#!/usr/bin/env bats

load "../helpers/test_helper.bash"

setup() {
  load_selector_script
}

@test "enter maps to paste password" {
  run tmux_bw_selector_action_from_key "enter"
  [ "$status" -eq 0 ]
  [ "$output" = "$BW_PASTE_PASSWORD" ]
}

@test "ctrl-y maps to copy password" {
  run tmux_bw_selector_action_from_key "ctrl-y"
  [ "$status" -eq 0 ]
  [ "$output" = "$BW_COPY_PASSWORD" ]
}

@test "ctrl-u maps to paste username" {
  run tmux_bw_selector_action_from_key "ctrl-u"
  [ "$status" -eq 0 ]
  [ "$output" = "$BW_PASTE_USERNAME" ]
}

@test "alt-u maps to copy username" {
  run tmux_bw_selector_action_from_key "alt-u"
  [ "$status" -eq 0 ]
  [ "$output" = "$BW_COPY_USERNAME" ]
}

@test "unknown key returns error" {
  run tmux_bw_selector_action_from_key "foo"
  [ "$status" -ne 0 ]
}

@test "selector returns ABORTED when rows loading fails" {
  # shellcheck disable=SC2329
  tmux_bw_selector_rows() {
    return 1
  }

  run tmux_bw_selector

  [ "$status" -eq "$TMUX_BW_SELECTOR_ABORTED" ]
}

@test "selector returns CANCEL on fzf interrupt (130)" {
  # shellcheck disable=SC2329
  tmux_bw_selector_rows() {
    printf 'id\tName\tUsername\tURIs\tHasTotp\n'
  }

  # shellcheck disable=SC2329
  fzf() {
    return 130
  }

  run tmux_bw_selector

  [ "$status" -eq "$TMUX_BW_SELECTOR_CANCEL" ]
}

@test "selector returns CANCEL on no match (1)" {
  # shellcheck disable=SC2329
  tmux_bw_selector_rows() {
    printf 'id\tName\tUsername\tURIs\tHasTotp\n'
  }

  # shellcheck disable=SC2329
  fzf() {
    return 1
  }

  run tmux_bw_selector

  [ "$status" -eq "$TMUX_BW_SELECTOR_CANCEL" ]
}

@test "selector returns ERROR on fzf error (2)" {
  # shellcheck disable=SC2329
  tmux_bw_selector_rows() {
    printf 'id\tName\tUsername\tURIs\tHasTotp\n'
  }

  # shellcheck disable=SC2329
  fzf() {
    return 2
  }

  run tmux_bw_selector

  [ "$status" -eq "$TMUX_BW_SELECTOR_ERROR" ]
}

@test "selector returns action and item id from fzf output" {
  # shellcheck disable=SC2329
  tmux_bw_selector_rows() {
    printf 'id\tName\tUsername\tURIs\tHasTotp\n'
  }

  # shellcheck disable=SC2329
  fzf() {
    printf '\nitem-123\tGitHub\talice\t["https://github.com"]\tfalse\n'
  }

  run tmux_bw_selector

  [ "$status" -eq 0 ]
  [ "$output" = "$(printf '%s\n%s' "$BW_PASTE_PASSWORD" "item-123")" ]
}

@test "alt-t maps to copy totp" {
  run tmux_bw_selector_action_from_key "alt-t"
  [ "$status" -eq 0 ]
  [ "$output" = "$BW_COPY_TOTP" ]
}

@test "ctrl-t maps to paste totp" {
  run tmux_bw_selector_action_from_key "ctrl-t"
  [ "$status" -eq 0 ]
  [ "$output" = "$BW_PASTE_TOTP" ]
}
