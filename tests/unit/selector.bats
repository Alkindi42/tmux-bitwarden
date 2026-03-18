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
