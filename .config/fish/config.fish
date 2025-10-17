if status is-interactive
    # Commands to run in interactive sessions can go here

    # Abbreviations
    # --------------------------------------------------------------------------
    abbr --add g git
    abbr --add gco git checkout
    abbr --add gcb git checkout -b
    abbr --add gs git status -sb
    abbr --add gcan git commit --amend --no-edit
    abbr --add ls eza
    abbr --add venv source venv/bin/activate
    abbr --add y yarn
    abbr --add lf yazi
    abbr --add dot GIT_WORK_TREE=~ GIT_DIR=~/.dotfiles
    abbr --add t tmux-fzf-session
    abbr --add t select-tmux-session

    abbr --add ga git add
    abbr --add gc git commit -m
    abbr --add gl git "log --pretty=format:'%C(yellow)%h%Creset %C(white)%s %C(dim #6e738d)%an %ar %Creset' --date=format:\"%b %d, '%y\""
    abbr --add gco git checkout
    abbr --add gac git commit -am
    abbr --add gcan git commit --amend --no-edit
    abbr --add gbr git branch
    abbr --add gpop git stash pop
    abbr --add gch git cherry-pick -e
    abbr --add gdc git reset HEAD^
    abbr --add gdd git reset --hard HEAD
    abbr --add grs git checkout --
    abbr --add gdelete git reset --hard HEAD~
    abbr --add gra git commit --amend --no-edit
    abbr --add grc git rebase --continue
    abbr --add gignore git update-index --skip-worktree
    abbr --add gunignore git update-index --no-skip-worktree

    abbr --add aa rewise-german-word-audio
    abbr --add at rewise-german-word-answer
    abbr --add ai rewise-german-word-explain

    # # SDKs and toolchains
    # --------------------------------------------------------------------------

    # Node
    fnm env --use-on-cd --shell fish | source

    # Maestro
    export MAESTRO_CLI_AI_MODEL=gpt-4.1
    export MAESTRO_DRIVER_STARTUP_TIMEOUT=30000
    fish_add_path ~/.maestro/bin

    # Android SDK / Java
    set -gx JAVA_HOME /Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home
    set -gx ANDROID_HOME $HOME/Library/Android/sdk
    fish_add_path $ANDROID_HOME/emulator
    fish_add_path $ANDROID_HOME/platform-tools

    # Rust
    fish_add_path $HOME/.cargo/bin

    # Shell plugins
    # --------------------------------------------------------------------------

    # Zoxide
    zoxide init fish | source

    # FZF
    set -gx FZF_DEFAULT_OPTS \
        "--bind=ctrl-j:accept" \
        --ansi \
        "--header=" \
        "--padding=5%" \
        "--prompt='  '\$' '" \
        "--pointer=▸" \
        "--color=pointer:bright-yellow,gutter:-1,bg+:-1,fg+:bright-yellow:bold"

    # Lazygit
    set -gx LG_CONFIG_FILE "$HOME/.config/lazygit/config.yml,$HOME/.config/lazygit/theme.yml"

    # Atuin
    set -gx ATUIN_NOBIND true
    atuin init fish | source

    # bind to ctrl-r in normal and insert mode, add any other bindings you want here too
    bind \cr _atuin_search
    bind -M insert \cr _atuin_search

    # Environment variables
    # --------------------------------------------------------------------------

    # Load secrets if available
    if test -f ~/.config/fish/secrets.fish
        source ~/.config/fish/secrets.fish
    end

    set -gx EDITOR nvim

    # PATH overrides
    # --------------------------------------------------------------------------
    fish_add_path -m ~/.local/bin

    # Initialize TMUX
    # --------------------------------------------------------------------------
    if test "$TERM_PROGRAM" = WezTerm
        select-tmux-session
    end
end
