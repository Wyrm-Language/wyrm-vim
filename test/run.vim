" Headless test runner: vim -Nu NONE -i NONE -Es -S test/run.vim
"
" test/syntax/*.wy use the assertion format of wyrm-vscode's test/grammar, with Vim
" syntax group names in place of TextMate scopes. An assertion line refers to the
" closest source line above it:
"   # <- wyrmGroup            column 1 has wyrmGroup
"   #    ^^^ wyrmGroup        the marked columns have wyrmGroup
" NONE as the group name asserts no syntax group.
"
" test/indent/*.wy are re-indented with `gg=G` and must come out unchanged.

let s:root = fnamemodify(expand('<sfile>'), ':p:h:h')
let &runtimepath = s:root .. ',' .. &runtimepath
filetype plugin indent on
syntax on

let s:failures = []
let s:checked = 0

function! s:Fail(file, lnum, msg) abort
  call add(s:failures, printf('%s:%d: %s', fnamemodify(a:file, ':.'), a:lnum, a:msg))
endfunction

function! s:CheckSyntax(file) abort
  execute 'silent edit ' .. fnameescape(a:file)
  if &filetype !=# 'wyrm'
    call s:Fail(a:file, 1, 'filetype is "' .. &filetype .. '", not wyrm')
    return
  endif
  let source = 0
  for lnum in range(1, line('$'))
    let text = getline(lnum)
    if text =~# '^# SYNTAX TEST'
      continue
    endif
    let m = matchlist(text, '^#\s*<-\s*\(\w\+\)\s*$')
    if !empty(m)
      let cols = [1]
    else
      let m = matchlist(text, '^#\(\s*\)\(\^\+\)\s\+\(\w\+\)\s*$')
      if empty(m)
        let source = lnum
        continue
      endif
      let start = 1 + len(m[1]) + 1
      let cols = range(start, start + len(m[2]) - 1)
      let m[1] = m[3]
    endif
    if source == 0
      call s:Fail(a:file, lnum, 'assertion before any source line')
      continue
    endif
    for col in cols
      let s:checked += 1
      let got = synIDattr(synID(source, col, 1), 'name')
      if got !=# (m[1] ==# 'NONE' ? '' : m[1])
        call s:Fail(a:file, lnum, printf('line %d col %d: want %s, got %s',
              \ source, col, m[1], empty(got) ? '(none)' : got))
      endif
    endfor
  endfor
endfunction

function! s:CheckIndent(file) abort
  execute 'silent edit ' .. fnameescape(a:file)
  let want = getline(1, '$')
  silent normal! gg=G
  let got = getline(1, '$')
  let s:checked += 1
  for i in range(len(want))
    if got[i] !=# want[i]
      call s:Fail(a:file, i + 1, printf('want %s, got %s', string(want[i]), string(got[i])))
    endif
  endfor
  silent edit!
endfunction

for s:file in glob(s:root .. '/test/syntax/*.wy', 0, 1)
  call s:CheckSyntax(s:file)
endfor
for s:file in glob(s:root .. '/test/indent/*.wy', 0, 1)
  call s:CheckIndent(s:file)
endfor

if empty(s:failures)
  call writefile([printf('ok: %d checks', s:checked)], '/dev/stdout')
  qall!
endif
call writefile(s:failures + [printf('%d of %d checks failed', len(s:failures), s:checked)],
      \ '/dev/stderr')
cquit!
