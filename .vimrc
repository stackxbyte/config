"=============================================
"    Move in insert mode using CTRL+hjkl
"=============================================
inoremap <A-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>
cnoremap <A-h> <Left>
cnoremap <C-j> <Down>
cnoremap <C-k> <Up>
cnoremap <C-l> <Right>
set whichwrap=lh


"=============================================
"                Abrivations
"=============================================

" Save and quite Abrivations
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
"             Arrow Key Mapping
"=============================================

" Move current line up down using arrow keys
"no <down> ddp 
"no <up> ddkP

" Normal Mode
no <left> <Nop>
no <right> <Nop>
no <down> <Nop> 
no <up> <Nop> 


" Insert Mode
ino <right> <Nop>
ino <left> <Nop>
ino <up> <Nop>
ino <down> <Nop>

" Visual Mode
vno <down> <Nop> 
vno <right> <Nop>
vno <left> <Nop>
vno <up> <Nop>

"=============================================
"               Basic Settings 
"=============================================

" Encodeing 
set encoding=UTF-8
set fileencoding=utf-8
set fileencodings=utf-8

" Highlight Search
set hlsearch

" Does Seaarch Incremently
set incsearch
set ignorecase
set smartcase

" Tab size 
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

" Convert Tab to space
set autoindent
set smartindent

" Line Number 
set number relativenumber

" Enable autocomplete ctrl+n to activate:
set wildmode=longest,list,full

set nocompatible
filetype off

" No Swap file
set noswapfile

" Show the command pressed in vim
set showcmd

" Line Barke & text wrap
set wrap
set linebreak
set cursorline

" Leader Key
let mapleader=","

" Exit from insert mode by pressing jjkk
imap jjkk <Esc> 


"=============================================
"              Auto Complete 
"=============================================

" Enable tab autocomplete
set completeopt=menu,menuone,preview
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"


"=============================================
"              Split Screen 
"=============================================

noremap <Tab>h :<C-u>split<CR>
noremap <Tab>v :<C-u>vsplit<CR>


"=============================================
"              New Tab Toggle  
"=============================================

" Open a new tab
nnoremap <C-t> :tabnew<CR>

"=============================================
"        Split Window Navigation 
"=============================================

noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l
noremap <C-h> <C-w>h

"=============================================
"         Visual Mode Navigation 
"=============================================

vmap < <gv
vmap > >gv

vnoremap J :m '>+1<CR>gv=gv  
vnoremap J :m '<-@<CR>gv=gv 

"=============================================
"            Pluggins For Vim
"=============================================

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim

" Calling Vundle to install Plugin
call vundle#begin()
Plugin 'tpope/vim-commentary'
Plugin 'sheerun/vim-polyglot'
Plugin 'junegunn/fzf.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'voldikss/vim-floaterm'
Plugin 'morhetz/gruvbox'
Plugin 'neoclide/coc.nvim'
Plugin 'jiangmiao/auto-pairs'
Plugin 'bagrat/vim-buffet'
Plugin 'ryanoasis/vim-devicons'
"Plugin 'mhinz/vim-startify'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
" Theme Plugins 
Plugin 'ghifarit53/tokyonight-vim'
Plugin 'bluz71/vim-nightfly-colors'
Plugin 'fholgado/Molokai2'
Plugin 'NLKNguyen/papercolor-theme'



call vundle#end()            
filetype plugin indent on

"=============================================
"           Theme Configration 
"=============================================

" Color Scheme 
colorscheme tokyonight  
set background=dark
set noshowmode
set laststatus=2
"=============================================
"          Nerd Tree Configration 
"=============================================

" Always open NERDTree
" autocmd VimEnter * NERDTree

" Close NERDTree when last buffer is deleted
" autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists("b:NERDTree") | quit | endif

" Move cursor to the editor area after NERDTree is opened
" autocmd VimEnter * wincmd p

nnoremap <F6> :NERDTreeToggle<CR>

"=============================================
"          Airline Config 
"=============================================
let g:airline_powerline_fonts = 1

" enable the extension
let g:airline#extensions#tabline#enabled = 1

let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline_theme='tokyonight'


" ---- Customize Airline Sections ----
" Section a: Show the current mode (Normal, Insert, etc.)
let g:airline_section_a = airline#section#create(['mode'])

