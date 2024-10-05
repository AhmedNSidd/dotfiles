" PLUGINS
call plug#begin()
"" Plugin for colorscheme
Plug 'catppuccin/vim', { 'as': 'catppuccin' }

"" Plugin for dynamically changing colorscheme if it's day/night
Plug 'vimpostor/vim-lumen'
let g:lumen_light_colorscheme = 'catppuccin_latte'
let g:lumen_dark_colorscheme = 'catppuccin_mocha'

"" Plugin for linting / fixing asynchronously
Plug 'dense-analysis/ale'
let g:ale_linters = {'go': ['gopls', 'golangci-lint']}
let g:ale_fixers = {'go': ['goimports', 'golines']}
let g:ale_go_golines_options = '--shorten-comments'
let g:ale_lint_on_insert_leave = 0 " Turn off linting when leaving insert, causes delay otherwise
let g:ale_fix_on_save = 1 " Automatically run fixers when we save file

"" Plugin for fuzzy searching
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'

"" Plugin for diffing two separate blocks of text
Plug 'AndrewRadev/linediff.vim'

"" Plugin for running Git commands conveniently
Plug 'tpope/vim-fugitive'

"" Plugin for working with Git diffs (& their hunks)
Plug 'airblade/vim-gitgutter'

"" Plugin for working with Golang projects
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
let g:go_fmt_autosave = 0 " Disable auto-formatting (handled by ALE)
let g:go_metalinter_enabled = [] " Disable linting (handled by ALE)
let g:go_test_timeout = '30s' " Increase test timeout time from 10s

call plug#end()

" Set leader key to spacebar
let mapleader = " "

set autowrite

" Enable true color support
set termguicolors

" Change vim's working directory to the one that's currently being viewed in
" netrw
let g:netrw_keepdir = 0

" Keybindings
nmap <silent> gr :ALEFindReferences -quickfix<CR>
"" Shorcuts for navigating through quickfix list quickly
nnoremap <M-n> :cnext<CR>
nnoremap <M-p> :cprevious<CR>

" Set specific options for vimdiff
set diffopt=internal,filler,closeoff,algorithm:patience

" Format the diff output to make it easier to read:
" 1. Enable text wrapping
augroup DiffFormatting 
  autocmd!
  autocmd VimEnter * if &diff | execute 'windo set wrap' | endif
  autocmd OptionSet diff if &diff | setlocal wrap | endif
augroup END

