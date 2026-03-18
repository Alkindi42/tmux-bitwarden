#!/usr/bin/env bash

readonly BW_KEY_COPY_PASSWORD="ctrl-y"
readonly BW_KEY_COPY_USERNAME="alt-u"
readonly BW_KEY_PASTE_PASSWORD="enter"
readonly BW_KEY_PASTE_USERNAME="ctrl-u"
readonly BW_KEY_REFRESH_CACHE="ctrl-r"

readonly TMUX_BW_SELECTOR_CANCEL=10
readonly TMUX_BW_SELECTOR_ERROR=20

tmux_bw_selector_rows() {
  local session="$1"

  printf 'id\tName\tUsername\tURIs\n'
  tmux_bw_list_items_with_cache "$session" | jq -r '
    .[]
    | [
        .id,
        (.name // ""),
        (.login.username // ""),
        ((.login.uris // []) | map(.uri // "") | @json)
      ]
    | @tsv
  '
}

tmux_bw_selector_action_from_key() {
  local key="$1"

  case "$key" in
  "" | "$BW_KEY_PASTE_PASSWORD")
    printf '%s\n' "$BW_PASTE_PASSWORD"
    ;;
  "$BW_KEY_COPY_PASSWORD")
    printf '%s\n' "$BW_COPY_PASSWORD"
    ;;
  "$BW_KEY_PASTE_USERNAME")
    printf '%s\n' "$BW_PASTE_USERNAME"
    ;;
  "$BW_KEY_COPY_USERNAME")
    printf '%s\n' "$BW_COPY_USERNAME"
    ;;
  *)
    return 1
    ;;
  esac
}

tmux_bw_selector() {
  local key
  local status
  local session
  local item_id
  local selection
  local action_name
  local selected_line

  local _name
  local _username
  local _uris_json

  if ! session="$(tmux_bw_get_session)"; then
    return "$TMUX_BW_SELECTOR_ERROR"
  fi

  while true; do
    if selection="$(
      tmux_bw_selector_rows "$session" | fzf \
        --delimiter=$'\t' \
        --expect="$BW_KEY_PASTE_PASSWORD,$BW_KEY_COPY_PASSWORD,$BW_KEY_PASTE_USERNAME,$BW_KEY_COPY_USERNAME,$BW_KEY_REFRESH_CACHE" \
        --with-nth=2 \
        --header-lines=1 \
        --header=$'enter: paste password | ctrl-y: copy password\nctrl-u: paste user | alt-u: copy user | ctrl-r: refresh' \
        --prompt='Bitwarden > ' \
        --preview='
          printf "ID        : %s\n" {1}
          printf "Name      : %s\n" {2}
          printf "Username  : %s\n" {3}
          printf "\nURI(s):\n"
          printf "%s\n" {4} | jq -r '"'"'if length == 0 then "(none)" else .[] end'"'"'
        ' \
        --preview-window='right:50%:wrap'
    )"; then
      status=0
    else
      status=$?
    fi

    case "$status" in
    0) ;;
    130 | 1)
      return "$TMUX_BW_SELECTOR_CANCEL"
      ;;
    *)
      return "$TMUX_BW_SELECTOR_ERROR"
      ;;
    esac

    {
      IFS= read -r key
      IFS= read -r selected_line
    } <<<"$selection"

    if [[ "$key" == "$BW_KEY_REFRESH_CACHE" ]]; then
      tmux_bw_cache_invalidate || return "$TMUX_BW_SELECTOR_ERROR"
      continue
    fi

    if ! action_name="$(tmux_bw_selector_action_from_key "$key")"; then
      return "$TMUX_BW_SELECTOR_ERROR"
    fi

    IFS=$'\t' read -r item_id _name _username _uris_json <<<"$selected_line"
    [[ -n "$item_id" ]] || return "$TMUX_BW_SELECTOR_ERROR"

    printf '%s\n%s\n' "$action_name" "$item_id"
    return 0
  done
}
