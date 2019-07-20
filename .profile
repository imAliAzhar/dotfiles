export PATH=~/.local/bin:~/.npm/node_modules/bin:$PATH


# Start graphical server if i3 not already running.
[ "$(tty)" = "/dev/tty1" ] && ! pgrep -x i3 >/dev/null && exec startx
