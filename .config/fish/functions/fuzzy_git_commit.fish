function fuzzy_git_commit
    # Get list of commits (assuming `git l` is defined as a custom alias)
    set -l commits (git l --color=always)
    
    if test (count $commits) -eq 0
        return
    end
    
    # Let user pick a commit with fzf
    set -l selected (printf "%s\n" $commits | fzf --ansi +m)
    
    if test -z "$selected"
        return
    end
    
    # Extract the commit hash (first word)
    set -l commit_hash (string split ' ' "$selected")[1]
    
    # Insert commit hash into current command line at cursor
    commandline -i "$commit_hash "
end
