#!/usr/bin/env bash

bw_list_items() {
  local session="$1"

  bw list items --session "$session"
}

bw_get_item_by_id() {
  local id="$2"
  local session="$1"

  bw get item --session "$session" "$id"
}
