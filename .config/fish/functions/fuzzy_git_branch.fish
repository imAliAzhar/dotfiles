function fuzzy_git_branch
    # Get local branches with color
    set -l branches (git --no-pager branch --color=always)
    
    # Exit if no branches found
    if test (count $branches) -eq 0
        return
    end
    
    # Convert list to newline-separated string and pass to fzf
    set -l selected_branch (printf "%s\n" $branches | fzf --ansi +m)
    
    # Exit if nothing selected
    if test -z "$selected_branch"
        return
    end
    
    # Clean up selected branch (remove '*', trim spaces)
    set -l output (string trim (string replace -r '^\*?\s*' '' "$selected_branch"))
    
    # Insert into command line
    commandline -i "$output "
end
