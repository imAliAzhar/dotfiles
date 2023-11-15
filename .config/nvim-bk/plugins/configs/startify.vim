autocmd BufDelete * if empty(filter(tabpagebuflist(), '!buflisted(v:val)')) | Startify | endif

let g:startify_files_number = 5
let g:startify_session_dir = '$HOME/.config/nvim/sessions'

let g:startify_lists = [
      \ { 'type': 'bookmarks', 'header': ['   Bookmarks']  },
      \ { 'type': 'files',     'header': ['   Recents']    },
      \ { 'type': 'dir',       'header': ['   '. getcwd()] },
      \ { 'type': 'commands',  'header': ['   Commands']   },
      \ { 'type': 'sessions',  'header': ['   Sessions']   },
      \ ]

let g:startify_bookmarks = [
      \ {'v': '~/.config/nvim/init.vim'},
      \ {'z': '~/.config/zsh/general.zsh'},
      \ {'a': '~/Projects/@finn/finn-auto-app'},
      \ ]
