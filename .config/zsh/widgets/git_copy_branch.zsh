copy_branch_name() {
  local branch
  branch=$(git rev-parse --abbrev-ref HEAD)
  echo "git rev-parse --abbrev-ref HEAD"

  if [[ -n "$branch" ]]; then
    echo -n "$branch" | pbcopy
    echo "Copied to clipboard: $branch"
  else
    echo "Not in a Git repository!" >&2
  fi
}
