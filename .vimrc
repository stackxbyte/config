"=============================================
"              Plugin Manager
"=============================================
" Install vim-plug if missing
if empty(glob('~/.vim/autoload/plug.vim'))
    silent execute "!curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
" Core
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/fzf.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'preservim/nerdtree'
Plug 'voldikss/vim-floaterm'
Plug 'neoclide/coc.nvim' , {'branch': 'release'}
Plug 'jiangmiao/auto-pairs'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Theme
Plug 'morhetz/gruvbox'
call plug#end()

"=============================================
"              Basic Settings
"=============================================
set nocompatible
syntax on
filetype plugin indent on

" Encoding
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8

" Search
set hlsearch
set incsearch
set ignorecase
set smartcase

" Indentation
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set autoindent
set smartindent

" UI
set number relativenumber
set wildmode=longest,list,full
set noswapfile
set nobackup
set nowritebackup
set showcmd
set cursorline
set scrolloff=8
set laststatus=2
set noshowmode
set hidden
set mouse=a
set termguicolors
set background=dark
set updatetime=300
set signcolumn=yes

" Undo persistence
silent! call mkdir(expand('~/.vim/undo'), 'p')
set undofile
set undodir=~/.vim/undo//

" Leader Key
let mapleader=","

" Exit insert mode quickly
imap jjkk <Esc>

" Move in insert mode using CTRL+hjkl / Alt+hjkl
inoremap <A-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <A-l> <Right>
cnoremap <A-h> <Left>
cnoremap <C-j> <Down>
cnoremap <C-k> <Up>
cnoremap <A-l> <Right>
set whichwrap=lh

"=============================================
"              Abbreviations
"=============================================
cnoreabbrev W! w!
cnoreabbrev Q! q!
cnoreabbrev Wq wq
cnoreabbrev WQ wq
cnoreabbrev wQ wq
cnoreabbrev W w
cnoreabbrev Q q
cnoreabbrev Qall qall
cnoreabbrev Qall! qall!

"=============================================
"              Arrow Key Mapping
"=============================================
"disable all arrow keys - use hjkl
no <down> <Nop>
no <left> <Nop>
no <right> <Nop>
no <up> <Nop>
ino <down> <Nop>
ino <left> <Nop>
ino <right> <Nop>
ino <up> <Nop>
vno <down> <Nop>
vno <left> <Nop>
vno <right> <Nop>
vno <up> <Nop>

"=============================================
"              Split Windows
"=============================================
noremap <Tab>h :<C-u>split<CR>
noremap <Tab>v :<C-u>vsplit<CR>

nnoremap <C-t> :tabnew<CR>

" Split window navigation
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l
noremap <C-h> <C-w>h

"=============================================
"              Visual Mode
"=============================================
vmap < <gv
vmap > >gv

" Move selected lines up/down
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

"=============================================
"              Autocomplete
"=============================================
set completeopt=menu,menuone,noselect

"=============================================
"             Theme Configuration
"=============================================
colorscheme gruvbox
let g:gruvbox_contrast_dark = 'hard'

"=============================================
"             NERDTree Configuration
"=============================================
nnoremap <F6> :NERDTreeToggle<CR>
let g:NERDTreeShowHidden = 1

"=============================================
"             Airline Configuration
"=============================================
let g:airline_powerline_fonts = 1
let g:airline_theme='gruvbox'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#hunks#enabled = 0
let g:airline#extensions#whitespace#enabled = 0
let g:airline_left_sep = ' '
let g:airline_right_sep = ' '
let g:airline_section_x = '%{&filetype}'
let g:airline_section_y = '%{&fileformat} ▌ %{&fileencoding}'
let g:airline_section_z = '%l:%c'

"=============================================
"             FZF Configuration
"=============================================
let g:fzf_preview_window = 'right:50%'
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6 } }
nnoremap <C-p> :Files<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>g :Rg<CR>

"=============================================
"             Floaterm Configuration
"=============================================
let g:floaterm_keymap_toggle = '<F7>'
let g:floaterm_keymap_next   = '<F8>'

"=============================================
"         Compile And Run Code
"=============================================
function! CompileAndRun() abort
    let l:ext = expand('%:e')
    if l:ext == 'c'
        let l:out = expand('%:r') . '.out'
        exec "!gcc " . expand('%') . " -o " . l:out
        if v:shell_error == 0
            exec "!./" . l:out
        endif
    elseif l:ext == 'cpp'
        let l:out = expand('%:r') . '.out'
        exec "!g++ " . expand('%') . " -o " . l:out
        if v:shell_error == 0
            exec "!./" . l:out
        endif
    elseif l:ext == 'py'
        exec "!python3 " . expand('%:p')
    else
        echo "Unsupported file type: " . l:ext
    endif
endfunction

nnoremap <F5> :call CompileAndRun()<CR>

"=============================================
"          Coc Nvim Configuration
"=============================================
" Extensions auto-installed on startup on any system.
" coc-clangd fetches its own clangd binary, giving C/C++ completion
" without needing ccls/clangd installed via the system package manager.
let g:coc_global_extensions = ['coc-clangd']

" Use tab for trigger completion
inoremap <silent><expr> <TAB>
    \ coc#pum#visible() ? coc#pum#next(1) :
    \ CheckBackspace() ? "\<Tab>" :
    \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                            \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <silent><expr> <c-space> coc#refresh()

" Navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" Show the diagnostic message at the cursor position (<leader> = ,)
nmap <silent> <leader>d <Plug>(coc-diagnostic-info)

" Go to code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Show documentation
nnoremap <silent> K :call ShowDocumentation()<CR>
function! ShowDocumentation()
    if CocAction('hasProvider', 'hover')
        call CocActionAsync('doHover')
    else
        call feedkeys('K', 'in')
    endif
endfunction

" Highlight symbol references
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

" Code actions
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>ac  <Plug>(coc-codeaction-cursor)
nmap <leader>qf  <Plug>(coc-fix-current)

" Text objects for functions/classes
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Add :Format command
command! -nargs=0 Format :call CocActionAsync('format')
command! -nargs=0 OR   :call CocActionAsync('runCommand', 'editor.action.organizeImport')

" CoCList shortcuts using space
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>