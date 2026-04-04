#!/bin/sh
# Manages .claude/recent-files for Claude Code PostToolUse hook
# Reads JSON from stdin (piped by Claude Code hook)
# Format: filepath:line

RECENT_FILE=".claude/recent-files"
MAX_LINES=20

# Extract both values in one jq call, tab-separated
parsed=$(jq -r '[.tool_input.file_path // "", (.tool_input.new_string // .tool_input.content // "" | split("\n")[0])] | @tsv')

filepath=$(printf '%s' "$parsed" | cut -f1)
first_line=$(printf '%s' "$parsed" | cut -f2)

[ -z "$filepath" ] && exit 0

rel=$(grealpath --relative-to=. "$filepath" 2>/dev/null || echo "$filepath")

line=""
if [ -n "$first_line" ] && [ -f "$filepath" ]; then
  line=$(grep -nF "$first_line" "$filepath" 2>/dev/null | head -1 | cut -d: -f1)
fi

if [ -n "$line" ]; then
  entry="${rel}:${line}"
else
  entry="$rel"
fi

touch "$RECENT_FILE"
grep -vF "$entry" "$RECENT_FILE" | { cat; echo "$entry"; } > "$RECENT_FILE.tmp"
tail -"$MAX_LINES" "$RECENT_FILE.tmp" > "$RECENT_FILE"
rm "$RECENT_FILE.tmp"
