#!/bin/sh
input=$(cat)

# Debug: dump all keys to stderr so we can see what's available
# echo "$input" | jq '.' >&2

# Git branch - try multiple paths
branch=$(echo "$input" | jq -r '(.git.branch // .git_branch // .branch // empty)' 2>/dev/null)

# Fallback: get branch from git directly
if [ -z "$branch" ]; then
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
fi

# Context usage
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Session cost
cost=$(echo "$input" | jq -r '.cost.total_cost // empty')

# Build output
parts=""

# Git branch in yellow (matching fish prompt accent)
if [ -n "$branch" ]; then
    parts=$(printf '\033[33m %s\033[0m' "$branch")
fi

# Context usage in dim
if [ -n "$used" ]; then
    used_int=$(printf '%.0f' "$used")
    parts=$(printf '%s  \033[2mctx:%s%%\033[0m' "$parts" "$used_int")
fi

# Cost in dim
if [ -n "$cost" ] && [ "$cost" != "0" ]; then
    parts=$(printf '%s  \033[2m$%s\033[0m' "$parts" "$cost")
fi

printf '%s' "$parts"
