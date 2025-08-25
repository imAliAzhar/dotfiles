function select-tmux-session --description 'FZF-based tmux session picker'
    # Fish does not support associative arrays, so we use parallel arrays instead.
    set session_names_list
    set session_dirs_list
    set active_status_list

    # Get a list of existing tmux sessions, sorted by last attached time.
    for line in (tmux list-sessions -F '#{session_last_attached} #{session_name} #{pane_start_path}' | sort -nr)
        # @fish-lsp-disable-next-line 4004 
        echo $line | read -l _timestamp session_name session_dir
        set -a session_names_list $session_name
        set -a session_dirs_list $session_dir
        set -a active_status_list true
    end

    set misc_sessions home dotfiles obsidian
    set misc_session_dirs_list $HOME $HOME/.config "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Gringotts"
    #
    for i in (seq (count $misc_sessions))
        if contains $misc_sessions[$i] $session_names_list
            continue
        end

        set -a session_names_list $misc_sessions[$i]
        set -a session_dirs_list $misc_session_dirs_list[$i]
        set -a active_status_list false
    end

    for dir in ~/Projects/*
        if not test -d $dir
            continue
        end

        set session_name (string replace -a '.' '_' (basename $dir))

        if contains $session_name $session_names_list
            continue
        end

        set -a session_names_list $session_name
        set -a session_dirs_list $dir
        set -a active_status_list false
    end

    set formatted_session_list

    set green (set_color green)
    set nc (set_color normal)

    for i in (seq (count $session_names_list))
        if test $active_status_list[$i] = true
            set -a formatted_session_list "$green• $session_names_list[$i]$nc"
        else
            set -a formatted_session_list "  $session_names_list[$i]"
        end
    end

    set selected_session (printf "%s\n" $formatted_session_list | fzf --no-info --no-scrollbar)

    if test -z "$selected_session"
        return
    end

    # Remove the leading "• " or spaces added for formatting
    set selected_session (string sub -s 3 $selected_session)

    set selected_idx (contains -i $selected_session $session_names_list)

    if not test "$active_status_list[$selected_idx]" = true
        cd $session_dirs_list[$selected_idx]

        set tmux_args -d -s $selected_session -n $EDITOR

        # For dotfiles session, set GIT environment variables
        if test "$selected_session" = dotfiles
            set -a tmux_args -e GIT_WORK_TREE="$HOME" -e GIT_DIR="$HOME/.dotfiles"
        end

        tmux new-session $tmux_args

        # For project-based sessions, start with editor open
        if test "$selected_session" != home
            tmux send-keys -t $selected_session:1.1 $EDITOR Enter
        end
    end

    if test -z "$TMUX"
        tmux attach -t $selected_session
    else
        tmux switch-client -t $selected_session
    end
end
