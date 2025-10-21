function copy_branch_name
    set branch (git rev-parse --abbrev-ref HEAD)

    if test -n "$branch"
        echo "$branch" | pbcopy
        echo "Copied to clipboard: $branch"
    else
        echo "Not in a Git repository!" >&2
    end
end
