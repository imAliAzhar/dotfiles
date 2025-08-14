if status is-interactive
    # Commands to run in interactive sessions can go here

    # Abbreviations
    # --------------------------------------------------------------------------
    abbr --add g git
    abbr --add gs git status -sb
    abbr --add gcan git commit --amend --no-edit
    abbr --add ls eza
    abbr --add venv source venv/bin/activate
    abbr --add y yarn
    abbr --add lf yazi
    abbr --add dot GIT_WORK_TREE=~ GIT_DIR=~/.dotfiles
end
