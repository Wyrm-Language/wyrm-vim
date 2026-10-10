" Vim syntax file
" Language:   Wyrm
" Filenames:  *.wy, *.wyrm
"
" Ported from wyrm-vscode's syntaxes/wyrm.tmLanguage.json. The language definition is
" doc/grammar.md and src/embed/wyrm/tokenizer.wy in the wyrm repository.
"
" Options:
"   g:wyrm_highlight_calls = 1   highlight the callee in `name(...)` as a function

if exists('b:current_syntax')
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

syn case match
syn iskeyword @,48-57,_,$
syn sync minlines=300

" Keywords --------------------------------------------------------------------------
" Hard keywords: _HARD_KEYWORDS in tokenizer.wy (true/false/nil are under Constants).

syn keyword wyrmConditional   if elif else
syn keyword wyrmRepeat        for while break continue
syn keyword wyrmStatement     return yield pass
syn keyword wyrmException     try catch
syn keyword wyrmException     defer nextgroup=wyrmDeferOnError skipwhite
syn match   wyrmDeferOnError  contained "\<on\s\+error\>"
syn keyword wyrmInclude       import from as except
syn keyword wyrmConcurrency   emit signal task thread
syn keyword wyrmKeyword       do
syn keyword wyrmStorage       var slot
syn keyword wyrmStorageClass  static with
syn keyword wyrmOperatorWord  and or not in is
syn match   wyrmSlotOption    "\<\%(setter\|getter\)\>\ze\s*=[^=]"

" Declarations: `fn name`, `fn [A, B] name`, `co name`, `class Name(Parent)`.
syn keyword wyrmDefine        fn co nextgroup=wyrmFuncName,wyrmReceivers skipwhite
syn keyword wyrmDefine        class nextgroup=wyrmClassName skipwhite
syn match   wyrmFuncName      contained "\h[[:alnum:]_$]*"
syn region  wyrmReceivers     contained matchgroup=wyrmDelimiter start="\[" end="\]"
      \ contains=wyrmReceiverType,wyrmComment nextgroup=wyrmFuncName skipwhite
syn match   wyrmReceiverType  contained "\h[[:alnum:]_$]*"
syn match   wyrmClassName     contained "\h[[:alnum:]_$]*" nextgroup=wyrmClassParen skipwhite
syn match   wyrmClassParen    contained "(\s*" nextgroup=wyrmClassParent
syn match   wyrmClassParent   contained "\h[[:alnum:]_$]*"

" Constants -------------------------------------------------------------------------

syn keyword wyrmBoolean       true false
syn keyword wyrmNil           nil undefined
syn keyword wyrmSelf          this super

" Builtins --------------------------------------------------------------------------
" Fundamental types (language-spec.md) are ordinary identifiers, not reserved words.
" `pair` is a match rather than a keyword so the call form below can win over it.

syn keyword wyrmBuiltinType   bool int uint float sym bytes str tuple list dict array
      \ fiber closure coroutine message object error file
syn match   wyrmBuiltinType   "\<pair\>"
syn keyword wyrmBuiltinClass  Unset NotFound OutOfMemory StopIteration RuntimeError OSError

if get(g:, 'wyrm_highlight_calls', 0)
  syn match wyrmFunctionCall  "\<\h[[:alnum:]_$]*\ze\s*("
endif
syn match   wyrmBuiltinFunc   "\<\%(defined\|print\|len\|copy\|cons\|pair\|car\|cdr\|next\|send\)\ze\s*("
syn match   wyrmBuiltinFunc   "\.\s*\zs\%(substr\|remove\|resize\|expand\|append\)\ze\s*("

" Operators and punctuation ---------------------------------------------------------
" Defined before the literals that start with the same characters, so those win.

syn match   wyrmOperator      "[-+*/%&|^~<>=!]"
syn match   wyrmOperator      "\*\*\|<<\|>>\|<=>\|==\|!=\|<=\|>=\|->\|<-"
syn match   wyrmDeclare       ":=\|?="
syn match   wyrmPairList      "\$\["
syn match   wyrmMessage       "!\s*\h[[:alnum:]_$]*"
syn match   wyrmNamespace     "\<\h[[:alnum:]_$]*\ze\s*::"
syn match   wyrmScope         "::"
syn match   wyrmScope         "::\s*\*"
syn match   wyrmAstRef        "\%(::\s*\)\@<=\$ast\>"
syn match   wyrmDecorator     "@\s*\%(\h[[:alnum:]_$]*\s*::\s*\)*\h[[:alnum:]_$]*"
syn match   wyrmEllipsis      "\.\.\."

