#!/usr/bin/env bash

bw_list_items() {
  local session="$1"

  bw list items --session "$session" --nointeraction
}

bw_get_item_by_id() {
  local session="$1"
  local id="$2"

  bw get item --session "$session" --nointeraction "$id"
}

bw_get_totp() {
  local session="$1"
  local id="$2"

  bw get totp --session "$session" --nointeraction "$id"
}
