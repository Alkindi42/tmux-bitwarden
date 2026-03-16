#!/usr/bin/env bash

readonly BW_KEY_COPY_PASSWORD="ctrl-y"
readonly BW_KEY_COPY_USERNAME="alt-u"
readonly BW_KEY_PASTE_PASSWORD="enter"
readonly BW_KEY_PASTE_USERNAME="ctrl-u"
readonly BW_KEY_REFRESH_CACHE="ctrl-r"

tmux_bw_selector() {
  local key
  local session
  local item_id
  local selection
  local action_name
  local selected_line

  session="$(tmux_bw_get_session)"

  while true; do
    selection="$(
      {
        printf 'id\tName\tUsername\tURI\n'
        tmux_bw_list_items_with_cache "$session" | jq -r '
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
        --expect="$BW_KEY_PASTE_PASSWORD,$BW_KEY_COPY_PASSWORD,$BW_KEY_PASTE_USERNAME,$BW_KEY_COPY_USERNAME,$BW_KEY_REFRESH_CACHE" \
        --with-nth=2,3,4 \
        --nth=2,3,4 \
        --header-lines=1 \
        --header="${BW_KEY_PASTE_PASSWORD}: paste password | ${BW_KEY_COPY_PASSWORD}: copy password | ${BW_KEY_PASTE_USERNAME}: paste username | ${BW_KEY_COPY_USERNAME}: copy username | ${BW_KEY_REFRESH_CACHE}: refresh cache" \
        --prompt='Bitwarden > '
    )"

    key="$(printf '%s\n' "$selection" | sed -n '1p')"
    selected_line="$(printf '%s\n' "$selection" | sed -n '2p')"
    item_id="$(printf '%s\n' "$selected_line" | awk '{print $1}')"

    case "$key" in
    "" | "$BW_KEY_PASTE_PASSWORD")
      action_name="$BW_PASTE_PASSWORD"
      ;;
    "$BW_KEY_COPY_PASSWORD")
      action_name="$BW_COPY_PASSWORD"
      ;;
    "$BW_KEY_PASTE_USERNAME")
      action_name="$BW_PASTE_USERNAME"
      ;;
    "$BW_KEY_COPY_USERNAME")
      action_name="$BW_COPY_USERNAME"
      ;;
    "$BW_KEY_REFRESH_CACHE")
      tmux_bw_cache_invalidate || return 1
      continue
      ;;
    *)
      return 1
      ;;
    esac

    [[ -n "$item_id" ]] || return 1

    printf '%s\n%s\n' "$action_name" "$item_id"
    return 0
  done
}
