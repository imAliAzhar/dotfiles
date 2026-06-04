# tmux-leap

[leap.nvim](https://codeberg.org/andyg/leap.nvim)-style motion jumping for tmux.

Jump to visible text in the current tmux pane with Leap's 2-character search,
preview labels, grouped labels, target ordering, smartcase, and whitespace/EOL
aliases ported from `leap.nvim`.

## Usage

1. Press the configured tmux key (default: `prefix + /`, set in these dotfiles to `prefix + s`).
2. Type the first search character; preview labels appear after candidate pairs.
3. Type the second character.
4. Press the active label to enter copy mode with the cursor on that target and a selection started there.

Leap-compatible details:

- Labels use leap.nvim's default order: `sfnjklhod...`.
- Matches are ranked from the current tmux/copy-mode cursor, prioritizing the current line and forward targets.
- `<space>` is equivalent to whitespace/newline, so `x<space>` targets `x` at EOL and `<space><space>` targets empty lines.
- Repeated same-character pairs (for example `aa` in `aaaa`) only target the start of the run, like leap.nvim.
- More matches than labels are split into groups; use `<space>` / `<backspace>` to move groups.

## Requirements

- tmux ≥ 3.2 (`display-popup` with `-b none`)
- LuaJIT

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

# Trigger directly from copy mode / scrollback (default: s)
set -g @leap-copy-key "s"

# Optional leap.nvim-style options
set -g @leap-labels "sfnjklhodweimbuyvrgtaqpcxz/SFNJKLHODWEIMBUYVRGTAQPCXZ?"
set -g @leap-safe-labels ""     # empty matches this repo's Neovim config (no autojump)
set -g @leap-ignorecase "1"
set -g @leap-smartcase "1"
set -g @leap-case-sensitive "" # set to 1/0 to force either mode
```

## How it works

1. `leap.tmux` sets up key bindings.
2. `scripts/leap.sh` captures the visible pane, passes cursor/options to a borderless popup, then moves the copy-mode cursor to the chosen `row:col`.
3. `scripts/leap_popup.lua` is the Leap port: it renders the pane in the popup, runs the two-phase search/label selection, and writes the selected target.
