function fish_prompt
    # Store the last command's status
    set -l last_status $status

    # Print empty line after each command
    echo

    # Determine prompt prefix based on SHLVL
    if test $SHLVL -eq 1
        set prompt_char '$'
    else
        set prompt_char (string repeat -n (math $SHLVL - 1) '▸')
    end


    if test $last_status -ne 0
      string join "" -- (set_color red) "[$last_status]" (set_color normal) " "
    else
      string join "" -- (set_color yellow) " $prompt_char " (set_color normal)
    end
end
