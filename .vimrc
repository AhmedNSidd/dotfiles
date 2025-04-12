" PLUGINS
call plug#begin()
"" Plugin for colorscheme
Plug 'catppuccin/vim', { 'as': 'catppuccin' }

if has("unix")
else
	"" Plugin for dynamically changing colorscheme if it's day/night
	Plug 'vimpostor/vim-lumen'
	let g:lumen_light_colorscheme = 'catppuccin_latte'
	let g:lumen_dark_colorscheme = 'catppuccin_mocha'
endif

"" Plugin for linting / fixing asynchronously
Plug 'dense-analysis/ale'
let g:ale_linters = {
\	'go': ['gopls', 'golangci-lint'],
\	'proto': ['buf-lint']
\}
let g:ale_fixers = {
\	'go': ['goimports', 'golines'],
\	'proto': ['buf-format']
\}
let g:ale_go_golines_options = '--shorten-comments --max-len=120'
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

"" Plugin for previewing markdown files
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}

"" Plugin for working with Golang projects
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
let g:go_fmt_autosave = 0 " Disable auto-formatting (handled by ALE)
let g:go_metalinter_enabled = [] " Disable linting (handled by ALE)
let g:go_test_timeout = '30s' " Increase test timeout time from 10s

"" Plugin for copying text in vim from remote connections
Plug 'ojroques/vim-oscyank', {'branch': 'main'}

call plug#end()

" Vim configurations
"" Set leader key to spacebar
let mapleader = " "
" Open splits on the bottom instead of top
"set splitbelow
" Open splits on the right instead of the left
set splitright
set autowrite
"" Enable true color support
set termguicolors

" Netrw configurations
"" Open vertical splits in netrw to the right instead of left
let g:netrw_altv = 1
" Change vim's working directory to the one that's currently being viewed in
" netrw
let g:netrw_keepdir = 0

" Custom commands
"" Open up a small terminal window
command Bterm botright terminal

" Keybindings
"" Shortcuts for copying to clipboard
nmap <leader>cc <leader>c_
vmap <leader>c <Plug>OSCYankVisual
"" Shortcuts for Explore / folder directory navigation
nnoremap <leader>ee :Explore<CR>
"" Shorcuts for navigating through quickfix list quickly
nnoremap <M-n> :cnext<CR>
nnoremap <M-p> :cprevious<CR>
"" Shortcuts for terminal
nnoremap <leader>tt :Bterm<CR>
"" Shortcuts for code navigation
nnoremap gr :ALEFindReferences -quickfix<CR>

" Set specific options for vimdiff
set diffopt=internal,filler,closeoff,algorithm:histogram

" Format the diff output to make it easier to read:
" 1. Enable text wrapping
augroup DiffFormatting 
  autocmd!
  autocmd VimEnter * if &diff | execute 'windo set wrap' | endif
  autocmd OptionSet diff if &diff | setlocal wrap | endif
augroup END

" Resize the terminal window to a smaller size whenever it's opened
autocmd TerminalWinOpen *
  \ if &buftype == 'terminal' |
  \   resize 9 |
  \   setlocal termwinsize=0x140 |
  \   setlocal nowrap |
  \ endif
