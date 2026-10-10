# Agent Development Guide

Vim runtime plugin for the Wyrm language: filetype detection, syntax, ftplugin and indent.
Plain Vim script; no build step. This is *not* the handcrafted `wyrm` repository.

- Canonical language definition: `doc/grammar.md` and `src/embed/wyrm/tokenizer.wy` in the
  `wyrm` repository. `syntax/wyrm.vim` is a port of wyrm-vscode's
  `syntaxes/wyrm.tmLanguage.json`; keep the two in step.
- Add a `test/syntax/*.wy` assertion for every syntax rule you touch.
- `vim -Nu NONE -i NONE -Es -S test/run.vim` must pass before committing. Vim's terminal
  output can hide the result in captured shells; redirect to a file if you see nothing.
- Vim gives `syn keyword` priority over `syn match`/`syn region` at the same position.
  Anything a match must override (for example `pair` as a call vs. a type) has to be a
  match too.
