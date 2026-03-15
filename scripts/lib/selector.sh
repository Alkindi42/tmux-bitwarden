#!/usr/bin/env bash

tmux_bw_selector() {
  local selection
  local session
  local item_id

  session="$(tmux_bw_get_session)"
  selection="$(
    {
      printf 'id\tName\tUsername\tURI\n'
      bw_list_items "$session" | jq -r '
      .[]
      | [
          .id,
          (.name // ""),
          (.login.username // ""),
          ((.login.uris // [])[0].uri // "")
        ]
      | @tsv
    '
    } | column -t -s $'\t' | fzf \
      --delimiter='  +' \
      --with-nth=2,3,4 \
      --nth=2,3,4 \
      --header-lines=1 \
      --prompt='Bitwarden > '
  )"

  item_id="$(printf '%s\n' "$selection" | awk '{print $1}')"

  [[ -n "$item_id" ]] || return 1

  printf '%s\n' "$item_id"
}
