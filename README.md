# tmux-bitwarden

![License](https://img.shields.io/github/license/Alkindi42/tmux-bitwarden)
[![CI](https://github.com/Alkindi42/tmux-bitwarden/actions/workflows/ci.yaml/badge.svg?branch=main)](https://github.com/Alkindi42/tmux-bitwarden/actions/workflows/ci.yaml)

Search and access your Bitwarden vault directly inside tmux using fuzzy search.

Quickly search login items and paste credentials without leaving your terminal.

## Features

- 🔍 Fuzzy search Bitwarden items with `fzf`
- 👀 Preview username and URIs before selecting
- 🔐 Secure vault access through the Bitwarden CLI
- ⚡ Fast search with optional caching
- ⌨️ Keyboard-driven workflow
- 📋 Paste or copy credentials instantly
- 🔄 Refresh cache without leaving the selector
- 🖥 Popup or split pane interface

## Requirements

You need the following tools installed:

- [Bitwarden CLI](https://bitwarden.com/help/cli/)
- [jq](https://stedolan.github.io/jq/)
- [fzf](https://github.com/junegunn/fzf)
- Bash >= 4
- tmux >= 3.0

## Installation

### Using Tmux Plugin Manager (recommended)

Add the plugin to your .tmux.conf:

```bash
set -g @plugin 'Alkindi42/tmux-bitwarden'
```

Then, install it:

```bash
prefix + I
```

## Usage

Press: `prefix + b` to open the Bitwarden selector.

You can then:

- search your vault items
- preview item details
- paste or copy credentials

## Key Bindings

Available inside the **selector**:

| Key | Action |
|-----|-----------------------------------------|
| `Enter` | Paste password into the active pane |
| `Ctrl-y` | Copy password to clipboard |
| `Ctrl-u` | Paste username into the active pane |
| `Alt-u` | Copy username to clipboard |
| `Ctrl-r` | Refresh cached items |

## Authentication

Before using the plugin, you only need to log in to Bitwarden using the CLI:

```bash
bw login
```

_No manual `BW_SESSION` export is required._

## Configuration

All options are optional.

### Default configuration

The plugin works out of the box with the following defaults:

| Option | Default |
|------|------|
| `@bw-key` | `b` |
| `@bw-ui` | `popup` |
| `@bw-ui-split-size` | `20` |
| `@bw-ui-popup-width` | `80%` |
| `@bw-ui-popup-height` | `80%` |
| `@bw-cache` | `true` |
| `@bw-cache-ttl` | `86400` |
| `@bw-cache-file` | `~/.cache/tmux-bitwarden/items.json` |

---

### Example configuration

```tmux
set -g @bw-key 'b'
set -g @bw-ui 'popup'
set -g @bw-cache 'true'
set -g @bw-cache-ttl '86400'
```

### UI options

| Option | Description |
|------|------|
| `@bw-ui` | `popup` or `split` |
| `@bw-ui-split-size` | Height of the split pane |
| `@bw-ui-popup-width` | Popup width (%) |
| `@bw-ui-popup-height` | Popup height (%) |

Example:

```tmux
set -g @bw-ui 'split'
set -g @bw-ui-split-size '20'
set -g @bw-ui-popup-height '90'
```

### Cache options

| Option | Description |
|------|------|
| `@bw-cache` | Enable or disable caching |
| `@bw-cache-ttl` | Cache duration in seconds |
| `@bw-cache-file` | Cache file location |

```tmux
set -g @bw-cache 'true'
set -g @bw-cache-ttl '86400'
```

You can refresh the cache anytime inside the selector with `Ctrl-r`.

## Security

- Passwords are **never stored in the cache**
- Only metadata (name, username, URIs) is cached
- Passwords are retrieved **only when required**
- Vault access is handled by the Bitwarden CLI session

## License

This project is licensed under the [MIT License](LICENSE).
