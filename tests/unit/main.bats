#!/usr/bin/env bats

load "../helpers/test_helper.bash"

setup() {
  load_main_script

  LAST_MESSAGE=""
  PASTE_TOTP_ARGS=""
  COPY_TOTP_ARGS=""
  PASTE_PASSWORD_ARGS=""
  COPY_PASSWORD_ARGS=""
  PASTE_USERNAME_ARGS=""
  COPY_USERNAME_ARGS=""

  # shellcheck disable=SC2329
  tmux_display_message() {
    LAST_MESSAGE="$1"
  }
}

@test "main returns 0 and shows message when pane target is missing" {
  main

  [ "$LAST_MESSAGE" = "Invalid pane target." ]
}

@test "main returns 0 when authentication fails without session" {
  # shellcheck disable=SC2329
  tmux_bw_has_session() {
    return 1
  }

  # shellcheck disable=SC2329
  tmux_bw_authenticate() {
    LAST_MESSAGE="You are not logged in. Please run 'bw login'."
    return 1
  }

  main "%1"

  [ "$LAST_MESSAGE" = "You are not logged in. Please run 'bw login'." ]
}

@test "main authenticates when session is missing and continues to selector" {
  local auth_called=0

  # shellcheck disable=SC2329
  tmux_bw_has_session() {
    return 1
  }

  # shellcheck disable=SC2329
  tmux_bw_authenticate() {
    auth_called=1
    return 0
  }

  # shellcheck disable=SC2329
  tmux_bw_selector() {
    return "$TMUX_BW_SELECTOR_CANCEL"
  }

  main "%1"

  [ "$auth_called" -eq 1 ]
}

@test "main returns 0 when selector is canceled" {
  # shellcheck disable=SC2329
  tmux_bw_has_session() {
    return 0
  }

  # shellcheck disable=SC2329
  tmux_bw_selector() {
    return "$TMUX_BW_SELECTOR_CANCEL"
  }

  main "%1"

  [ -z "$LAST_MESSAGE" ]
}

@test "main dispatches paste password with selected item id and target pane" {
  # shellcheck disable=SC2329
  tmux_bw_has_session() {
    return 0
  }

  # shellcheck disable=SC2329
  tmux_bw_selector() {
    printf '%s\n%s\n' "$BW_PASTE_PASSWORD" "item-123"
  }

  # shellcheck disable=SC2329
  tmux_bw_paste_password() {
    PASTE_PASSWORD_ARGS="$1|$2"
  }

  main "%9"

  [ "$PASTE_PASSWORD_ARGS" = "item-123|%9" ]
}

@test "main shows success message after copy password" {
  # shellcheck disable=SC2329
  tmux_bw_has_session() {
    return 0
  }

  # shellcheck disable=SC2329
  tmux_bw_selector() {
    printf '%s\n%s\n' "$BW_COPY_PASSWORD" "item-456"
  }

  # shellcheck disable=SC2329
  tmux_bw_copy_password() {
    COPY_PASSWORD_ARGS="$1"
  }

  main "%1"

  [ "$COPY_PASSWORD_ARGS" = "item-456" ]
  [ "$LAST_MESSAGE" = "Password copied to the clipboard." ]
}

@test "main shows message for unknown action" {
  # shellcheck disable=SC2329
  tmux_bw_has_session() {
    return 0
  }

  # shellcheck disable=SC2329
  tmux_bw_selector() {
    printf '%s\n%s\n' "unknown-action" "item-999"
  }

  main "%1"

  [ "$LAST_MESSAGE" = "Unknown action." ]
}

@test "main dispatches paste username with selected item id and target pane" {
  # shellcheck disable=SC2329
  tmux_bw_has_session() {
    return 0
  }

  # shellcheck disable=SC2329
  tmux_bw_selector() {
    printf '%s\n%s\n' "$BW_PASTE_USERNAME" "item-789"
  }

  # shellcheck disable=SC2329
  tmux_bw_paste_username() {
    PASTE_USERNAME_ARGS="$1|$2"
  }

  main "%7"

  [ "$PASTE_USERNAME_ARGS" = "item-789|%7" ]
}

@test "main shows success message after copy username" {
  # shellcheck disable=SC2329
  tmux_bw_has_session() {
    return 0
  }

  # shellcheck disable=SC2329
  tmux_bw_selector() {
    printf '%s\n%s\n' "$BW_COPY_USERNAME" "item-321"
  }

  # shellcheck disable=SC2329
  tmux_bw_copy_username() {
    COPY_USERNAME_ARGS="$1"
  }

  main "%1"

  [ "$COPY_USERNAME_ARGS" = "item-321" ]
  [ "$LAST_MESSAGE" = "Username copied to the clipboard." ]
}

@test "main shows error when selector fails" {
  # shellcheck disable=SC2329
  tmux_bw_has_session() {
    return 0
  }

  # shellcheck disable=SC2329
  tmux_bw_selector() {
    return "$TMUX_BW_SELECTOR_ERROR"
  }

  main "%1"

  [ "$LAST_MESSAGE" = "Selector failed." ]
}

@test "main dispatches paste totp with selected item id and target pane" {
  # shellcheck disable=SC2329
  tmux_bw_has_session() {
    return 0
  }

  # shellcheck disable=SC2329
  tmux_bw_selector() {
    printf '%s\n%s\n' "$BW_PASTE_TOTP" "item-totp-1"
  }

  # shellcheck disable=SC2329
  tmux_bw_paste_totp() {
    PASTE_TOTP_ARGS="$1|$2"
  }

  main "%5"

  [ "$PASTE_TOTP_ARGS" = "item-totp-1|%5" ]
}

@test "main shows success message after copy totp" {
  # shellcheck disable=SC2329
  tmux_bw_has_session() {
    return 0
  }

  # shellcheck disable=SC2329
  tmux_bw_selector() {
    printf '%s\n%s\n' "$BW_COPY_TOTP" "item-totp-2"
  }

  # shellcheck disable=SC2329
  tmux_bw_copy_totp() {
    COPY_TOTP_ARGS="$1"
  }

  main "%1"

  [ "$COPY_TOTP_ARGS" = "item-totp-2" ]
  [ "$LAST_MESSAGE" = "TOTP copied to the clipboard." ]
}
