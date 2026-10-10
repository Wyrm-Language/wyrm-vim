" Vim filetype plugin
" Language:   Wyrm
"
" Options:
"   g:wyrm_recommended_style = 0   don't set expandtab / shiftwidth=4

if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

let s:cpo_save = &cpo
set cpo&vim

setlocal comments=:#
setlocal commentstring=#\ %s
setlocal iskeyword=@,48-57,_,$
setlocal formatoptions-=t formatoptions+=croql
setlocal suffixesadd=.wy,.wyrm

" gf / [i on `import std::io` and `from std::io import x`: std::io -> std/io.wy.
setlocal include=^\\s*\\%(import\\\|from\\)\\s\\+
setlocal includeexpr=substitute(v:fname,'::','/','g')
setlocal isfname+=:
for s:dir in split($WYRM_PATH, ':')
  execute 'setlocal path+=' .. fnameescape(s:dir)
endfor
unlet! s:dir

let b:undo_ftplugin = 'setlocal comments< commentstring< iskeyword< formatoptions<'
      \ .. ' suffixesadd< include< includeexpr< isfname< path<'

if get(g:, 'wyrm_recommended_style', 1)
  setlocal expandtab shiftwidth=4 softtabstop=4 tabstop=8
  let b:undo_ftplugin ..= ' | setlocal expandtab< shiftwidth< softtabstop< tabstop<'
endif

let &cpo = s:cpo_save
unlet s:cpo_save
