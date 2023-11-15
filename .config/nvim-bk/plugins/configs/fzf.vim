let g:fzf_preview_window = 'right:70%'
command! -bang -nargs=? -complete=dir Files
      \ call fzf#vim#files(<q-args>, {'options': [
      \ '--preview-window', 'right:70%',
      \ '--preview', '~/.config/nvim/plugins/repos/fzf.vim/bin/preview.sh {}',
      \]}, <bang>0)
