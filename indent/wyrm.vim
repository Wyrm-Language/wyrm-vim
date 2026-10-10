" Vim indent file
" Language:   Wyrm
"
" Wyrm blocks are either `:` plus an indented body (offside rule) or `{ ... }`.
" The next line is indented after a trailing `:` or an unclosed bracket, a closing
" bracket lines up with its opener's line, and `elif` / `else` / `catch` line up with
" the `if` / `try` they continue. Dedenting out of a `:` block is left to the user.

if exists('b:did_indent')
  finish
endif
let b:did_indent = 1

setlocal autoindent
setlocal indentexpr=GetWyrmIndent(v:lnum)
setlocal indentkeys=!^F,o,O,0},0],0),=elif,=else,=catch

let b:undo_indent = 'setlocal autoindent< indentexpr< indentkeys<'

if exists('*GetWyrmIndent')
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

" True when the character at (lnum, col) is inside a string, character or comment.
function! s:IsLiteral(lnum, col) abort
  return synIDattr(synID(a:lnum, a:col, 1), 'name') =~# 'String\|Comment\|Character\|Escape\|Todo'
endfunction

" The previous line that is not blank and not a comment-only line.
function! s:PrevCodeLine(lnum) abort
  let lnum = prevnonblank(a:lnum - 1)
  while lnum > 0 && getline(lnum) =~# '^\s*#'
    let lnum = prevnonblank(lnum - 1)
  endwhile
  return lnum
endfunction

" Column of the last character of a line that is code, or 0.
function! s:LastCodeCol(lnum) abort
  let line = getline(a:lnum)
  let col = len(line)
  while col > 0 && (line[col - 1] =~# '\s' || s:IsLiteral(a:lnum, col))
    let col -= 1
  endwhile
  return col
endfunction

" Net brackets opened on a line (ignoring literals), and the column of the first
" closing bracket that has no opener on the same line.
function! s:Brackets(lnum) abort
  let line = getline(a:lnum)
  let depth = 0
  let min_depth = 0
  let unmatched_close = 0
  for col in range(1, len(line))
    let ch = line[col - 1]
    if ch !~# '[][(){}]' || s:IsLiteral(a:lnum, col)
      continue
    endif
    let depth += ch =~# '[[({]' ? 1 : -1
    if depth < min_depth
      let min_depth = depth
      let unmatched_close = col
    endif
  endfor
  return [depth - min_depth, unmatched_close]
endfunction

" Line of the bracket that the closer at (lnum, col) closes, or 0.
function! s:OpenerLine(lnum, col) abort
  let ch = getline(a:lnum)[a:col - 1]
  let pairs = {')': ['(', ')'], ']': ['\[', '\]'], '}': ['{', '}']}
  let save = getcurpos()
  call cursor(a:lnum, a:col)
  let found = searchpair(pairs[ch][0], '', pairs[ch][1], 'bnW',
        \ 's:IsLiteral(line("."), col("."))', max([1, a:lnum - 500]))
  call setpos('.', save)
  return found > 0 ? found : 0
endfunction

function! GetWyrmIndent(lnum) abort
  let line = getline(a:lnum)
  if s:IsLiteral(a:lnum, 1) && synIDattr(synID(a:lnum, 1, 1), 'name') =~# 'String'
    return -1
  endif

  " A line starting with a closer lines up with the opener's line.
  let first = match(line, '\S') + 1
  if first > 0 && line[first - 1] =~# '[])}]'
    let opener = s:OpenerLine(a:lnum, first)
    if opener > 0
      return indent(opener)
    endif
  endif

  let prev = s:PrevCodeLine(a:lnum)
  if prev == 0
    return 0
  endif

  " `elif` / `else` / `catch` line up with the nearest shallower `if` / `elif` / `try`.
  if line =~# '^\s*\%(elif\|else\|catch\)\>'
    let cur = indent(a:lnum)
    let lnum = prev
    while lnum > 0
      if indent(lnum) < cur && getline(lnum) =~# '^\s*\%(if\|elif\|try\|catch\|for\|while\)\>'
        return indent(lnum)
      endif
      let lnum = s:PrevCodeLine(lnum)
    endwhile
    return max([0, indent(prev) - shiftwidth()])
  endif

  " Base: the previous line's indent, or, if it closes a bracket opened on an earlier
  " line, the indent of the line that opened it.
  let [opened, unmatched_close] = s:Brackets(prev)
  let base = indent(prev)
  if unmatched_close > 0
    let opener = s:OpenerLine(prev, unmatched_close)
    if opener > 0
      let base = indent(opener)
    endif
  endif

  let last = s:LastCodeCol(prev)
  let last_ch = last > 0 ? getline(prev)[last - 1] : ''
  if opened > 0 || last_ch ==# ':'
    return base + shiftwidth()
  endif

  " A block usually ends after these.
  let target = base
  if getline(prev) =~# '^\s*\%(return\|break\|continue\|pass\)\>' && last_ch !=# '}'
    let target = max([0, base - shiftwidth()])
  endif

  " Nothing says where an offside block ends, so a line already dedented further
  " than the target keeps its indent.
  return indent(a:lnum) < target ? -1 : target
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save
