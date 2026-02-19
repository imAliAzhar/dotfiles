#!/bin/bash

# Get the directory where this script lives
LAUNCHD_DIR="$(cd "$(dirname "$0")" && pwd)"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"

# Ensure LaunchAgents directory exists
mkdir -p "$LAUNCH_AGENTS_DIR"

# Find all plist files in subdirectories (not in root)
find "$LAUNCHD_DIR" -mindepth 2 -name "*.plist" | while read -r plist; do
	filename=$(basename "$plist")
	target="$LAUNCH_AGENTS_DIR/$filename"

	# Unload existing agent if running
	launchctl unload "$target" 2>/dev/null

	# Remove existing symlink or file
	rm -f "$target"

	# Create symlink to the plist file
	ln -s "$plist" "$target"
	echo "Symlinked: $filename"

	# Load the launch agent
	launchctl load "$target"
	echo "Loaded: $filename"
done
