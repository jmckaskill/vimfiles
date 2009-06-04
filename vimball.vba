" Vimball Archiver by Charles E. Campbell, Jr., Ph.D.
UseVimball
finish
autoload/vimball.vim	[[[1
780
" vimball.vim : construct a file containing both paths and files
" Author:	Charles E. Campbell, Jr.
" Date:		May 30, 2008
" Version:	26
" GetLatestVimScripts: 1502 1 :AutoInstall: vimball.vim
" Copyright: (c) 2004-2007 by Charles E. Campbell, Jr.
"            The VIM LICENSE applies to Vimball.vim, and Vimball.txt
"            (see |copyright|) except use "Vimball" instead of "Vim".
"            No warranty, express or implied.
"  *** ***   Use At-Your-Own-Risk!   *** ***

" ---------------------------------------------------------------------
"  Load Once: {{{1
if &cp || exists("g:loaded_vimball") || v:version < 700
 finish
endif
let s:keepcpo        = &cpo
let g:loaded_vimball = "v26"
set cpo&vim
"DechoTabOn

" =====================================================================
" Constants: {{{1
if !exists("s:USAGE")
 let s:USAGE   = 0
 let s:WARNING = 1
 let s:ERROR   = 2

 " determine if cygwin is in use or not
 if !exists("g:netrw_cygwin")
  if has("win32") || has("win95") || has("win64") || has("win16")
   if &shell =~ '\%(\<bash\>\|\<zsh\>\)\%(\.exe\)\=$'
    let g:netrw_cygwin= 1
   else
    let g:netrw_cygwin= 0
   endif
  else
   let g:netrw_cygwin= 0
  endif
 endif

 " set up g:vimball_mkdir if the mkdir() call isn't defined
 if !exists("*mkdir")
  if exists("g:netrw_local_mkdir")
   let g:vimball_mkdir= g:netrw_local_mkdir
  elseif executable("mkdir")
   let g:vimball_mkdir= "mkdir"
  elseif executable("makedir")
   let g:vimball_mkdir= "makedir"
  endif
  if !exists(g:vimball_mkdir)
   call vimball#ShowMesg(s:WARNING,"(vimball) g:vimball_mkdir undefined")
  endif
 endif

 " set up shell quoting character
 if exists("g:vimball_shq") && !exists("g:netrw_shq")
  let g:netrw_shq= g:vimball_shq
 endif
 if !exists("g:netrw_shq")
  if exists("&shq") && &shq != ""
   let g:netrw_shq= &shq
  elseif has("win32") || has("win95") || has("win64") || has("win16")
   if g:netrw_cygwin
    let g:netrw_shq= "'"
   else
    let g:netrw_shq= '"'
   endif
  else
   let g:netrw_shq= "'"
  endif
" call Decho("g:netrw_shq<".g:netrw_shq.">")
 endif

 " set up escape string (used to protect paths)
 if !exists("g:vimball_path_escape")
  let g:vimball_path_escape= ' ;#%'
 endif
endif

" =====================================================================
"  Functions: {{{1

" ---------------------------------------------------------------------
" vimball#MkVimball: creates a vimball given a list of paths to files {{{2
" Input:
"     line1,line2: a range of lines containing paths to files to be included in the vimball
"     writelevel : if true, force a write to filename.vba, even if it exists
"                  (usually accomplished with :MkVimball! ...
"     filename   : base name of file to be created (ie. filename.vba)
" Output: a filename.vba using vimball format:
"     path
"     filesize
"     [file]
"     path
"     filesize
"     [file]
fun! vimball#MkVimball(line1,line2,writelevel,...) range
"  call Dfunc("MkVimball(line1=".a:line1." line2=".a:line2." writelevel=".a:writelevel." vimballname<".a:1.">) a:0=".a:0)
  if a:1 =~ '\.vim$' || a:1 =~ '\.txt$'
   let vbname= substitute(a:1,'\.\a\{3}$','.vba','')
  else
   let vbname= a:1
  endif
  if vbname !~ '\.vba$'
   let vbname= vbname.'.vba'
  endif
"  call Decho("vbname<".vbname.">")
  if a:1 =~ '[\/]'
   call vimball#ShowMesg(s:ERROR,"(MkVimball) vimball name<".a:1."> should not include slashes")
"   call Dret("MkVimball : vimball name<".a:1."> should not include slashes")
   return
  endif
  if !a:writelevel && filereadable(vbname)
   call vimball#ShowMesg(s:ERROR,"(MkVimball) file<".vbname."> exists; use ! to insist")
"   call Dret("MkVimball : file<".vbname."> already exists; use ! to insist")
   return
  endif

  " user option bypass
  call vimball#SaveSettings()

  if a:0 >= 2
   " allow user to specify where to get the files
   let home= expand(a:2)
  else
   " use first existing directory from rtp
   let home= s:VimballHome()
  endif

  " save current directory
  let curdir = getcwd()
  call s:ChgDir(home)

  " record current tab, initialize while loop index
  let curtabnr = tabpagenr()
  let linenr   = a:line1
"  call Decho("curtabnr=".curtabnr)

  while linenr <= a:line2
   let svfile  = getline(linenr)
"   call Decho("svfile<".svfile.">")
 
   if !filereadable(svfile)
    call vimball#ShowMesg(s:ERROR,"unable to read file<".svfile.">")
	call s:ChgDir(curdir)
	call vimball#RestoreSettings()
"    call Dret("MkVimball")
    return
   endif
 
   " create/switch to mkvimball tab
   if !exists("vbtabnr")
    tabnew
    silent! file Vimball
    let vbtabnr= tabpagenr()
   else
    exe "tabn ".vbtabnr
   endif
 
   let lastline= line("$") + 1
   if lastline == 2 && getline("$") == ""
	call setline(1,'" Vimball Archiver by Charles E. Campbell, Jr., Ph.D.')
	call setline(2,'UseVimball')
	call setline(3,'finish')
	let lastline= line("$") + 1
   endif
   call setline(lastline  ,substitute(svfile,'$','	[[[1',''))
   call setline(lastline+1,0)

   " write the file from the tab
   let svfilepath= s:Path(svfile,'')
"   call Decho("exe $r ".fnameescape(svfilepath))
   exe "$r ".fnameescape(svfilepath)

   call setline(lastline+1,line("$") - lastline - 1)
"   call Decho("lastline=".lastline." line$=".line("$"))

  " restore to normal tab
   exe "tabn ".curtabnr
   let linenr= linenr + 1
  endwhile

  " write the vimball
  exe "tabn ".vbtabnr
  call s:ChgDir(curdir)
  setlocal ff=unix
  if a:writelevel
   let vbnamepath= s:Path(vbname,'')
"   call Decho("exe w! ".fnameescape(vbnamepath))
   exe "w! ".fnameescape(vbnamepath)
  else
   let vbnamepath= s:Path(vbname,'')
"   call Decho("exe w ".fnameescape(vbnamepath))
   exe "w ".fnameescape(vbnamepath)
  endif
"  call Decho("Vimball<".vbname."> created")
  echo "Vimball<".vbname."> created"

  " remove the evidence
  setlocal nomod bh=wipe
  exe "tabn ".curtabnr
  exe "tabc ".vbtabnr

  " restore options
  call vimball#RestoreSettings()

"  call Dret("MkVimball")
endfun

" ---------------------------------------------------------------------
" vimball#Vimball: extract and distribute contents from a vimball {{{2
"                  (invoked the the UseVimball command embedded in 
"                  vimballs' prologue)
fun! vimball#Vimball(really,...)
"  call Dfunc("vimball#Vimball(really=".a:really.") a:0=".a:0)

  if getline(1) !~ '^" Vimball Archiver by Charles E. Campbell, Jr., Ph.D.$'
   echoerr "(Vimball) The current file does not appear to be a Vimball!"
"   call Dret("vimball#Vimball")
   return
  endif

  " set up standard settings
  call vimball#SaveSettings()
  let curtabnr    = tabpagenr()
  let vimballfile = expand("%:tr")

  " set up vimball tab
"  call Decho("setting up vimball tab")
  tabnew
  silent! file Vimball
  let vbtabnr= tabpagenr()
  let didhelp= ""

  " go to vim plugin home
  if a:0 > 0
   let home= expand(a:1)
  else
   let home= s:VimballHome()
  endif
"  call Decho("home<".home.">")

  " save current directory and remove older same-named vimball, if any
  let curdir = getcwd()
"  call Decho("home<".home.">")
"  call Decho("curdir<".curdir.">")

  call s:ChgDir(home)
  let s:ok_unablefind= 1
  call vimball#RmVimball(vimballfile)
  unlet s:ok_unablefind

  let linenr  = 4
  let filecnt = 0

  " give title to listing of (extracted) files from Vimball Archive
  if a:really
   echohl Title     | echomsg "Vimball Archive"         | echohl None
  else             
   echohl Title     | echomsg "Vimball Archive Listing" | echohl None
   echohl Statement | echomsg "files would be placed under: ".home | echohl None
  endif

  " apportion vimball contents to various files
"  call Decho("exe tabn ".curtabnr)
  exe "tabn ".curtabnr
"  call Decho("linenr=".linenr." line$=".line("$"))
  while 1 < linenr && linenr < line("$")
   let fname   = substitute(getline(linenr),'\t\[\[\[1$','','')
   let fname   = substitute(fname,'\\','/','g')
   let fsize   = getline(linenr+1)+0
   let filecnt = filecnt + 1
"   call Decho("fname<".fname."> fsize=".fsize." filecnt=".filecnt)

   if a:really
    echomsg "extracted <".fname.">: ".fsize." lines"
   else
    echomsg "would extract <".fname.">: ".fsize." lines"
   endif
"   call Decho("using L#".linenr.": will extract file<".fname.">")
"   call Decho("using L#".(linenr+1).": fsize=".fsize)

   " Allow AsNeeded/ directory to take place of plugin/ directory
   " when AsNeeded/filename is filereadable or was present in VimballRecord
   if fname =~ '\<plugin/'
   	let anfname= substitute(fname,'\<plugin/','AsNeeded/','')
	if filereadable(anfname) || (exists("s:VBRstring") && s:VBRstring =~ anfname)
"	 call Decho("using anfname<".anfname."> instead of <".fname.">")
	 let fname= anfname
	endif
   endif

   " make directories if they don't exist yet
   if a:really
"    call Decho("making directories if they don't exist yet (fname<".fname.">)")
    let fnamebuf= substitute(fname,'\\','/','g')
	let dirpath = substitute(home,'\\','/','g')
    while fnamebuf =~ '/'
     let dirname  = dirpath."/".substitute(fnamebuf,'/.*$','','')
	 let dirpath  = dirname
     let fnamebuf = substitute(fnamebuf,'^.\{-}/\(.*\)$','\1','')
"	 call Decho("dirname<".dirname.">")
     if !isdirectory(dirname)
"      call Decho("making <".dirname.">")
      if exists("g:vimball_mkdir")
	   call system(g:vimball_mkdir." ".s:Escape(dirname))
      else
       call mkdir(dirname)
      endif
	  call s:RecordInVar(home,"rmdir('".dirname."')")
     endif
    endwhile
   endif
   call s:ChgDir(home)

   " grab specified qty of lines and place into "a" buffer
   " (skip over path/filename and qty-lines)
   let linenr   = linenr + 2
   let lastline = linenr + fsize - 1
"   call Decho("exe ".linenr.",".lastline."yank a")
   exe "silent ".linenr.",".lastline."yank a"

   " copy "a" buffer into tab
"   call Decho('copy "a buffer into tab#'.vbtabnr)
   exe "tabn ".vbtabnr
   setlocal ma
   silent! %d
   silent put a
   1
   silent d

   " write tab to file
   if a:really
    let fnamepath= s:Path(home."/".fname,'')
"    call Decho("exe w! ".fnameescape(fnamepath))
	exe "silent w! ".fnameescape(fnamepath)
    echo "wrote ".fnamepath
	call s:RecordInVar(home,"call delete('".fnameescape(fnamepath)."')")
   endif

   " return to tab with vimball
"   call Decho("exe tabn ".curtabnr)
   exe "tabn ".curtabnr

   " set up help if its a doc/*.txt file
"   call Decho("didhelp<".didhelp."> fname<".fname.">")
   if a:really && didhelp == "" && fname =~ 'doc/[^/]\+\.\(txt\|..x\)$'
   	let didhelp= substitute(fname,'^\(.*\<doc\)[/\\][^.]*\.\(txt\|..x\)$','\1','')
"	call Decho("didhelp<".didhelp.">")
   endif

   " update for next file
"   call Decho("update linenr= [linenr=".linenr."] + [fsize=".fsize."] = ".(linenr+fsize))
   let linenr= linenr + fsize
  endwhile

  " set up help
"  call Decho("about to set up help: didhelp<".didhelp.">")
  if didhelp != ""
   let htpath= s:Path(home."/".didhelp,"")
"   call Decho("exe helptags ".htpath)
   exe "helptags ".htpath
   echo "did helptags"
  endif

  " make sure a "Press ENTER..." prompt appears to keep the messages showing!
  while filecnt <= &ch
   echomsg " "
   let filecnt= filecnt + 1
  endwhile

  " record actions in <.VimballRecord>
  call s:RecordInFile(home)

  " restore events, delete tab and buffer
  exe "tabn ".vbtabnr
  setlocal nomod bh=wipe
  exe "tabn ".curtabnr
  exe "tabc ".vbtabnr
  call vimball#RestoreSettings()
  call s:ChgDir(curdir)

"  call Dret("vimball#Vimball")
endfun

" ---------------------------------------------------------------------
" vimball#RmVimball: remove any files, remove any directories made by any {{{2
"               previous vimball extraction based on a file of the current
"               name.
"  Usage:  RmVimball  (assume current file is a vimball; remove)
"          RmVimball vimballname
fun! vimball#RmVimball(...)
"  call Dfunc("vimball#RmVimball() a:0=".a:0)
  if exists("g:vimball_norecord")
"   call Dret("vimball#RmVimball : (g:vimball_norecord)")
   return
  endif

  if a:0 == 0
   let curfile= expand("%:tr")
"   call Decho("case a:0=0: curfile<".curfile."> (used expand(%:tr))")
  else
   if a:1 =~ '[\/]'
    call vimball#ShowMesg(s:USAGE,"RmVimball vimballname [path]")
"    call Dret("vimball#RmVimball : suspect a:1<".a:1.">")
    return
   endif
   let curfile= a:1
"   call Decho("case a:0=".a:0.": curfile<".curfile.">")
  endif
  if curfile =~ '\.vba$'
   let curfile= substitute(curfile,'\.vba','','')
  endif
  if a:0 >= 2
   let home= expand(a:2)
  else
   let home= s:VimballHome()
  endif
  let curdir = getcwd()
"  call Decho("home   <".home.">")
"  call Decho("curfile<".curfile.">")
"  call Decho("curdir <".curdir.">")

  call s:ChgDir(home)
  if filereadable(".VimballRecord")
"   call Decho(".VimballRecord is readable")
"   call Decho("curfile<".curfile.">")
   keepalt keepjumps 1split 
   silent! keepalt keepjumps e .VimballRecord
   let keepsrch= @/
"   call Decho("search for ^".curfile.".vba:")
"   call Decho("search for ^".curfile."[-0-9.]*.vba:")
   if search('^'.curfile.": ".'cw')
	let foundit= 1
   elseif search('^'.curfile.".vba: ",'cw')
	let foundit= 1
   elseif search('^'.curfile.'[-0-9.]*.vba: ','cw')
	let foundit= 1
   else
    let foundit = 0
   endif
   if foundit
	let exestring  = substitute(getline("."),'^'.curfile.'\S\{-}\.vba: ','','')
    let s:VBRstring= substitute(exestring,'call delete(','','g')
    let s:VBRstring= substitute(s:VBRstring,"[')]",'','g')
"	call Decho("exe ".exestring)
	silent! keepalt keepjumps exe exestring
	silent! keepalt keepjumps d
	let exestring= strlen(substitute(exestring,'call delete(.\{-})|\=',"D","g"))
"	call Decho("exestring<".exestring.">")
	echomsg "removed ".exestring." files"
   else
    let s:VBRstring= ''
	let curfile    = substitute(curfile,'\.vba','','')
"    call Decho("unable to find <".curfile."> in .VimballRecord")
	if !exists("s:ok_unablefind")
     call vimball#ShowMesg(s:WARNING,"(RmVimball) unable to find <".curfile."> in .VimballRecord")
	endif
   endif
   silent! keepalt keepjumps g/^\s*$/d
   silent! keepalt keepjumps wq!
   let @/= keepsrch
  endif
  call s:ChgDir(curdir)

"  call Dret("vimball#RmVimball")
endfun

" ---------------------------------------------------------------------
" vimball#Decompress: attempts to automatically decompress vimballs {{{2
fun! vimball#Decompress(fname)
"  call Dfunc("Decompress(fname<".a:fname.">)")

  " decompression:
  if     expand("%") =~ '.*\.gz'  && executable("gunzip")
   " handle *.gz with gunzip
   silent exe "!gunzip ".s:Escape(a:fname)
   if v:shell_error != 0
	call vimball#ShowMesg(s:WARNING,"(vimball#Decompress) gunzip may have failed with <".a:fname.">")
   endif
   let fname= substitute(a:fname,'\.gz$','','')
   exe "e ".escape(fname,' \')
   call vimball#ShowMesg(s:USAGE,"Source this file to extract it! (:so %)")

  elseif expand("%") =~ '.*\.gz' && executable("gzip")
   " handle *.gz with gzip -d
   silent exe "!gzip -d ".s:Escape(a:fname)
   if v:shell_error != 0
	call vimball#ShowMesg(s:WARNING,'(vimball#Decompress) "gzip -d" may have failed with <'.a:fname.">")
   endif
   let fname= substitute(a:fname,'\.gz$','','')
   exe "e ".escape(fname,' \')
   call vimball#ShowMesg(s:USAGE,"Source this file to extract it! (:so %)")

  elseif expand("%") =~ '.*\.bz2' && executable("bunzip2")
   " handle *.bz2 with bunzip2
   silent exe "!bunzip2 ".s:Escape(a:fname)
   if v:shell_error != 0
	call vimball#ShowMesg(s:WARNING,"(vimball#Decompress) bunzip2 may have failed with <".a:fname.">")
   endif
   let fname= substitute(a:fname,'\.bz2$','','')
   exe "e ".escape(fname,' \')
   call vimball#ShowMesg(s:USAGE,"Source this file to extract it! (:so %)")

  elseif expand("%") =~ '.*\.bz2' && executable("bzip2")
   " handle *.bz2 with bzip2 -d
   silent exe "!bzip2 -d ".s:Escape(a:fname)
   if v:shell_error != 0
	call vimball#ShowMesg(s:WARNING,'(vimball#Decompress) "bzip2 -d" may have failed with <'.a:fname.">")
   endif
   let fname= substitute(a:fname,'\.bz2$','','')
   exe "e ".escape(fname,' \')
   call vimball#ShowMesg(s:USAGE,"Source this file to extract it! (:so %)")

  elseif expand("%") =~ '.*\.zip' && executable("unzip")
   " handle *.zip with unzip
   silent exe "!unzip ".s:Escape(a:fname)
   if v:shell_error != 0
	call vimball#ShowMesg(s:WARNING,"(vimball#Decompress) unzip may have failed with <".a:fname.">")
   endif
   let fname= substitute(a:fname,'\.zip$','','')
   exe "e ".escape(fname,' \')
   call vimball#ShowMesg(s:USAGE,"Source this file to extract it! (:so %)")
  endif

  set noma bt=nofile fmr=[[[,]]] fdm=marker

"  call Dret("Decompress")
endfun

" ---------------------------------------------------------------------
" vimball#ShowMesg: {{{2
fun! vimball#ShowMesg(level,msg)
"  call Dfunc("vimball#ShowMesg(level=".a:level." msg<".a:msg.">)")
  let rulerkeep   = &ruler
  let showcmdkeep = &showcmd
  set noruler noshowcmd
  redraw!

  if &fo =~ '[ta]'
   echomsg "***vimball*** " a:msg
  else
   if a:level == s:WARNING || a:level == s:USAGE
    echohl WarningMsg
   elseif a:level == s:ERROR
    echohl Error
   endif
   echomsg "***vimball*** " a:msg
   echohl None
  endif

  if a:level != s:USAGE
   call inputsave()|let ok= input("Press <cr> to continue")|call inputrestore()
  endif

  let &ruler   = rulerkeep
  let &showcmd = showcmdkeep

"  call Dret("vimball#ShowMesg")
endfun
" =====================================================================
" s:ChgDir: change directory (in spite of Windoze) {{{2
fun! s:ChgDir(newdir)
"  call Dfunc("ChgDir(newdir<".a:newdir.">)")
  if (has("win32") || has("win95") || has("win64") || has("win16"))
   exe 'silent cd '.fnameescape(substitute(a:newdir,'/','\\','g'))
  else
   exe 'silent cd '.fnameescape(a:newdir)
  endif
"  call Dret("ChgDir : curdir<".getcwd().">")
endfun

" ---------------------------------------------------------------------
" s:Path: prepend and append quotes and do escaping {{{2
fun! s:Path(cmd,quote)
"  call Dfunc("Path(cmd<".a:cmd."> quote<".a:quote.">) vimball_path_escape<".g:vimball_path_escape.">")
  if (has("win32") || has("win95") || has("win64") || has("win16"))
"   let cmdpath= a:quote.substitute(a:cmd,'/','\\','g').a:quote
   let cmdpath= a:quote.substitute(a:cmd,'\\','/','g').a:quote
"   call Decho("cmdpath<".cmdpath."> (win32 mod)")
  else
   let cmdpath= a:quote.a:cmd.a:quote
"   call Decho("cmdpath<".cmdpath."> (not-win32 mod)")
  endif
  if a:quote == "" && g:vimball_path_escape !~ ' '
   let cmdpath= escape(cmdpath,' ')
"   call Decho("cmdpath<".cmdpath."> (empty quote case)")
  endif
  let cmdpath= escape(cmdpath,g:vimball_path_escape)
"  call Dret("Path <".cmdpath.">")
  return cmdpath
endfun

" ---------------------------------------------------------------------
" s:RecordInVar: record a un-vimball command in the .VimballRecord file {{{2
fun! s:RecordInVar(home,cmd)
"  call Dfunc("RecordInVar(home<".a:home."> cmd<".a:cmd.">)")
  if a:cmd =~ '^rmdir'
"   if !exists("s:recorddir")
"    let s:recorddir= substitute(a:cmd,'^rmdir',"call s:Rmdir",'')
"   else
"    let s:recorddir= s:recorddir."|".substitute(a:cmd,'^rmdir',"call s:Rmdir",'')
"   endif
  elseif !exists("s:recordfile")
   let s:recordfile= a:cmd
  else
   let s:recordfile= s:recordfile."|".a:cmd
  endif
"  call Dret("RecordInVar : s:recordfile<".(exists("s:recordfile")? s:recordfile : "")."> s:recorddir<".(exists("s:recorddir")? s:recorddir : "").">")
endfun

" ---------------------------------------------------------------------
" s:RecordInFile: {{{2
fun! s:RecordInFile(home)
"  call Dfunc("s:RecordInFile()")
  if exists("g:vimball_norecord")
"   call Dret("s:RecordInFile : g:vimball_norecord")
   return
  endif

  if exists("s:recordfile") || exists("s:recorddir")
   let curdir= getcwd()
   call s:ChgDir(a:home)
   keepalt keepjumps 1split 

   let cmd= expand("%:tr").": "
"   call Decho("cmd<".cmd.">")

   silent! keepalt keepjumps e .VimballRecord
   setlocal ma
   $
   if exists("s:recordfile") && exists("s:recorddir")
   	let cmd= cmd.s:recordfile."|".s:recorddir
   elseif exists("s:recorddir")
   	let cmd= cmd.s:recorddir
   elseif exists("s:recordfile")
   	let cmd= cmd.s:recordfile
   else
"    call Dret("s:RecordInFile : neither recordfile nor recorddir exist")
	return
   endif
"   call Decho("cmd<".cmd.">")

   " put command into buffer, write .VimballRecord `file
   keepalt keepjumps put=cmd
   silent! keepalt keepjumps g/^\s*$/d
   silent! keepalt keepjumps wq!
   call s:ChgDir(curdir)

   if exists("s:recorddir")
"	call Decho("unlet s:recorddir<".s:recorddir.">")
   	unlet s:recorddir
   endif
   if exists("s:recordfile")
"	call Decho("unlet s:recordfile<".s:recordfile.">")
   	unlet s:recordfile
   endif
  else
"   call Decho("s:record[file|dir] doesn't exist")
  endif

"  call Dret("s:RecordInFile")
endfun

" ---------------------------------------------------------------------
" s:VimballHome: determine/get home directory path (usually from rtp) {{{2
fun! s:VimballHome()
"  call Dfunc("VimballHome()")
  if exists("g:vimball_home")
   let home= g:vimball_home
  else
   " go to vim plugin home
   for home in split(&rtp,',') + ['']
    if isdirectory(home) && filewritable(home) | break | endif
	let basehome= substitute(home,'[/\\]\.vim$','','')
    if isdirectory(basehome) && filewritable(basehome)
	 let home= basehome."/.vim"
	 break
	endif
   endfor
   if home == ""
    " just pick the first directory
    let home= substitute(&rtp,',.*$','','')
   endif
   if (has("win32") || has("win95") || has("win64") || has("win16"))
    let home= substitute(home,'/','\\','g')
   endif
  endif
  " insure that the home directory exists
"  call Decho("picked home<".home.">")
  if !isdirectory(home)
   if exists("g:vimball_mkdir")
"	call Decho("home<".home."> isn't a directory -- making it now with g:vimball_mkdir<".g:vimball_mkdir.">")
"    call Decho("system(".g:vimball_mkdir." ".s:Escape(home).")")
    call system(g:vimball_mkdir." ".s:Escape(home))
   else
"	call Decho("home<".home."> isn't a directory -- making it now with mkdir()")
    call mkdir(home)
   endif
  endif
"  call Dret("VimballHome <".home.">")
  return home
endfun

" ---------------------------------------------------------------------
" vimball#SaveSettings: {{{2
fun! vimball#SaveSettings()
"  call Dfunc("SaveSettings()")
  let s:makeep  = getpos("'a")
  let s:regakeep= @a
  if exists("&acd")
   let s:acdkeep = &acd
  endif
  let s:eikeep  = &ei
  let s:fenkeep = &fen
  let s:hidkeep = &hidden
  let s:ickeep  = &ic
  let s:lzkeep  = &lz
  let s:pmkeep  = &pm
  let s:repkeep = &report
  let s:vekeep  = &ve
  let s:ffkeep  = &ff
  if exists("&acd")
   setlocal ei=all ve=all noacd nofen noic report=999 nohid bt= ma lz pm= ff=unix
  else
   setlocal ei=all ve=all       nofen noic report=999 nohid bt= ma lz pm= ff=unix
  endif
  " vimballs should be in unix format
  setlocal ff=unix
"  call Dret("SaveSettings")
endfun

" ---------------------------------------------------------------------
" vimball#RestoreSettings: {{{2
fun! vimball#RestoreSettings()
"  call Dfunc("RestoreSettings()")
  let @a      = s:regakeep
  if exists("&acd")
   let &acd   = s:acdkeep
  endif
  let &fen    = s:fenkeep
  let &hidden = s:hidkeep
  let &ic     = s:ickeep
  let &lz     = s:lzkeep
  let &pm     = s:pmkeep
  let &report = s:repkeep
  let &ve     = s:vekeep
  let &ei     = s:eikeep
  let &ff     = s:ffkeep
  if s:makeep[0] != 0
   " restore mark a
"   call Decho("restore mark-a: makeep=".string(makeep))
   call setpos("'a",s:makeep)
  endif
  if exists("&acd")
   unlet s:acdkeep
  endif
  unlet s:regakeep s:eikeep s:fenkeep s:hidkeep s:ickeep s:repkeep s:vekeep s:makeep s:lzkeep s:pmkeep s:ffkeep
"  call Dret("RestoreSettings")
endfun

" ---------------------------------------------------------------------
" s:Escape: {{{2
fun s:Escape(name)
  " shellescape() was added by patch 7.0.111
  if exists("*shellescape")
    return shellescape(a:name)
  endif
  return g:netrw_shq . a:name . g:netrw_shq
endfun

" ---------------------------------------------------------------------
"  Restore:
let &cpo= s:keepcpo
unlet s:keepcpo

" ---------------------------------------------------------------------
" Modelines: {{{1
" vim: fdm=marker
plugin/vimballPlugin.vim	[[[1
36
" vimballPlugin : construct a file containing both paths and files
" Author: Charles E. Campbell, Jr.
" Copyright: (c) 2004-2007 by Charles E. Campbell, Jr.
"            The VIM LICENSE applies to Vimball.vim, and Vimball.txt
"            (see |copyright|) except use "Vimball" instead of "Vim".
"            No warranty, express or implied.
"  *** ***   Use At-Your-Own-Risk!   *** ***
"
" (Rom 2:1 WEB) Therefore you are without excuse, O man, whoever you are who
"      judge. For in that which you judge another, you condemn yourself. For
"      you who judge practice the same things.
" GetLatestVimScripts: 1502 1 :AutoInstall: vimball.vim

" ---------------------------------------------------------------------
"  Load Once: {{{1
if &cp || exists("g:loaded_vimballPlugin")
 finish
endif
let g:loaded_vimballPlugin = "v26"
let s:keepcpo              = &cpo
set cpo&vim

" ------------------------------------------------------------------------------
" Public Interface: {{{1
com! -ra   -complete=file -na=+ -bang MkVimball call vimball#MkVimball(<line1>,<line2>,<bang>0,<f-args>)
com! -na=? -complete=dir  UseVimball  call vimball#Vimball(1,<f-args>)
com! -na=0                VimballList call vimball#Vimball(0)
com! -na=* -complete=dir  RmVimball   call vimball#SaveSettings()|call vimball#RmVimball(<f-args>)|call vimball#RestoreSettings()
au BufEnter  *.vba.gz,*.vba.bz2,*.vba.zip call vimball#Decompress(expand("<amatch>"))
au BufEnter  *.vba setlocal ff=unix noma bt=nofile fmr=[[[,]]] fdm=marker|call vimball#ShowMesg(0,"Source this file to extract it! (:so %)")

" =====================================================================
" Restoration And Modelines: {{{1
" vim: fdm=marker
let &cpo= s:keepcpo
unlet s:keepcpo
doc/pi_vimball.txt	[[[1
201
*pi_vimball.txt*	For Vim version 7.1.  Last change: 2008 May 30

			       ----------------
			       Vimball Archiver
			       ----------------

Author:  Charles E. Campbell, Jr.  <NdrOchip@ScampbellPfamily.AbizM>
	  (remove NOSPAM from Campbell's email first)
Copyright: (c) 2004-2008 by Charles E. Campbell, Jr.	*Vimball-copyright*
	   The VIM LICENSE applies to Vimball.vim, and Vimball.txt
	   (see |copyright|) except use "Vimball" instead of "Vim".
	   No warranty, express or implied.
	   Use At-Your-Own-Risk!

==============================================================================
1. Contents				*vba* *vimball* *vimball-contents*

	1. Contents......................................: |vimball-contents|
	3. Vimball Manual................................: |vimball-manual|
	   MkVimball.....................................: |:MkVimball|
	   UseVimball....................................: |:UseVimball|
	   RmVimball.....................................: |:RmVimball|
	4. Vimball History...............................: |vimball-history|


==============================================================================
2. Vimball Introduction						*vimball-intro*

	Vimball is intended to make life simpler for users of plugins.  All
	a user needs to do with a vimball is: >
		vim someplugin.vba
		:so %
		:q
<	and the plugin and all its components will be installed into their
	appropriate directories.  Note that one doesn't need to be in any
	particular directory when one does this.  Plus, any help for the
	plugin will also be automatically installed.

	If a user has decided to use the AsNeeded plugin, vimball is smart
	enough to put scripts nominally intended for .vim/plugin/ into
	.vim/AsNeeded/ instead.

	Removing a plugin that was installed with vimball is really easy: >
		vim
		:RmVimball someplugin
<	This operation is not at all easy for zips and tarballs, for example.

	Vimball examines the user's |'runtimepath'| to determine where to put
	the scripts.  The first directory mentioned on the runtimepath is
	usually used if possible.  Use >
		:echo &rtp
<	to see that directory.


==============================================================================
3. Vimball Manual					*vimball-manual*

							*:MkVimball*
		:[range]MkVimball[!] filename [path]

	The range is composed of lines holding paths to files to be included
	in your new vimball, omitting the portion of the paths that is
	normally specified by the runtimepath (|'rtp'|).  As an example: >
		plugin/something.vim
		doc/something.txt
<	using >
		:[range]MkVimball filename
<
	on this range of lines will create a file called "filename.vba" which
	can be used by Vimball.vim to re-create these files.  If the
	"filename.vba" file already exists, then MkVimball will issue a
	warning and not create the file.  Note that these paths are relative
	to your .vim (vimfiles) directory, and the files should be in that
	directory.  The vimball plugin normally uses the first |'runtimepath'|
	directory that exists as a prefix; don't use absolute paths, unless
	the user has specified such a path.

	If you use the exclamation point (!), then MkVimball will create the
	"filename.vba" file, overwriting it if it already exists.  This
	behavior resembles that for |:w|.

							*g:vimball_mkdir*
	First, the |mkdir()| command is tried (not all systems support it).

	If it doesn't exist, then g:vimball_mkdir doesn't exist, it is set to:
	  |g:netrw_local_mkdir|, if it exists
	   "mkdir", if it is executable
	   "makedir", if it is executable
	   Otherwise, it is undefined.
	One may explicitly specify the directory making command using
	g:vimball_mkdir.  This command is used to make directories that
	are needed as indicated by the vimball.

							*g:vimball_home*
	You may override the use of the |'runtimepath'| by specifying a
	variable, g:vimball_home.

	Path Preprocessing				*g:vimball_path_escape*

	Paths used in vimball are preprocessed by s:Path(); in addition,
	certain characters are escaped (by prepending a backslash).  The
	characters are in g:vimball_path_escape, and may be overridden by
	the user in his/her .vimrc initialization script.

							*vimball-extract*
		vim filename.vba

	Simply editing a Vimball will cause Vimball.vim to tell the user to
	source the file to extract its contents.

	Extraction will only proceed if the first line of a putative vimball
	file holds the "Vimball Archiver by Charles E. Campbell, Jr., Ph.D."
	line.

		:VimballList				*:VimballList*

	This command will tell Vimball to list the files in the archive, along
	with their lengths in lines.

		:UseVimball [path]			*:UseVimball*

	This command is contained within the vimball itself; it invokes the
	vimball#Vimball() routine which is responsible for unpacking the
	vimball.  One may choose to execute it by hand instead of sourcing
	the vimball; one may also choose to specify a path for the
	installation, thereby overriding the automatic choice of the first
	existing directory on the |'runtimepath'|.

		:RmVimball vimballfile [path]		*:RmVimball*

	This command removes all files generated by the specified vimball
	(but not any directories it may have made).  One may choose a path
	for de-installation, too (see |'runtimepath'|); otherwise, the
	default is the first existing directory on the |'runtimepath'|.
	To implement this, a file (.VimballRecord) is made in that directory
	containing a record of what files need to be removed for all vimballs
	used thus far.


==============================================================================
4. Vimball History					*vimball-history* {{{1

	26 : May 27, 2008 * g:vimball_mkdir usage installed.  Makes the
	                    $HOME/.vim (or $HOME\vimfiles) directory if
			    necessary.
	     May 30, 2008 * (tnx to Bill McCarthy) found and fixed a bug:
			    vimball wasn't updating plugins to AsNeeded/
			    when it should
	25 : Mar 24, 2008 * changed vimball#Vimball() to recognize doc/*.??x
			    files as help files, too.
	     Apr 18, 2008 * RmVimball command is now protected by saving and
	                    restoring settings -- in particular, acd was
			    causing problems as reported by Zhang Shuhan
	24 : Nov 15, 2007 * |g:vimball_path_escape| used by s:Path() to
	                    prevent certain characters from causing trouble
	22 : Mar 21, 2007 * uses setlocal instead of set during BufEnter
	21 : Nov 27, 2006 * (tnx to Bill McCarthy) vimball had a header
	                    handling problem and it now changes \s to /s
	20 : Nov 20, 2006 * substitute() calls have all had the 'e' flag
	                    removed.
	18 : Aug 01, 2006 * vimballs now use folding to easily display their
	                    contents.
			  * if a user has AsNeeded/somefile, then vimball
			    will extract plugin/somefile to the AsNeeded/
			    directory
	17 : Jun 28, 2006 * changes all \s to /s internally for Windows
	16 : Jun 15, 2006 * A. Mechylynck's idea to allow users to specify
			    installation root paths implemented for
			    UseVimball, MkVimball, and RmVimball.
			  * RmVimball implemented
	15 : Jun 13, 2006 * bugfix
	14 : May 26, 2006 * bugfixes
	13 : May 01, 2006 * exists("&acd") used to determine if the acd
			    option exists
	12 : May 01, 2006 * bugfix - the |'acd'| option is not always defined
	11 : Apr 27, 2006 * VimballList would create missing subdirectories that
			    the vimball specified were needed.  Fixed.
	10 : Apr 27, 2006 * moved all setting saving/restoration to a pair of
			    functions.  Included some more settings in them
			    which frequently cause trouble.
	9  : Apr 26, 2006 * various changes to support Windows' predilection
			    for backslashes and spaces in file and directory
			    names.
	7  : Apr 25, 2006 * bypasses foldenable
			  * uses more exe and less norm! (:yank :put etc)
			  * does better at insuring a "Press ENTER" prompt
			    appears to keep its messages visible
	4  : Mar 31, 2006 * BufReadPost seems to fire twice; BufReadEnter
			    only fires once, so the "Source this file..."
			    message is now issued only once.
	3  : Mar 20, 2006 * removed query, now requires sourcing to be
			    extracted (:so %).  Message to that effect
			    included.
			  * :VimballList  now shows files that would be
			    extracted.
	2  : Mar 20, 2006 * query, :UseVimball included
	1  : Mar 20, 2006 * initial release


==============================================================================
vim:tw=78:ts=8:ft=help:fdm=marker
