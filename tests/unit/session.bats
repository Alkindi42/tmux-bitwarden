#!/usr/bin/env bats

load "../helpers/test_helper.bash"

setup() {
  load_session_script

  LAST_MESSAGE=""
  UNLOCK_CALLED=0

  # shellcheck disable=SC2329
  tmux_display_message() {
    LAST_MESSAGE="$1"
  }
}

@test "tmux_bw_has_session returns success when a session exists" {
  # shellcheck disable=SC2329
  tmux_bw_get_session() {
    printf '%s\n' "session-token"
  }

  run tmux_bw_has_session

  [ "$status" -eq 0 ]
}

@test "tmux_bw_has_session returns failure when no session exists" {
  # shellcheck disable=SC2329
  tmux_bw_get_session() {
    return 0
  }

  run tmux_bw_has_session

  [ "$status" -ne 0 ]
}

@test "tmux_bw_authenticate shows message when user is unauthenticated" {
  # shellcheck disable=SC2329
  tmux_bw_get_status() {
    printf '%s\n' "$BW_STATUS_UNAUTHENTICATED"
  }

  local status=0
  tmux_bw_authenticate || status=$?

  [ "$status" -eq 1 ]
  [ "$LAST_MESSAGE" = "You are not logged in. Please run 'bw login'." ]
}

@test "tmux_bw_authenticate unlocks the vault when status is locked" {
  # shellcheck disable=SC2329
  tmux_bw_get_status() {
    printf '%s\n' "$BW_STATUS_LOCKED"
  }

  # shellcheck disable=SC2329
  tmux_bw_unlock_and_store_session() {
    UNLOCK_CALLED=1
    return 0
  }

  tmux_bw_authenticate

  [ "$UNLOCK_CALLED" -eq 1 ]
}

@test "tmux_bw_authenticate succeeds when status is unlocked" {
  # shellcheck disable=SC2329
  tmux_bw_get_status() {
    printf '%s\n' "$BW_STATUS_UNLOCKED"
  }

  run tmux_bw_authenticate

  [ "$status" -eq 0 ]
}

@test "tmux_bw_authenticate shows message on unknown status" {
  # shellcheck disable=SC2329
  tmux_bw_get_status() {
    printf '%s\n' "weird-status"
  }

  local status=0
  tmux_bw_authenticate || status=$?

  [ "$status" -eq 1 ]
  [ "$LAST_MESSAGE" = "Unknown Bitwarden status." ]
}

@test "tmux_bw_run_with_auth retries after auth error and succeeds" {
  local trace_file="$BATS_TEST_TMPDIR/auth-retry-trace"
  : >"$trace_file"

  # shellcheck disable=SC2329
  tmux_bw_get_session() {
    if grep -q '^auth$' "$trace_file"; then
      printf '%s\n' "fresh-session"
    else
      printf '%s\n' "stale-session"
    fi
  }

  # shellcheck disable=SC2329
  tmux_bw_authenticate() {
    printf '%s\n' "auth" >>"$trace_file"
    return 0
  }

  # shellcheck disable=SC2329
  fake_bw_call() {
    local session="$1"
    printf '%s\n' "call:$session" >>"$trace_file"

    if [[ "$session" == "stale-session" ]]; then
      printf '%s\n' "Vault is locked." >&2
      return 1
    fi

    printf '%s\n' "ok"
  }

  run tmux_bw_run_with_auth fake_bw_call

  [ "$status" -eq 0 ]
  [ "$output" = "ok" ]
  grep -qx 'auth' "$trace_file"
  [ "$(grep -c '^call:' "$trace_file")" -eq 2 ]
  grep -qx 'call:stale-session' "$trace_file"
  grep -qx 'call:fresh-session' "$trace_file"
}

@test "tmux_bw_run_with_auth does not retry on non-auth error" {
  local trace_file="$BATS_TEST_TMPDIR/auth-no-retry-trace"
  : >"$trace_file"

  # shellcheck disable=SC2329
  tmux_bw_get_session() {
    printf '%s\n' "session-token"
  }

  # shellcheck disable=SC2329
  tmux_bw_authenticate() {
    printf '%s\n' "auth" >>"$trace_file"
    return 0
  }

  # shellcheck disable=SC2329
  fake_bw_call() {
    local session="$1"
    printf '%s\n' "call:$session" >>"$trace_file"
    printf '%s\n' "Item not found." >&2
    return 1
  }

  run tmux_bw_run_with_auth fake_bw_call

  [ "$status" -ne 0 ]
  [ "$(grep -c '^call:' "$trace_file")" -eq 1 ]
  [ "$(grep -c '^auth$' "$trace_file")" -eq 0 ]
}
