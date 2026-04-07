function qc --description 'Quick Commands Launcher'
    set -l LOCAL_COMMANDS_FILE ".qc/commands.json"
    set -l GLOBAL_COMMANDS_FILE "$HOME/.config/qc/commands.json"
    set -l COMMANDS_FILE
    set -l COMMANDS_LOCATION

    if test -f "$LOCAL_COMMANDS_FILE"
        set COMMANDS_FILE "$LOCAL_COMMANDS_FILE"
        set COMMANDS_LOCATION (basename $PWD)
    else
        set COMMANDS_FILE "$GLOBAL_COMMANDS_FILE"
        set COMMANDS_LOCATION "global"
    end

    if not test -f "$COMMANDS_FILE"
        mkdir -p (dirname "$COMMANDS_FILE")
        echo '{"commands":[]}' > "$COMMANDS_FILE"
    end

    # Direct key execution
    if test (count $argv) -eq 1
        set -l key $argv[1]

        if test "$key" = n; or test "$key" = --new; or test "$key" = -n
            _qc_add "$COMMANDS_FILE"
            return
        end

        if test "$key" = --list; or test "$key" = -l
            jq -r '.commands[] | "[" + .key + "] " + .description' "$COMMANDS_FILE"
            return
        end

        set -l cmd (jq -r --arg key "$key" '.commands[] | select(.key == $key) | .command' "$COMMANDS_FILE")
        if test -z "$cmd"
            echo "No command found for key: $key"
            return 1
        end
        commandline -r "$cmd"
        return
    end

    # Interactive mode with fzf
    set -l scope_display "[$COMMANDS_LOCATION]"
    set -l selection (begin
        echo "[n] Add new command"
        jq -r '.commands[] | "[" + .key + "] " + .description' "$COMMANDS_FILE"
    end | fzf \
        --prompt="$scope_display > " \
        --height=50% \
        --reverse \
        --border \
        --header="↑↓ Navigate | Enter: Select | Ctrl-C: Exit")

    or return 1

    set -l key (string match -r '^\[(.)\]' "$selection")[2]

    if test "$key" = n
        _qc_add "$COMMANDS_FILE"
        return
    end

    if test -n "$key"
        set -l cmd (jq -r --arg key "$key" '.commands[] | select(.key == $key) | .command' "$COMMANDS_FILE")
        if test -n "$cmd"
            commandline -r "$cmd"
        end
    end
end

function _qc_add
    set -l commands_file $argv[1]

    read -P "Enter key (single character): " key
    if test (string length "$key") -ne 1
        echo "Please enter a single character"
        return 1
    end

    set -l existing (jq -r --arg key "$key" '.commands[] | select(.key == $key) | .key' "$commands_file")
    if test -n "$existing"
        echo "Key '$key' already exists"
        return 1
    end

    read -P "Enter description: " description
    test -z "$description"; and return 1

    read -P "Enter command: " cmd
    test -z "$cmd"; and return 1

    set -l tmp (mktemp)
    jq --arg key "$key" --arg desc "$description" --arg cmd "$cmd" \
        '.commands += [{"key": $key, "description": $desc, "command": $cmd}]' \
        "$commands_file" > "$tmp"; and mv "$tmp" "$commands_file"

    echo "Command added — run with: qc $key"
end
