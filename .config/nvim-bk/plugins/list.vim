source $HOME/.config/nvim/plugins/plug.vim

call plug#begin('$HOME/.config/nvim/plugins/repos')

Plug 'vim-airline/vim-airline'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'tpope/vim-fugitive'
Plug 'mhinz/vim-startify'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'airblade/vim-rooter'
Plug 'ptzz/lf.vim'
Plug 'rbgrouleff/bclose.vim'
Plug 'rust-lang/rust.vim'
Plug 'Chiel92/vim-autoformat'
Plug 'sheerun/vim-polyglot'
Plug 'lifepillar/pgsql.vim'
Plug 'chriskempson/base16-vim'

call plug#end()

" Configs
" =======

" source $HOME/.config/nvim/plugins/configs/autoformat.vim
source $HOME/.config/nvim/plugins/configs/commentary.vim
source $HOME/.config/nvim/plugins/configs/airline.vim
source $HOME/.config/nvim/plugins/configs/coc.vim
source $HOME/.config/nvim/plugins/configs/fzf.vim
source $HOME/.config/nvim/plugins/configs/lf.vim
source $HOME/.config/nvim/plugins/configs/pgsql.vim
source $HOME/.config/nvim/plugins/configs/rooter.vim
source $HOME/.config/nvim/plugins/configs/startify.vim