" Literals --------------------------------------------------------------------------

" A leading '-' is the arithmetic operator, not part of the literal.
syn match   wyrmNumber        "\<\d[0-9_]*\>"
syn match   wyrmFloat         "\<\d[0-9_]*\.\%(\d[0-9_]*\)\=\%([eE][-+]\=\d\+\)\=\%([[:alnum:]_.]\)\@!"
syn match   wyrmFloat         "\<\d[0-9_]*[eE][-+]\=\d\+\>"
syn match   wyrmNumber        "\<0x\x[[:xdigit:]_]*\>"
syn match   wyrmNumber        "\<0b[01][01_]*\>"

" Symbols: 'name, and the operator symbols in _OPERATOR_SYMBOLS plus '::.
syn match   wyrmSymbol        "'\h[[:alnum:]_$]*"
syn match   wyrmSymbol        "'\%(\.\.\.\|<=>\|\*\*\|<<\|>>\|==\|!=\|<=\|>=\|::\|[-+*/%&|^~<>]\)"

" Clojure-style characters: \a, \(, \newline. Any other multi-letter name is an error.
syn match   wyrmCharacter     "\\\_."
syn match   wyrmCharError     "\\\h[[:alnum:]_]\+"
syn match   wyrmCharacter     "\\\%(newline\|space\|tab\|return\|backspace\|formfeed\|null\)\>"

syn match   wyrmEscape        contained "\\."
" A plain string ends at its closing quote, or at a line end not escaped by '\'.
syn region  wyrmString        start=+"+ skip=+\\\\\|\\"+ end=+"+ end=+\\\@1<!$+
      \ contains=wyrmEscape,@Spell
syn region  wyrmString        start=+"""+ skip=+\\\\\|\\"+ end=+"""+ keepend
      \ contains=wyrmEscape,@Spell
syn region  wyrmRawString     start=+R"\z([A-Za-z0-9_]*\)(+ end=+)\z1"+ contains=@Spell

syn keyword wyrmTodo          contained TODO FIXME XXX NOTE
syn match   wyrmComment       "#.*$" contains=wyrmTodo,@Spell

" Links -----------------------------------------------------------------------------

hi def link wyrmConditional   Conditional
hi def link wyrmRepeat        Repeat
hi def link wyrmStatement     Statement
hi def link wyrmException     Exception
hi def link wyrmDeferOnError  Exception
hi def link wyrmInclude       Include
hi def link wyrmConcurrency   Keyword
hi def link wyrmKeyword       Keyword
hi def link wyrmStorage       StorageClass
hi def link wyrmStorageClass  StorageClass
hi def link wyrmOperatorWord  Operator
hi def link wyrmSlotOption    Keyword
hi def link wyrmDefine        Define
hi def link wyrmFuncName      Function
hi def link wyrmReceiverType  Type
hi def link wyrmClassName     Type
hi def link wyrmClassParent   Type
hi def link wyrmBoolean       Boolean
hi def link wyrmNil           Constant
hi def link wyrmSelf          Identifier
hi def link wyrmBuiltinType   Type
hi def link wyrmBuiltinClass  Type
hi def link wyrmFunctionCall  Function
hi def link wyrmBuiltinFunc   Function
hi def link wyrmOperator      Operator
hi def link wyrmDeclare       Operator
hi def link wyrmPairList      Delimiter
hi def link wyrmDelimiter     Delimiter
hi def link wyrmMessage       Function
hi def link wyrmNamespace     Identifier
hi def link wyrmScope         Operator
hi def link wyrmAstRef        Special
hi def link wyrmDecorator     PreProc
hi def link wyrmEllipsis      Constant
hi def link wyrmNumber        Number
hi def link wyrmFloat         Float
hi def link wyrmSymbol        Constant
hi def link wyrmCharacter     Character
hi def link wyrmCharError     Error
hi def link wyrmEscape        SpecialChar
hi def link wyrmString        String
hi def link wyrmRawString     String
hi def link wyrmTodo          Todo
hi def link wyrmComment       Comment

let b:current_syntax = 'wyrm'

let &cpo = s:cpo_save
unlet s:cpo_save
