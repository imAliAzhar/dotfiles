(shells |
    enumerate  |
    each { |it| $"(if $it.item.active {'*'} else  {' '} )($it.index): ($it.item.path)" |
        str replace $nu.home-path '~'
    } |
    fzf --ansi |
    parse "{index}: {rest}" |
    get index |
    into int |
    g $in.0
)