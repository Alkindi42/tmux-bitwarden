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
}

@test "cache is not expired when file is recent" {
  local cache_file="$TEST_TMPDIR/items.json"
  printf '%s\n' '[]' >"$cache_file"

  run tmux_bw_cache_is_expired "$cache_file" 3600

  [ "$status" -eq 1 ]
}

@test "cache invalidate removes cache file" {
  # shellcheck disable=SC2329
  tmux_bw_get_config_or_default() {
    printf '%s\n' "$expected_cache_file"
  }

  local expected_cache_file="$TEST_TMPDIR/items.json"
  printf '%s\n' '[]' >"$expected_cache_file"

  tmux_bw_cache_invalidate
  [ ! -e "$expected_cache_file" ]
}

@test "cache invalidate succeeds when cache file does not exist" {
  local cache_file="$TEST_TMPDIR/missing.json"

  tmux_bw_get_config_or_default() {
    printf '%s\n' "$cache_file"
  }

  tmux_bw_cache_invalidate
}
