#!/usr/bin/env bash

tmux_bw_selector() {
  local key
  local session
  local item_id
  local selection
  local action_name
  local selected_line

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
      --expect=enter,ctrl-y \
      --with-nth=2,3,4 \
      --nth=2,3,4 \
      --header-lines=1 \
      --prompt='Bitwarden > '
  )"

  key="$(printf '%s\n' "$selection" | sed -n '1p')"
  selected_line="$(printf '%s\n' "$selection" | sed -n '2p')"
  item_id="$(printf '%s\n' "$selected_line" | awk '{print $1}')"

  case "$key" in
  "" | enter)
    action_name="$BW_PASTE_PASSWORD"
    ;;
  ctrl-y)
    action_name="$BW_COPY_PASSWORD"
    ;;
  *)
    return 1
    ;;
  esac

  [[ -n "$item_id" ]] || return 1

  printf '%s\n%s\n' "$action_name" "$item_id"
}
