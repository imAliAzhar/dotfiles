"Enter adds a new line below
nnoremap <CR> o<Esc>

"\ adds a new line above
nnoremap \ O<Esc>

"Toggle line comment
map <Leader>/ <Plug>CommentaryLine

"Save buffer
nnoremap <Leader>w :w<CR>

"Close buffer
nnoremap <Leader>q :bd<CR>

"Fuzzy search project files
nnoremap <Leader>f :Files<CR>

"Fuzzy search current directory files
nnoremap <Leader>F :Files %:h<CR>

"Fuzzy search buffers
nnoremap <Leader>p :Buffers<CR>

"Fuzzy search text
nnoremap ? :Rg<CR>

nnoremap <leader>e :Lf<CR>

"Quick switch to previous buffer
nnoremap <silent> <Leader><Leader> :b#<CR>

"Jump to last position
nnoremap <Leader>o <C-O>

"Edit zsh
nnoremap <leader>ve :vsplit $HOME/.config/zsh/settings.zsh<cr>

"Edit mappings
nnoremap <leader>ze :vsplit $MYVIMRC<cr>

"Source mappings
nnoremap <leader>vs :source $MYVIMRC<cr>

"Strong h and l
nnoremap H ^
nnoremap L $

