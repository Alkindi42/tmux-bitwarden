#!/usr/bin/env bats

load "../helpers/test_helper.bash"

setup() {
  load_cache_script
  TEST_TMPDIR="$(mktemp -d)"
}

teardown() {
  rm -rf "$TEST_TMPDIR"
}

@test "cache is expired when file does not exist" {
  local missing_file="$TEST_TMPDIR/missing.json"

  run tmux_bw_cache_is_expired "$missing_file" 3600
  [ "$status" -eq 0 ]
}

@test "cache is not expired when file is recent" {
  local cache_file="$TEST_TMPDIR/items.json"
  printf '%s\n' '[]' >"$cache_file"

  run tmux_bw_cache_is_expired "$cache_file" 3600

  [ "$status" -eq 1 ]
}

@test "cache invalidate removes cache file" {
  local expected_cache_file="$TEST_TMPDIR/items.json"
  printf '%s\n' '[]' >"$expected_cache_file"

  # shellcheck disable=SC2329
  tmux_bw_get_config_or_default() {
    printf '%s\n' "$expected_cache_file"
  }

  tmux_bw_cache_invalidate
  [ ! -e "$expected_cache_file" ]
}

@test "cache invalidate succeeds when cache file does not exist" {
  local cache_file="$TEST_TMPDIR/missing.json"

  # shellcheck disable=SC2329
  tmux_bw_get_config_or_default() {
    printf '%s\n' "$cache_file"
  }

  tmux_bw_cache_invalidate
}

@test "cache never expires when ttl is -1" {
  local cache_file="$TEST_TMPDIR/items.json"
  printf '%s\n' '[]' >"$cache_file"

  run tmux_bw_cache_is_expired "$cache_file" -1

  [ "$status" -eq 1 ]
}

@test "list items with cache filters non-login Bitwarden items" {
  # shellcheck disable=SC2329
  tmux_bw_get_config_or_default() {
    case "$1" in
    "$BW_CONFIG_KEY_CACHE")
      printf '%s\n' "false"
      ;;
    *)
      printf '%s\n' "$2"
      ;;
    esac
  }

  # shellcheck disable=SC2329
  tmux_bw_run_with_auth() {
    cat <<'JSON'
[
  {
    "id": "login-1",
    "type": 1,
    "name": "Github",
    "login": {
      "username": "Alkindi",
      "uris": [
        { "uri": "https://github.com/login" }
      ]
    }
  },
  {
    "id": "card-1",
    "type": 3,
    "name": "Amex",
    "card": {
      "brand": "Amex"
    }
  }
]
JSON
  }

  run tmux_bw_list_items_with_cache

  [ "$status" -eq 0 ]
  [[ "$output" == *'"id":"login-1"'* ]]
  [[ "$output" != *'"id":"card-1"'* ]]
}

@test "list items with cache exposes has_totp flag" {
  tmux_bw_get_config_or_default() {
    case "$1" in
    "$BW_CONFIG_KEY_CACHE")
      printf '%s\n' "false"
      ;;
    *)
      printf '%s\n' "$2"
      ;;
    esac
  }

  tmux_bw_run_with_auth() {
    cat <<'JSON'
[
  {
    "id": "login-with-totp",
    "type": 1,
    "name": "GitHub",
    "login": {
      "username": "alice",
      "uris": [
        { "uri": "https://github.com/login" }
      ],
      "totp": "otpauth://totp/example"
    }
  },
  {
    "id": "login-without-totp",
    "type": 1,
    "name": "GitLab",
    "login": {
      "username": "bob",
      "uris": [
        { "uri": "https://gitlab.com/users/sign_in" }
      ]
    }
  }
]
JSON
  }

  run tmux_bw_list_items_with_cache

  [ "$status" -eq 0 ]
  [[ "$output" == *'"id":"login-with-totp"'* ]]
  [[ "$output" == *'"has_totp":true'* ]]
  [[ "$output" == *'"id":"login-without-totp"'* ]]
  [[ "$output" == *'"has_totp":false'* ]]
}
