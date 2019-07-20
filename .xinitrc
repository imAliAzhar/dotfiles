[[ -f ~/.Xmodmap ]] && xmodmap ~/.Xmodmap
xrdb .Xresources
exec i3
