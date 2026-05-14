#!/usr/bin/env python3
"""
tmux-leap popup: renders captured pane content with jump labels, writes
the selected row:col to RESULT_FILE and exits.
"""
import os
import sys
import tty
import termios

LABELS = "asdghklqwertyuiopzxcvbnmfj;ASDGHKLQWERTYUIOPZXCVBNMFJ"

# ANSI helpers
LABEL   = "\033[38;5;214m\033[1m"   # bold orange — label character
PROMPT  = "\033[7m"                  # reverse video — status bar
RESET   = "\033[0m"
HIDE    = "\033[?25l"
SHOW    = "\033[?25h"


def getch() -> str:
    fd = sys.stdin.fileno()
    old = termios.tcgetattr(fd)
    try:
        tty.setraw(fd)
        return sys.stdin.read(1)
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old)


def expand_tabs(s: str, tabsize: int = 8) -> str:
    out, col = [], 0
    for c in s:
        if c == "\t":
            n = tabsize - (col % tabsize)
            out.append(" " * n)
            col += n
        else:
            out.append(c)
            col += 1
    return "".join(out)


def find_matches(lines: list[str], search: str) -> list[tuple[int, int]]:
    hits = []
    needle = search.lower()
    for row, line in enumerate(lines):
        col = 0
        ll = line.lower()
        while True:
            idx = ll.find(needle, col)
            if idx == -1:
                break
            hits.append((row, idx))
            col = idx + 1
    return hits


def at(row: int, col: int) -> str:
    return f"\033[{row + 1};{col + 1}H"


def render_content(lines: list[str], width: int) -> None:
    sys.stdout.write("\033[H")
    for line in lines:
        sys.stdout.write(expand_tabs(line)[:width].ljust(width))
        sys.stdout.write("\r\n")


def show_prompt(height: int, text: str) -> None:
    sys.stdout.write(at(height - 1, 0))
    sys.stdout.write(f"{PROMPT} leap> {text} {RESET}\033[K")
    sys.stdout.flush()


def main() -> None:
    content_file = os.environ.get("CONTENT_FILE", "")
    result_file  = os.environ.get("RESULT_FILE",  "")
    height = int(os.environ.get("PANE_HEIGHT", "24"))
    width  = int(os.environ.get("PANE_WIDTH",  "80"))

    try:
        with open(content_file) as f:
            raw = f.read()
    except OSError:
        sys.exit(1)

    lines = raw.split("\n")
    if lines and lines[-1] == "":
        lines = lines[:-1]
    lines = lines[: height - 1]  # reserve last row for the prompt

    sys.stdout.write(HIDE)
    try:
        render_content(lines, width)
        show_prompt(height, "")

        char1 = getch()
        if char1 in ("\x1b", "\x03", "\x04", "\r"):
            return
        show_prompt(height, char1)

        char2 = getch()
        if char2 in ("\x1b", "\x03", "\x04"):
            return

        search = char1 + char2
        matches = find_matches(lines, search)

        if not matches:
            show_prompt(height, f"{search}  [no matches]")
            getch()
            return

        # Assign a label to each match (up to len(LABELS))
        label_map: dict[str, tuple[int, int]] = {}
        for i, (row, col) in enumerate(matches):
            if i >= len(LABELS):
                break
            lbl = LABELS[i]
            label_map[lbl] = (row, col)
            sys.stdout.write(at(row, col))
            sys.stdout.write(f"{LABEL}{lbl}{RESET}")

        show_prompt(height, search)

        sel = getch()
        if sel not in label_map:
            return

        row, col = label_map[sel]
        with open(result_file, "w") as f:
            f.write(f"{row}:{col}\n")

    finally:
        sys.stdout.write(SHOW)
        sys.stdout.flush()


if __name__ == "__main__":
    main()
