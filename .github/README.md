# Dotfiles

Dotfiles for my various setups over the years.

## Setup

Clone this github repository:

```
git clone --bare https://github.com/imaliazhar/dotfiles.git $HOME/.dotfiles
```

Define temporary alias in the current shell:

```
alias dot="GIT_WORK_TREE=~ GIT_DIR=~/.dotfiles"
```

Checkout the actual content from the git repository to your `$HOME`

```
dot git checkout
```

!! Checking out will overwrite existing files! Backup current files if its not a fresh install.

Hide untracked files in git status (optional).

```
dot git config status.showUntrackedFiles no
```

---

Git setup copied from [this](https://www.atlassian.com/git/tutorials/dotfiles) article.
