git_copy_commit() {
  local ref=${1:-HEAD}
  local hash

  echo "git rev-parse $ref"

  hash=$(git rev-parse "$ref")
  echo -n "$hash" | pbcopy
  echo "Copied to clipboard: $hash"
}
