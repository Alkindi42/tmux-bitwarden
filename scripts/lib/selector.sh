#!/usr/bin/env bash

readonly BW_KEY_COPY_TOTP="alt-t"
readonly BW_KEY_PASTE_TOTP="ctrl-t"
readonly BW_KEY_COPY_PASSWORD="ctrl-y"
readonly BW_KEY_COPY_USERNAME="alt-u"
readonly BW_KEY_PASTE_PASSWORD="enter"
readonly BW_KEY_PASTE_USERNAME="ctrl-u"
readonly BW_KEY_REFRESH_CACHE="ctrl-r"

readonly TMUX_BW_SELECTOR_CANCEL=10
readonly TMUX_BW_SELECTOR_ERROR=20
readonly TMUX_BW_SELECTOR_ABORTED=30

tmux_bw_selector_rows() {
  local items

  items="$(tmux_bw_list_items_with_cache)" || return 1

  printf 'id\tName\tUsername\tURIs\tHasTotp\n'
  printf '%s\n' "$items" | jq -r '
    .[]
    | [
        .id,
        (.name // ""),
        (.login.username // ""),
        ((.login.uris // []) | map(.uri // "") | @json),
        (.login.has_totp // false)
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
  "$BW_KEY_COPY_TOTP")
    printf '%s\n' "$BW_COPY_TOTP"
    ;;
  "$BW_KEY_PASTE_TOTP")
    printf '%s\n' "$BW_PASTE_TOTP"
    ;;
  *)
    return 1
    ;;
  esac
}

tmux_bw_selector() {
  local key
  local rows
  local status
  local item_id
  local selection
  local action_name
  local selected_line

  local _name
  local _username
  local _uris_json
  local _has_totp

  while true; do
    rows="$(tmux_bw_selector_rows)" || return "$TMUX_BW_SELECTOR_ABORTED"

    if selection="$(
      printf '%s\n' "$rows" | fzf \
        --delimiter=$'\t' \
        --expect="$BW_KEY_PASTE_PASSWORD,$BW_KEY_COPY_PASSWORD,$BW_KEY_PASTE_USERNAME,$BW_KEY_COPY_USERNAME,$BW_KEY_REFRESH_CACHE,$BW_KEY_COPY_TOTP,$BW_KEY_PASTE_TOTP" \
        --with-nth=2 \
        --header-lines=1 \
        --header=$'enter: paste password | ctrl-y: copy password | ctrl-r: refresh\nctrl-u: paste user | alt-u: copy user | alt-t: copy totp | ctrl-t: paste totp' \
        --prompt='Bitwarden > ' \
        --preview='
          printf "ID        : %s\n" {1}
          printf "Name      : %s\n" {2}
          printf "Username  : %s\n" {3}
          case "{r5}" in
          true)
            printf "TOTP      : yes\n"
            ;;
          esac
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

    IFS=$'\t' read -r item_id _name _username _uris_json _has_totp <<<"$selected_line"
    [[ -n "$item_id" ]] || return "$TMUX_BW_SELECTOR_ERROR"

    printf '%s\n%s\n' "$action_name" "$item_id"
    return 0
  done
}
