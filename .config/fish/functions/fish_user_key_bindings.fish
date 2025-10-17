function fish_user_key_bindings
    # Map `H` to move to beginning of line (equivalent to 0)
    bind -M default H beginning-of-line
    # Map `L` to move to end of line (equivalent to $)
    bind -M default L end-of-line

    # Execute this once per mode that emacs bindings should be used in
    fish_default_key_bindings -M insert

    # Then execute the vi-bindings so they take precedence when there's a conflict.
    # Without --no-erase fish_vi_key_bindings will default to
    # resetting all bindings.
    # The argument specifies the initial mode (insert, "default" or visual).
    fish_vi_key_bindings --no-erase insert

    # Bind `Ctrl-g` to fuzzy_git_branch and `Ctrl-e` to fuzzy_git_commit
    for mode in default insert
        bind -M default \cr history-pager
        bind -M $mode \cg fuzzy_git_branch
        bind -M $mode \eg fuzzy_git_commit
        bind -M $mode \ck rewise-german-word-explain
    end
end
