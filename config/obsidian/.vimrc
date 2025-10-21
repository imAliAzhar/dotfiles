" symlink:
" ln -n obsidian.vimrc  /Users/imaliazhar/Library/Mobile Documents/iCloud~md~obsidian/Documents/Gringotts/.obsidian.vimrc

"Enter adds a new line below
nnoremap <CR> o<Esc>

"\ adds a new line above
nnoremap \ O<Esc>

" Have j and k navigate visual lines rather than logical ones
nnoremap j gj
nnoremap k gk

" I like using H and L for beginning/end of line
nmap H ^
nmap L $

" Quickly remove search highlights
nmap <F9> :nohl

" Yank to system clipboard
set clipboard=unnamed

" Go back and forward with Ctrl+O and Ctrl+I
" (make sure to remove default Obsidian shortcuts for these to work)
exmap back obcommand app:go-back
nmap <C-o> :back
exmap forward obcommand app:go-forward
nmap <C-i> :forward
