#!/usr/bin/env bats

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

load_selector_script() {
  source "$PROJECT_ROOT/scripts/lib/selector.sh"
}

load_cache_script() {
  source "$PROJECT_ROOT/scripts/lib/config.sh"
  source "$PROJECT_ROOT/scripts/lib/vault.sh"
  source "$PROJECT_ROOT/scripts/lib/cache.sh"
}

load_main_script() {
  source "$PROJECT_ROOT/scripts/main.sh"
}
