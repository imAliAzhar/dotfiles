Which distribution of Emacs to use on macOS?

https://ylluminarious.github.io/2019/05/23/emacs-mac-port-introduction/
https://www.reddit.com/r/emacs/comments/1heyuq4/comment/m27fo42


https://github.com/railwaycat/homebrew-emacsmacport/tree/master
$ brew tap railwaycat/emacsmacport
$ brew install emacs-mac

https://github.com/railwaycat/homebrew-emacsmacport/blob/master/docs/emacs-start-helpers.md#helper-2
$ osacompile -o Emacs.app -e 'tell application "Finder" to open POSIX file "'"$(brew --prefix)"'/opt/emacs-mac/Emacs.app"'

