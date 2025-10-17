# Escape for a Lua double-quoted string: first backslashes, then double quotes
function lua_escape_dq
    set s $argv
    set s (string replace -a '\\' '\\\\' -- $s)
    set s (string replace -a '"' '\"' -- $s)
    echo $s
end

function notify_command_completion --on-event fish_postexec --description 'Notify when a command takes a long time to complete'
    if test "$CMD_DURATION" -gt 3000
        # Safely join argv and escape double quotes
        set -l cmd (string escape -- $argv)

        set -l safe_cmd (lua_escape_dq -- $cmd)
        hs -c "hs.alert.show(\"Command completed: $safe_cmd\", 2)" >/dev/null
    end
end
