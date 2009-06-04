" Vimball Archiver by Charles E. Campbell, Jr., Ph.D.
UseVimball
finish
doc/ttoc.txt	[[[1
228
*ttoc.txt*  ttoc - A regexp-based ToC of the current buffer
            Author: Thomas Link, micathom at gmail com


This plugin tries to duplicate the functionality of Marc Weber's 
outline.vim (vimscript #1947) on the basis of its description and of 
vim's own |:g|. Other than outline.vim, it relies on tlib (vimscript 
#1863).

The TToC command can be used to get a quick table of contents of the 
buffer based on a given regular expression. The regexp can be defined on 
the command line, in window (w:ttoc_rx), buffer-local (b:ttoc_rx) 
variables or in global filetype-specific (g:ttoc_rx_{&filetype}) 
variables. The order actually is: [wbg]:ttoc_rx_{&filetype} > 
[wbg]:ttoc_rx.

In the list view, you can select a line and either preview it (<c-p>), 
jump there (<), close the list and jump there (<cr>).

Example: >

  " Use the default settings for the current file-type
  :TToC
  " Show all words beginning at column 1
  :TToC ^\w
  " Show 'if' statements (but not the concluding 'then' statement)
  :TToC ^\s*if\>.\{-}\ze\s\+then
  " Show 'if' statements and 3 extra lines
  :3TToC! \<if\>

The TToC with a bang works somewhat like |:g| only that you can 
browse/filter the list and select an item after reviewing the results. 
Try it out and compare (with the help file as current buffer): >

  :TToC! TToC

with >

  :g/TToC



-----------------------------------------------------------------------
Install~

Edit the vba file and type: >

    :so %

See :help vimball for details. If you have difficulties, please make 
sure, you have the current version of vimball (vimscript #1502) 
installed.

This script requires tlib (vimscript #1863) to be installed.

Suggested maps (to be set in ~/.vimrc): >
    noremap <m-c>       :TToC<cr>
    inoremap <m-c>       <c-o>:TToC<cr>

and (in case <m-t> is set to open some menu):
    noremap  <Leader>cc       :TToC<cr>
    inoremap <Leader>cc       <c-o>:TToC<cr>
    noremap  <Leader>c<space> :TToC!
    inoremap <Leader>c<space> <c-o>:TToC!

The following gives you a |[I| or |]I| like experience but with a IMHO more 
convenient UI:

    noremap  <Leader>c#       :TToC! <c-r><c-w><cr>
    inoremap <Leader>c#       <c-o>:TToC! <c-r><c-w><cr>

Or open the search in a "background" window:

    noremap  <Leader>cb       :Ttocbg! <c-r><c-w><cr>
    inoremap <Leader>cb       <c-o>:Ttocbg! <c-r><c-w><cr>

Key maps in the list view:
    <c-p>   ... preview selected item
    <cr>    ... close the TOC and jump to the selected item
    <space> ... jump to the selected item but don't close the TOC
    <esc>   ... close the TOC, jump back to the original position


========================================================================
Contents~

        g:ttoc_markers ......... |g:ttoc_markers|
        g:ttoc_rx .............. |g:ttoc_rx|
        g:ttoc_rx_bib .......... |g:ttoc_rx_bib|
        g:ttoc_rx_c ............ |g:ttoc_rx_c|
        g:ttoc_rx_cpp .......... |g:ttoc_rx_cpp|
        g:ttoc_rx_html ......... |g:ttoc_rx_html|
        g:ttoc_rx_java ......... |g:ttoc_rx_java|
        g:ttoc_rx_javascript ... |g:ttoc_rx_javascript|
        g:ttoc_rx_perl ......... |g:ttoc_rx_perl|
        g:ttoc_rx_php .......... |g:ttoc_rx_php|
        g:ttoc_rx_python ....... |g:ttoc_rx_python|
        g:ttoc_rx_rd ........... |g:ttoc_rx_rd|
        g:ttoc_rx_ruby ......... |g:ttoc_rx_ruby|
        g:ttoc_rx_scheme ....... |g:ttoc_rx_scheme|
        g:ttoc_rx_sh ........... |g:ttoc_rx_sh|
        g:ttoc_rx_tcl .......... |g:ttoc_rx_tcl|
        g:ttoc_rx_tex .......... |g:ttoc_rx_tex|
        g:ttoc_rx_viki ......... |g:ttoc_rx_viki|
        g:ttoc_rx_vim .......... |g:ttoc_rx_vim|
        g:ttoc_world ........... |g:ttoc_world|
        g:ttoc_vertical ........ |g:ttoc_vertical|
        g:ttoc_win_size ........ |g:ttoc_win_size|
        TToC_GetLine_viki ...... |TToC_GetLine_viki()|
        TToC_GetLine_bib ....... |TToC_GetLine_bib()|
        :TToC .................. |:TToC|
        :Ttoc .................. |:Ttoc|
        :Ttocbg ................ |:Ttocbg|



                                                    *g:ttoc_markers*
g:ttoc_markers                 (default: 1)
    Markers as used by vim and other editors. Can be also buffer-local. 
    This rx is added to the filetype-specific rx.
    Values:
      0      ... disable
      1      ... use &foldmarker
      2      ... use &foldmarker only if &foldmethod == marker
      string ... use as rx

                                                    *g:ttoc_rx*
g:ttoc_rx                      (default: '^\w.*')
    By default, assume that everything at the first column is important.


Some filetype-specific regexps. If you don't like the default values, 
set these variables in ~/.vimrc.

                                                    *g:ttoc_rx_bib*
g:ttoc_rx_bib                  (default: '^@\w\+\s*{\s*\zs\S\{-}\ze\s*,')

                                                    *g:ttoc_rx_c*
g:ttoc_rx_c                    (default: '^[[:alnum:]#].*')

                                                    *g:ttoc_rx_cpp*
g:ttoc_rx_cpp                  (default: g:ttoc_rx_c)

                                                    *g:ttoc_rx_html*
g:ttoc_rx_html                 (default: '\(<h\d.\{-}</h\d>\|<\(html\|head\|body\|div\|script\|a\s\+name=\).\{-}>\|<.\{-}\<id=.\{-}>\)')

                                                    *g:ttoc_rx_java*
g:ttoc_rx_java                 (default: '^\s*\(\(package\|import\|private\|public\|protected\|void\|int\|boolean\)\s\+\|\u\).*')

                                                    *g:ttoc_rx_javascript*
g:ttoc_rx_javascript           (default: '^\s*\(var\s\+.\{-}\|\w\+\s*:\s*.\{-}\)\s*$')

                                                    *g:ttoc_rx_perl*
g:ttoc_rx_perl                 (default: '^\([$%@]\|\s*\(use\|sub\)\>\).*')

                                                    *g:ttoc_rx_php*
g:ttoc_rx_php                  (default: '^\(\w\|\s*\(class\|function\|var\|require\w*\|include\w*\)\>\).*')

                                                    *g:ttoc_rx_python*
g:ttoc_rx_python               (default: '^\s*\(import\|class\|def\)\>.*')

                                                    *g:ttoc_rx_rd*
g:ttoc_rx_rd                   (default: '^\(=\+\|:\w\+:\).*')

                                                    *g:ttoc_rx_ruby*
g:ttoc_rx_ruby                 (default: '\C^\(if\>\|\s*\(class\|module\|def\|require\|private\|public\|protected\|module_functon\|alias\|attr\(_reader\|_writer\|_accessor\)\?\)\>\|\s*[[:upper:]_]\+\s*=\).*')

                                                    *g:ttoc_rx_scheme*
g:ttoc_rx_scheme               (default: '^\s*(define.*')

                                                    *g:ttoc_rx_sh*
g:ttoc_rx_sh                   (default: '^\s*\(\(export\|function\|while\|case\|if\)\>\|\w\+\s*()\s*{\).*')

                                                    *g:ttoc_rx_tcl*
g:ttoc_rx_tcl                  (default: '^\s*\(source\|proc\)\>.*')

                                                    *g:ttoc_rx_tex*
g:ttoc_rx_tex                  (default: '\C\\\(label\|\(sub\)*\(section\|paragraph\|part\)\)\>.*')

                                                    *g:ttoc_rx_viki*
g:ttoc_rx_viki                 (default: '^\(\*\+\|\s*#\l\).*')

                                                    *g:ttoc_rx_vim*
g:ttoc_rx_vim                  (default: '\C^\(fu\%[nction]\|com\%[mand]\|if\|wh\%[ile]\)\>.*')

                                                    *g:ttoc_world*
g:ttoc_world
    ttoc-specific |tlib#input#ListD| configuration.
    Customizations should be done in ~/.vimrc/after/plugin/ttoc.vim
    E.g. in order to split horizontally, use: >
        let g:ttoc_world.scratch_vertical = 0
<

                                                    *g:ttoc_vertical*
g:ttoc_vertical                (default: '&lines < &co')
    If true, split vertical.

                                                    *g:ttoc_win_size*
g:ttoc_win_size                (default: '((&lines > &co) ? &lines : &co) / 2')
    Vim code that evaluates to the desired window width/heigth.

                                                    *TToC_GetLine_viki()*
TToC_GetLine_viki(lnum, acc)

                                                    *TToC_GetLine_bib()*
TToC_GetLine_bib(lnum, acc)

                                                    *:TToC*
:[COUNT]TToC[!] [REGEXP]
    EXAMPLES: >
      TToC                   ... use standard settings
      TToC foo.\{-}\ze \+bar ... show this rx (don't include 'bar')
      TToC! foo.\{-}bar      ... show lines matching this rx 
      3TToC! foo.\{-}bar     ... show lines matching this rx + 3 extra lines
<

                                                    *:Ttoc*
:Ttoc
    Synonym for |:TToC|.

                                                    *:Ttocbg*
:Ttocbg
    Like |:TToC| but open the list in "background", i.e. the focus stays 
    in the document window.



vim:tw=78:fo=tcq2:isk=!-~,^*,^|,^":ts=8:ft=help:norl:
plugin/ttoc.vim	[[[1
213
" ttoc.vim -- A regexp-based ToC of the current buffer
" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-07-09.
" @Last Change: 2009-05-03.
" @Revision:    462
" GetLatestVimScripts: 2014 0 ttoc.vim

if &cp || exists("loaded_ttoc")
    finish
endif
if !exists('loaded_tlib') || loaded_tlib < 32
    echoerr 'tlib >= 0.32 is required'
    finish
endif
let loaded_ttoc = 5

let s:save_cpo = &cpo
set cpo&vim


" Markers as used by vim and other editors. Can be also buffer-local. 
" This rx is added to the filetype-specific rx.
" Values:
"   0      ... disable
"   1      ... use &foldmarker
"   2      ... use &foldmarker only if &foldmethod == marker
"   string ... use as rx
TLet g:ttoc_markers = 1

" if has('signs')
"     " If non-empty, mark locations with signs.
"     TLet g:ttoc_sign = '~'
"     exec 'sign define TToC text='. g:ttoc_sign .' texthl=Special'
" else
"     " :nodoc:
"     TLet g:ttoc_sign = ''
" endif


" By default, assume that everything at the first column is important.
TLet g:ttoc_rx = '^\w.*'

" TLet g:ttoc_markers = '.\{-}{{{.*'


" Filetype-specific rx "{{{2

" :doc:
" Some filetype-specific regexps. If you don't like the default values, 
" set these variables in ~/.vimrc.

TLet g:ttoc_rx_bib    = '^@\w\+\s*{\s*\zs\S\{-}\ze\s*,'
TLet g:ttoc_rx_c      = '^[[:alnum:]#].*'
TLet g:ttoc_rx_cpp    = g:ttoc_rx_c
TLet g:ttoc_rx_html   = '\(<h\d.\{-}</h\d>\|<\(html\|head\|body\|div\|script\|a\s\+name=\).\{-}>\|<.\{-}\<id=.\{-}>\)'
TLet g:ttoc_rx_java   = '^\s*\(\(package\|import\|private\|public\|protected\|void\|int\|boolean\)\s\+\|\u\).*'
TLet g:ttoc_rx_javascript = '^\(var\s\+.\{-}\|\s*\w\+\s*:\s*\S.\{-}[,{]\)\s*$'
TLet g:ttoc_rx_perl   = '^\([$%@]\|\s*\(use\|sub\)\>\).*'
TLet g:ttoc_rx_php    = '^\(\w\|\s*\(class\|function\|var\|require\w*\|include\w*\)\>\).*'
TLet g:ttoc_rx_python = '^\s*\(import\|class\|def\)\>.*'
TLet g:ttoc_rx_rd     = '^\(=\+\|:\w\+:\).*'
TLet g:ttoc_rx_ruby   = '\C^\(if\>\|\s*\(class\|module\|def\|require\|private\|public\|protected\|module_functon\|alias\|attr\(_reader\|_writer\|_accessor\)\?\)\>\|\s*[[:upper:]_]\+\s*=\).*'
TLet g:ttoc_rx_scheme = '^\s*(define.*'
TLet g:ttoc_rx_sh     = '^\s*\(\(export\|function\|while\|case\|if\)\>\|\w\+\s*()\s*{\).*'
TLet g:ttoc_rx_tcl    = '^\s*\(source\|proc\)\>.*'
TLet g:ttoc_rx_tex    = '\C\\\(label\|\(sub\)*\(section\|paragraph\|part\)\)\>.*'
TLet g:ttoc_rx_viki   = '^\(\*\+\|\s*#\l\).*'
TLet g:ttoc_rx_vim    = '\C^\(fu\%[nction]\|com\%[mand]\|if\|wh\%[ile]\)\>.*'

" TLet g:ttoc_rx_vim    = '\C^\(\(fu\|if\|wh\).*\|.\{-}\ze\("\s*\)\?{{{.*\)'
" TLet g:ttoc_rx_ocaml  = '^\(let\|module\|\s*let .\{-}function\).*'


" :nodefault:
" ttoc-specific |tlib#input#ListD| configuration.
" Customizations should be done in ~/.vimrc/after/plugin/ttoc.vim
" E.g. in order to split horizontally, use: >
"     let g:ttoc_world.scratch_vertical = 0
TLet g:ttoc_world = {
                \ 'type': 'm',
                \ 'query': 'Select entry',
                \ 'pick_last_item': 0,
                \ 'scratch': '__ttoc__',
                \ 'retrieve_eval': 'ttoc#Collect(world, 0)',
                \ 'return_agent': 'ttoc#GotoLine',
                \ 'key_handlers': [
                    \ {'key': 16, 'agent': 'tlib#agent#PreviewLine',  'key_name': '<c-p>', 'help': 'Preview'},
                    \ {'key':  7, 'agent': 'ttoc#GotoLine',     'key_name': '<c-g>', 'help': 'Jump (don''t close the TOC window)'},
                    \ {'key': 60, 'agent': 'ttoc#GotoLine',     'key_name': '<',     'help': 'Jump (don''t close the TOC window)'},
                    \ {'key':  5, 'agent': 'tlib#agent#DoAtLine',     'key_name': '<c-e>', 'help': 'Run a command on selected lines'},
                    \ {'key': "\<c-insert>", 'agent': 'ttoc#SetFollowCursor', 'key_name': '<c-ins>', 'help': 'Toggle trace cursor'},
                    \ {'key': 28, 'agent': 'tlib#agent#ToggleStickyList',       'key_name': '<c-\>', 'help': 'Toggle sticky'},
                \ ],
            \ }
            " \ 'scratch_vertical': (&lines > &co),


" If true, split vertical.
TLet g:ttoc_vertical = '&lines < &co'
" TLet g:ttoc_vertical = -1

" Vim code that evaluates to the desired window width/heigth.
TLet g:ttoc_win_size = '((&lines > &co) ? &lines : &co) / 2'
" TLet g:ttoc_win_size = '((&lines > &co) ? winheight(0) : winwidth(0)) / 2'


" function! TToC_GetLine_vim(lnum, acc) "{{{3
"     let l = a:lnum
"     while 1
"         let l -= 1
"         let t = getline(l)
"         if !empty(t) && t =~ '^\s*"'
"             let t = matchstr(t, '"\s*\zs.*')
"             TLogVAR t
"             call insert(a:acc, t, 1)
"         else
"             break
"         endif
"     endwh
"     return l
" endf


function! TToC_GetLine_viki(lnum, acc) "{{{3
    let l = a:lnum
    while 1
        let l += 1
        let t = getline(l)
        if !empty(t)
            if t[0] == '#'
                call add(a:acc, t)
            elseif t =~ '\s\+::\s\+'
                call add(a:acc, t)
            else
                break
            end
        else
            break
        endif
    endwh
    return l
endf


function! TToC_GetLine_bib(lnum, acc) "{{{3
    for l in range(a:lnum + tlib#string#Count(a:acc[0], '\n'), a:lnum + 4)
        let t = getline(l)
        if !empty(t)
            call add(a:acc, t)
        endif
    endfor
    return a:lnum + 5
endf


augroup TToC
    autocmd!
augroup END


" :display: :[COUNT]TToC[!] [REGEXP]
" EXAMPLES: >
"   TToC                   ... use standard settings
"   TToC foo.\{-}\ze \+bar ... show this rx (don't include 'bar')
"   TToC! foo.\{-}bar      ... show lines matching this rx 
"   3TToC! foo.\{-}bar     ... show lines matching this rx + 3 extra lines
command! -nargs=? -bang -count TToC call ttoc#View(<q-args>, !empty("<bang>"), v:count, <count>)

" Synonym for |:TToC|.
command! -nargs=? -bang -count Ttoc call ttoc#View(<q-args>, !empty("<bang>"), v:count, <count>)

" Like |:TToC| but open the list in "background", i.e. the focus stays 
" in the document window.
command! -nargs=? -bang -count Ttocbg call ttoc#View(<q-args>, !empty("<bang>"), v:count, <count>, 1)


let &cpo = s:save_cpo

finish
CHANGES:
0.1
- Initial release

0.2
- Require tlib 0.14
- <c-e> Run a command on selected lines.
- g:ttoc_world can be a normal dictionary.
- Use tlib#input#ListD() instead of tlib#input#ListW().

0.3
- Highlight the search term on partial searches
- Defined :Ttoc as synonym for :TToC
- Defined :Ttocbg to open a toc in the "background" (leave the 
focus/cursor in the main window)
- Require tlib 0.21
- Experimental: ttoc#Autoword(onoff): automatically show lines 
containing the word under the cursor; must be enabled for each buffer.
- Split plugin into (autoload|plugin)/ttoc.vim
- Follow/trace cursor functionality (toggled with <c-t>): instantly 
preview the line under cursor.
- Restore original position when using preview

0.4
- Handle multi-line regexps (thanks to M Weber for pointing this out)
- Require tlib 0.27
- Changed key for "trace cursor" from <c-t> to <c-insert>.

0.5
- Require tlib 0.32
- Fill location list

autoload/ttoc.vim	[[[1
244
" ttoc.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-11-11.
" @Last Change: 2009-03-15.
" @Revision:    0.0.73

if &cp || exists("loaded_ttoc_autoload")
    finish
endif
let loaded_ttoc_autoload = 1
let s:save_cpo = &cpo
set cpo&vim


" :def: function! ttoc#Collect(world, return_index, ?additional_lines=0)
function! ttoc#Collect(world, return_index, ...) "{{{3
    TVarArg ['additional_lines', 0]
    " TLogVAR additional_lines
    let pos = getpos('.')
    let s:accum = []
    let s:table  = []
    let s:current_line = line('.')
    let s:line_format  = '%0'. len(line('$')) .'d'
    let s:current_index = 0
    let s:additional_lines = additional_lines
    let s:rx = a:world.ttoc_rx
    let rs  = @/
    let s:next_line = 1
    let s:multiline = stridx(a:world.ttoc_rx, '\_.') != -1
    let s:world = a:world

    try
        exec 'keepjumps g /'. escape(a:world.ttoc_rx, '/') .'/call s:ProcessLine()'
    finally
        let @/ = rs
    endtry

    call setpos('.', pos)
    " let a:world.index_table = s:table
    if a:return_index
        return [s:accum, s:current_index]
    else
        return s:accum
    endif
endf


function! s:ProcessLine() "{{{3
    let l = line('.')
    " TLogVAR l
    if l >= s:next_line

        let linesplus = 1
        " call TLogDBG("s:multiline=". s:multiline)
        if s:multiline
            let pos = getpos('.')
            keepjumps let endline = search(s:world.ttoc_rx, 'ceW')
            " TLogVAR endline
            if endline == 0
                " shouldn't be here
                let t = matchstr(getline(l)
            else
                let t = [join(getline(l, endline), "\n")]
                let linesplus += (endline - l)
            endif
            call setpos('.', pos)
        else
            let t = [matchstr(getline(l), s:rx)]
        endif
        " TLogVAR t
        let s:next_line = l + linesplus
        if exists('*TToC_GetLine_'.&filetype)
            let next_line = TToC_GetLine_{&filetype}(l, t)
            if next_line > s:next_line
                let s:next_line = next_line
            endif
        endif

        if s:additional_lines > 0
            let next_line = s:next_line + s:additional_lines
            for i in range(s:next_line, next_line - 1)
                " TLogVAR i
                let lt = getline(i)
                if lt =~ '\S'
                    call add(t, lt)
                endif
            endfor
            let s:next_line = next_line
        endif

        let i = printf(s:line_format, l) .': '. substitute(join(t, ' | '), repeat('\s', &sw), ' ', 'g')
        " TLogVAR i
        " let i = substitute(join(t, ' | '), '\s\+', ' ', 'g')
        call add(s:accum, i)
        " call add(s:table, l)
        if l <= s:current_line
            let s:current_index += 1
        endif

    endif
    " call TLogDBG("s:next_line=". s:next_line)
endf


function! ttoc#GotoLine(world, selected) "{{{3
    " TLogVAR a:selected
    if empty(a:selected)
        call a:world.RestoreOrigin()
        return a:world
    else
        " call a:world.SetOrigin()
        return tlib#agent#GotoLine(a:world, a:selected)
    endif
endf


" :def: function! ttoc#View(rx, ?partial_rx=0, ?v_count=0, ?p_count=0, ?background=0)
function! ttoc#View(rx, ...) "{{{3
    " TLogVAR a:rx
    TVarArg ['partial_rx', 0], ['v_count', 0], ['p_count', 0], ['background', 0]
    let additional_lines = v_count ? v_count : p_count ? p_count : 0
    " TLogVAR partial_rx, additional_lines, v_count, p_count

    if empty(a:rx)
        let rx = s:DefaultRx()
    else
        let rx = a:rx
        if partial_rx
            let rx = '^.\{-}'. rx .'.*$'
        end
    endif

    if empty(rx)
        echoerr 'TToC: No regexp given'
    else
        " TLogVAR ac
        let w = copy(g:ttoc_world)
        let w.ttoc_rx = rx
        let [ac, ii] = ttoc#Collect(w, 1, additional_lines)
        " TLogVAR ac
        " if !empty(g:ttoc_sign)
            let acc = []
            let bn  = bufnr('%')
            let i = 1
            for item in ac
                call add(acc, {'bufnr': bn, 'lnum': matchstr(item, '^0*\zs\d\+'), 'text': i .': '. rx})
                let i += 1
            endfor
            call setloclist(winnr(), acc)
            " call tlib#signs#ClearBuffer('TToC', bn)
            " call tlib#signs#Mark('TToC', acc)
        " endif
        let w.initial_index = ii
        let w.base = ac
        let win_size = tlib#var#Get('ttoc_win_size', 'wbg')
        if !empty(win_size)
            " TLogDBG tlib#cmd#UseVertical('TToC')
            let use_vertical = eval(g:ttoc_vertical)
            if use_vertical == 1 || (use_vertical == -1 && tlib#cmd#UseVertical('TToC'))
                let w.scratch_vertical = 1
                if get(w, 'resize_vertical', 0) == 0
                    let w.resize_vertical = eval(win_size)
                endif
            else
                if get(w, 'resize', 0) == 0
                    let w.resize = eval(win_size)
                endif
            endif
        endif
        " TLogVAR w.resize_vertical, w.resize
        " let world = tlib#World#New(a:dict)
        if partial_rx && !empty(a:rx)
            " call world.SetInitialFilter(a:rx)
            let w.tlib_UseInputListScratch = '3match IncSearch /'. escape(a:rx, '/') .'/'
        endif
        if background
            let w.next_state = 'suspend'
        endif
        " call tlib#input#ListW(world)
        call tlib#input#ListD(w)
    endif
endf


function! s:DefaultRx() "{{{3
    let rx = tlib#var#Get('ttoc_rx_'. &filetype, 'wbg')
    if empty(rx)
        let rx = tlib#var#Get('ttoc_rx', 'wbg')
    endif
    let marker = tlib#var#Get('ttoc_markers', 'wbg')
    if !empty(marker)
        if type(marker) == 0
            if marker == 1 || (marker == 2 && &foldmethod == 'marker')
                let [open, close] = split(&foldmarker, ',', 1)
                if !empty(open)
                    let rx  = printf('\(%s\|.\{-}%s.*\)', rx, tlib#rx#Escape(open))
                endif
            endif
        else
            let rx = printf('\(%s\|%s\)', rx, marker)
        endif
    endif
    return rx
endf


" If onoff is true, switch on auto-following of the word under cursor. 
" This has to be enabled for each buffer.
" If onoff is false, switch it off.
function! ttoc#Autoword(onoff) "{{{3
    let s:lword = ''
    if a:onoff
        autocmd TToC CursorMoved,CursorMovedI <buffer> let s:cword = expand('<cword>') | if s:cword != s:lword | let s:lword = s:cword | call ttoc#View(s:cword, 1, 0, 0, 1) | endif
    else
        autocmd! TToC
    endif
endf


function! ttoc#SetFollowCursor(world, selected) "{{{3
    if empty(a:world.follow_cursor)
        let a:world.follow_cursor = 'ttoc#FollowCursor'
    else
        let a:world.follow_cursor = ''
    endif
    let a:world.state = 'redisplay'
    return a:world
endf


function! ttoc#FollowCursor(world, selected) "{{{3
    let l = a:selected[0]
    " TLogVAR l
    call tlib#buffer#ViewLine(l)
    redraw
    let a:world.state = 'redisplay'
    return a:world
endf


let &cpo = s:save_cpo
unlet s:save_cpo
