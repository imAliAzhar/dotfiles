# tmux-leap

[leap.nvim](https://github.com/ggandor/leap.nvim)-style motion jumping for tmux.

Jump to any visible text in your tmux pane using a 2-character search. All matches are labelled — press a label key to land there in copy mode.

## Demo

```
$ git log --oneline
a1b2c3d (HEAD) add feature
d4e5f6a fix bug          ← press prefix+/ → type "fi" → press label → cursor jumps here
7g8h9i0 refactor
```

1. Press `prefix + /`
2. Type 2 characters (e.g. `fi`)
3. Every match gets a bold orange label (`a`, `s`, `d`, …)
4. Press the label key → copy mode opens with cursor at that word

## Requirements

- tmux ≥ 3.2 (`display-popup` with `-b none`)
- Python 3.6+

## Installation

### TPM

```tmux
set -g @plugin 'imAliAzhar/tmux-leap'
```

Press `prefix + I` to install.

### Manual (dotfiles)

```tmux
# in tmux.conf
run '~/.config/tmux/plugins/tmux-leap/leap.tmux'
```

## Configuration

```tmux
# Change trigger key (default: /)
set -g @leap-key "s"
```

## How it works

1. `leap.tmux` — sets up the keybinding on load
2. `scripts/leap.sh` — captures the visible pane, opens a borderless popup overlaid exactly on top of it, then positions the copy-mode cursor at the chosen location
3. `scripts/leap_popup.py` — renders the captured content inside the popup, reads 2 chars, finds all matches, overlays single-char labels, reads the selection, and writes `row:col` to a temp file
