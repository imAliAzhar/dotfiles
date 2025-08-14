function ip
    ipconfig getifaddr en0 | tr -d '\n' | pbcopy
    echo -n "Copied IP to clipboard: "
    pbpaste
end