" Section b: Show the Git branch (if in a Git repo) and file name (with readonly flag)
let g:airline_section_c = airline#section#create(['branch', 'readonly'])

" Section c: Show the filename only, without the full path
let g:airline_section_b = '%t'

let g:airline_section_x = ' [%{&filetype}]'


" Section y: Show the current line and column number
let g:airline_section_y = '%{&fileencoding} ▌ %{&fileformat}'

" Section z: Show file encoding and file format
let g:airline_section_z = '%l:%c'

" ---- Custom Function to Display Current Time ----
" Add current time to the status line in section x

" ---- Performance Optimizations ----
let g:airline#extensions#branch#enabled = 1  " Enable Git branch display
let g:airline#extensions#hunks#enabled = 0   " Disable hunks (e.g., Git changes) to speed things up
let g:airline#extensions#whitespace#enabled = 0  " Disable whitespace checking for performance

let g:airline_left_sep = ''   " Customize the left separator
let g:airline_right_sep = ''  " Customize the right separator

let g:airline_section_separator = '|'
let g:airline_section_separator_right = '|'
let g:airline_subseparator_left = '|'
let g:airline_subseparator_right = '|'
"=============================================
"             Fzf Configration 
"=============================================

let g:fzf_preview_window = 'right:50%'
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6  }  }

"=============================================
"         Other Plug Config 
"=============================================

" Disable startify cow like header :>
let g:startify_custom_header = []

" Shortcut key for floating terminal
let g:floaterm_keymap_toggle = '<F7>'

"=============================================
"         Compile And Run C Code 
"=============================================

function! CompileAndRun()
    let l:filename = expand('%:r')  " Get the current file name without extension
    let l:filetype = &filetype      " Get the file type of the current buffer
    let l:filepath = expand('%:p')  " Get the full path of the current file
    let l:relpath = expand('%')     " Get the relative path of the current file

    if l:filetype == 'c'
        let l:outputfile = l:filename . ".out"  " Output file name with .out extension

        " Compile the C file and generate the output file
        exec "!gcc " . l:relpath . " -o " . l:outputfile

        " Run the compiled program in the terminal
        exec "!./" . l:outputfile
    elseif l:filetype == 'python'
        " Run the Python file using python3
        exec "!python3 " . l:filepath
    else
        echo "Unsupported file type!"
    endif
endfunction

" Map the F5 key to call the function
nnoremap <F5> :call CompileAndRun()<CR>

"=============================================
"          Coc Nvim Configration 
"=============================================

" May need for Vim (not Neovim) since coc.nvim calculates byte offset by count
" utf-8 byte sequence
set encoding=utf-8
" Some servers have issues with backup files, see #649
set nobackup
set nowritebackup

" Having longer updatetime (default is 4000 ms = 4s) leads to noticeable
" delays and poor user experience
set updatetime=300

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config
inoremap <silent><expr> <TAB>
    \ coc#pum#visible() ? coc#pum#next(1) :
    \ CheckBackspace() ? "\<Tab>" :
    \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                            \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
let col = col('.') - 1
return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion
if has('nvim')
inoremap <silent><expr> <c-space> coc#refresh()
else
inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
if CocAction('hasProvider', 'hover')
  call CocActionAsync('doHover')
else
  call feedkeys('K', 'in')
endif
endfunction

" Highlight the symbol and its references when holding the cursor
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
autocmd!
" Setup formatexpr specified filetype(s)
autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
" Update signature help on jump placeholder
autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying code actions to the selected code block
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying code actions at the cursor position
nmap <leader>ac  <Plug>(coc-codeaction-cursor)
" Remap keys for apply code actions affect whole buffer
nmap <leader>as  <Plug>(coc-codeaction-source)
" Apply the most preferred quickfix action to fix diagnostic on the current line
nmap <leader>qf  <Plug>(coc-fix-current)

" Remap keys for applying refactor code actions
nmap <silent> <leader>re <Plug>(coc-codeaction-refactor)
xmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)
nmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)

" Run the Code Lens action on the current line
nmap <leader>cl  <Plug>(coc-codelens-action)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> to scroll float windows/popups
if has('nvim-0.4.0') || has('patch-8.2.0750')
nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges
" Requires 'textDocument/selectionRange' support of language server
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer
command! -nargs=0 Format :call CocActionAsync('format')

" Add `:Fold` command to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline
" set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>
