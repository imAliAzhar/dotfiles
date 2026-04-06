function rewise-german-word-answer --description 'Show answer to ANKI_WORD_ID'
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

    set original (sed -n '3p' ~/Projects/anki/generated/$word_id-note)

    printf "%s" "$original" (set_color brblack)" => "(set_color normal)

    cat ~/Projects/anki/generated/$word_id-ans | while read -l line
        echo (set_color yellow --bold)"$line"(set_color normal)
    end
end
