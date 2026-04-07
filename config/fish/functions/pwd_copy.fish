function pwd_copy
    pwd | string replace $HOME '~' | tr -d '\n' | pbcopy
end
