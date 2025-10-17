function fuzzy_git_commit
    # One-line, colored commits: <hash> <subject> <author> <date>
    set -l commits (git log --color=always \
        --date=format:"%b %d, '%y" \
        --pretty=format:"%C(yellow)%h%Creset %C(white)%s %C(dim)%an %ad%Creset")

    if test (count $commits) -eq 0
        echo "No commits found"
        return
    end

    # Fuzzy select with ANSI color support
    set -l selected (printf "%s\n" $commits | fzf --ansi +m)

    if test -z "$selected"
        return
    end

    # First token is the short hash
    set -l commit_hash (string split ' ' -- "$selected")[1]

    # Insert at cursor
    commandline -i -- "$commit_hash"
end
