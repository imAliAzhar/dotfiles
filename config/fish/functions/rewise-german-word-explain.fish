function rewise-german-word-explain --description 'Explain the sentence with AI'
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

    rewise-german-word-audio $word_id
    set file ~/Projects/anki/explanations/$word_id-exp

    if not test -f $file
        echo "Error: File not found: $file"
        return 1
    end

    echo
    echo -e (cat $file)
end
