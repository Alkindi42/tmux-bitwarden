#!/usr/bin/env bash

tmux_bw_file_mtime() {
  local file="$1"

  [[ -f "$file" ]] || return 1

  if stat -c %Y "$file" >/dev/null 2>&1; then
    stat -c %Y "$file"
  else
    stat -f %m "$file"
  fi
}

tmux_bw_cache_is_expired() {
  local file="$1"
  local ttl_seconds="$2"
  local now
  local mtime

  [[ -f "$file" ]] || return 0

  now="$(date +%s)"
  mtime="$(tmux_bw_file_mtime "$file")" || return 0

  ((now - mtime >= ttl_seconds))
}

tmux_bw_list_items_with_cache() {
  local session="$1"
  local cache
  local cache_ttl
  local cache_file
  local cache_filter
  local enabled_cache

  cache_filter='
    map({
      id,
      name,
      login: {
        username: .login.username,
        uris: .login.uris
      }
    })
  '

  enabled_cache="$(tmux_bw_get_config_or_default "$BW_CONFIG_KEY_CACHE" "$BW_CONFIG_DEFAULT_CACHE")"

  if [[ "$enabled_cache" == "true" ]]; then
    cache_file="$(tmux_bw_get_config_or_default "$BW_CONFIG_KEY_CACHE_FILE" "$BW_CONFIG_DEFAULT_CACHE_FILE")"
    cache_ttl="$(tmux_bw_get_config_or_default "$BW_CONFIG_KEY_CACHE_TTL" "$BW_CONFIG_DEFAULT_CACHE_TTL")"

    if tmux_bw_cache_is_expired "$cache_file" "$cache_ttl"; then
      mkdir -p "$(dirname "$cache_file")" || return 1
      cache="$(bw_list_items "$session" | jq -c "$cache_filter")" || return 1
      printf '%s\n' "$cache" >"$cache_file" || return 1
    else
      cache="$(<"$cache_file")" || return 1
    fi
  else
    cache="$(bw_list_items "$session" | jq "$cache_filter")" || return 1
  fi

  printf "%s\n" "$cache"
}
