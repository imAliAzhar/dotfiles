function rewise-german-word --description 'Show a random (or chosen) German word to revise'
    if not test -d ~/Projects/anki/generated
        return 0
    end

    # Increase this number to increase the pool size
    set cap 20

    if test -n "$argv[1]"
        set idx $argv[1]
    else
        set idx (shuf -i 1-$cap -n 1)
    end

    echo "  Word #$idx"
    cat ~/Projects/anki/generated/$idx-note

    set -gx ANKI_WORD_ID $idx
end
