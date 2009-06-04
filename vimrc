syntax on
filetype plugin indent on
set nocp
set nowrap
set noacd
set incsearch
set ignorecase
set smartcase
set scrolloff=5
set number
set backspace=indent,eol,start
colors metacosm
set hlsearch
set laststatus=2
set noequalalways "equalalways screws around with the quickfix list
behave xterm
set mouse=a
set mousefocus
set clipboard+=unnamed
set foldmethod=syntax
set nofoldenable
set encoding=utf-8
set fileencodings="ucs-bom,utf-8"

"Linux/Git
set tabstop=8
set shiftwidth=8
set softtabstop=8
set noexpandtab

"Work
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab


set smarttab
"set autoindent
"set smartindent
set ruler
set showcmd
if has("gui_gtk2")
  set guifont=ProFontWindows\ 9
elseif has("gui_win32")
  set guifont=ProFontWindows:h9:cANSI
endif
"let test = "タλ©±βΓγπΠεΕσΣΩΨφ£€Θ"
set guioptions-=l "left scrollbar
set guioptions-=L "left scrollbar when vsplit
set guioptions-=r "right scrollbar
set guioptions-=R "right scrollbar when vsplit
set guioptions-=T "remove toolbar
set guioptions-=m "remove menubar
set guioptions+=c "use console dialogs instead of popup dialogs
set formatoptions+=r "insert star for multiline comment when press enter in insert mode
set formatoptions-=o "insert star for "o" command
set formatoptions-=c "auto wrap comments
set formatoptions-=a "auto format paragraphs
set formatoptions+=n "recognize numbered lists and auto indent wrapped text
set formatoptions-=t "Auto-wrap text using textwidth
set textwidth=78

command -bang -nargs=? QFix call QFixToggle(<bang>0)
function! QFixToggle(forced)
  if exists("g:qfix_win") && a:forced == 0
    cclose
    unlet g:qfix_win
  else
    botright copen 10
    let g:qfix_win = bufnr("$")
  endif
endfunction


map ,t <C-]>
map ,T <C-T>
map ,a :A<CR>
map ,u <C-^>
map <F4> :cnext<CR>
map <F5> :cprev<CR>
map <F7> :wa<CR>:make<CR>
nmap <silent> <F12> :QFix<CR>
map ; :

autocmd BufEnter * execute ":lcd ".expand("%:p:h")
