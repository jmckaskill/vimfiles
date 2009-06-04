" Vimball Archiver by Charles E. Campbell, Jr., Ph.D.
UseVimball
finish
doc/ack.txt	[[[1
38
*ack.txt*   Plugin that integrates ack with Vim

==============================================================================
Author:  Antoine Imbert <antoine.imbert+ackvim@gmail.com>         *ack-author*
License: Same terms as Vim itself (see |license|)

==============================================================================
INTRODUCTION                                                             *ack*

This plugin is a front for the Perl module App::Ack.  Ack can be used as a
replacement for grep.  This plugin will allow you to run ack from vim, and
shows the results in a split window.

:Ack [options] {pattern} [{directory}]                                  *:Ack*

    Search recursively in {directory} (which defaults to the current
    directory) for the {pattern}.  Behaves just like the |:grep| command, but
    will open the |Quickfix| window for you.

:AckAdd [options] {pattern} [{directory}]                            *:AckAdd*

    Just like |:Ack| + |:grepadd|.  Appends the |quickfix| with the results

:LAck [options] {pattern} [{directory}]                                *:LAck*

    Just like |:Ack| + |:lgrep|.  Searches, but opens in |location-list|

:LAckAdd [options] {pattern} [{directory}]                          *:LAckAdd*

    Just like |:Ack| + |:lgrepadd|.  Searches, but appends results to
    |location-list|

Files containing the search term will be listed in the split window, along
with the line number of the occurrence, once for each occurrence.  <Enter> on
a line in this window will open the file, and place the cursor on the matching
line.

See http://search.cpan.org/~petdance/ack/ack for more information.
plugin/ack.vim	[[[1
50
" NOTE: You must, of course, install the ack script
"       in your path.
" On Ubuntu:
"   sudo apt-get install ack-grep
"   ln -s /usr/bin/ack-grep /usr/bin/ack
" With MacPorts:
"   sudo port install p5-app-ack

let g:ackprg="ack\\ -H\\ --nocolor\\ --nogroup"

function! Ack(args)
    let grepprg_bak=&grepprg
    exec "set grepprg=" . g:ackprg
    execute "silent! grep " . a:args
    botright copen
    let &grepprg=grepprg_bak
    exec "redraw!"
endfunction

function! AckAdd(args)
    let grepprg_bak=&grepprg
    exec "set grepprg=" . g:ackprg
    execute "silent! grepadd " . a:args
    botright copen
    let &grepprg=grepprg_bak
    exec "redraw!"
endfunction

function! LAck(args)
    let grepprg_bak=&grepprg
    exec "set grepprg=" . g:ackprg
    execute "silent! lgrep " . a:args
    botright lopen
    let &grepprg=grepprg_bak
    exec "redraw!"
endfunction

function! LAckAdd(args)
    let grepprg_bak=&grepprg
    exec "set grepprg=" . g:ackprg
    execute "silent! lgrepadd " . a:args
    botright lopen
    let &grepprg=grepprg_bak
    exec "redraw!"
endfunction

command! -nargs=* -complete=file Ack call Ack(<q-args>)
command! -nargs=* -complete=file AckAdd call AckAdd(<q-args>)
command! -nargs=* -complete=file LAck call LAck(<q-args>)
command! -nargs=* -complete=file LAckAdd call LAckAdd(<q-args>)
