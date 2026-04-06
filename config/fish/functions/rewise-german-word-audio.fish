function rewise-german-word-audio --description 'Play audio for the sentence'
    if not test -d ~/Projects/anki/generated
        return 0
    end

    if test (count $argv) -gt 0
        set word_id $argv[1]
    else if test -n "$ANKI_WORD_ID"
        set word_id $ANKI_WORD_ID
    else
        echo "Error: No ID provided and ANKI_WORD_ID is not set"
        return 1
    end

    set file ~/Projects/anki/generated/$word_id-audio
    if not test -f $file
        echo "Error: File not found: $file"
        return 1
    end

    # Read filename and trim newline/whitespace
    set fname (string trim (cat $file))

    # Build absolute path to Anki media (use $HOME, not "~")
    set media_dir "$HOME/Library/Application Support/Anki2/User 1/collection.media"
    set mp3 "$media_dir/$fname"

    if not test -f "$mp3"
        echo "Error: Audio file not found: $mp3"
        return 1
    end

    echo "Playing audio for"
    rewise-german-word-answer $word_id
    afplay "$mp3" &
    disown
end
