#!/usr/bin/env bats

load "../helpers/test_helper.bash"

setup() {
  load_main_script

  LAST_MESSAGE=""
  PASTE_PASSWORD_ARGS=""
  COPY_PASSWORD_ARGS=""
  PASTE_USERNAME_ARGS=""
  COPY_USERNAME_ARGS=""
  UNLOCK_CALLED=0

  # shellcheck disable=SC2329
  tmux_display_message() {
    LAST_MESSAGE="$1"
  }
}

@test "main returns 0 and shows message when pane target is missing" {
  main

  [ "$LAST_MESSAGE" = "Invalid pane target." ]
}

@test "main returns 0 and shows message when user is unauthenticated" {
  # shellcheck disable=SC2329
  tmux_bw_get_status() {
    printf '%s\n' "$BW_STATUS_UNAUTHENTICATED"
  }

  main "%1"

  [ "$LAST_MESSAGE" = "You are not logged in. Please run 'bw login'." ]
}

@test "main unlocks the vault when status is locked" {
  # shellcheck disable=SC2329
  tmux_bw_get_status() {
    printf '%s\n' "$BW_STATUS_LOCKED"
  }

  tmux_bw_unlock_and_store_session() {
    UNLOCK_CALLED=1
  }

  # shellcheck disable=SC2329
  tmux_bw_selector() {
    return 1
  }

  main "%1"

  [ "$UNLOCK_CALLED" -eq 1 ]
}

@test "main returns 0 when selector is canceled" {
  # shellcheck disable=SC2329
  tmux_bw_get_status() {
    printf '%s\n' "$BW_STATUS_UNLOCKED"
  }

  # shellcheck disable=SC2329
  tmux_bw_selector() {
    return 1
  }

  main "%1"

  [ -z "$LAST_MESSAGE" ]
}

@test "main dispatches paste password with selected item id and target pane" {
  # shellcheck disable=SC2329
  tmux_bw_get_status() {
    printf '%s\n' "$BW_STATUS_UNLOCKED"
  }

  # shellcheck disable=SC2329
  tmux_bw_selector() {
    printf '%s\n%s\n' "$BW_PASTE_PASSWORD" "item-123"
  }

  tmux_bw_paste_password() {
    PASTE_PASSWORD_ARGS="$1|$2"
  }

  main "%9"

  [ "$PASTE_PASSWORD_ARGS" = "item-123|%9" ]
}

@test "main shows success message after copy password" {
  # shellcheck disable=SC2329
  tmux_bw_get_status() {
    printf '%s\n' "$BW_STATUS_UNLOCKED"
  }

  # shellcheck disable=SC2329
  tmux_bw_selector() {
    printf '%s\n%s\n' "$BW_COPY_PASSWORD" "item-456"
  }

  tmux_bw_copy_password() {
    COPY_PASSWORD_ARGS="$1"
  }

  main "%1"

  [ "$COPY_PASSWORD_ARGS" = "item-456" ]
  [ "$LAST_MESSAGE" = "Password copied to the clipboard." ]
}

@test "main returns 1 and shows message for unknown action" {
  # shellcheck disable=SC2329
  tmux_bw_get_status() {
    printf '%s\n' "$BW_STATUS_UNLOCKED"
  }

  # shellcheck disable=SC2329
  tmux_bw_selector() {
    printf '%s\n%s\n' "unknown-action" "item-999"
  }

  local status=0
  main "%1" || status=$?

  [ "$status" -eq 1 ]
  [ "$LAST_MESSAGE" = "Unknown action." ]
}

@test "main dispatches paste username with selected item id and target pane" {
  # shellcheck disable=SC2329
  tmux_bw_get_status() {
    printf '%s\n' "$BW_STATUS_UNLOCKED"
  }

  # shellcheck disable=SC2329
  tmux_bw_selector() {
    printf '%s\n%s\n' "$BW_PASTE_USERNAME" "item-789"
  }

  tmux_bw_paste_username() {
    PASTE_USERNAME_ARGS="$1|$2"
  }

  main "%7"

  [ "$PASTE_USERNAME_ARGS" = "item-789|%7" ]
}

@test "main shows success message after copy username" {
  # shellcheck disable=SC2329
  tmux_bw_get_status() {
    printf '%s\n' "$BW_STATUS_UNLOCKED"
  }

  # shellcheck disable=SC2329
  tmux_bw_selector() {
    printf '%s\n%s\n' "$BW_COPY_USERNAME" "item-321"
  }

  tmux_bw_copy_username() {
    COPY_USERNAME_ARGS="$1"
  }

  main "%1"

  [ "$COPY_USERNAME_ARGS" = "item-321" ]
  [ "$LAST_MESSAGE" = "Username copied to the clipboard." ]
}
