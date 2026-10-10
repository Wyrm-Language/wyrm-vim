# wyrm-vim

Vim support for the [Wyrm](https://wyrm-lang.com) language (`*.wy`, `*.wyrm`).

| File | What it does |
| --- | --- |
| `ftdetect/wyrm.vim` | sets `filetype=wyrm` for `*.wy` and `*.wyrm` |
| `syntax/wyrm.vim` | syntax highlighting, ported from the wyrm-vscode TextMate grammar |
| `ftplugin/wyrm.vim` | `#` comments, 4-space indent, `gf` on `import a::b` (searches `$WYRM_PATH`) |
| `indent/wyrm.vim` | indents after a trailing `:` or an open bracket; aligns closers and `elif` / `else` / `catch` |

The language definition it follows is `doc/grammar.md` and `src/embed/wyrm/tokenizer.wy`
in the [wyrm](https://codeberg.org/wyrm-lang/wyrm) repository. The VS Code and Gram equivalents are [wyrm-vscode](https://github.com/Wyrm-Language/wyrm-vscode) and
[wyrm-gram](https://github.com/Wyrm-Language/wyrm-gram).

## Install

With Vim's own packages:

```sh
mkdir -p ~/.vim/pack/wyrm/start
ln -s /path/to/wyrm-vim ~/.vim/pack/wyrm/start/wyrm-vim
```

With a plugin manager, point it at this directory, for example
`Plug '/path/to/wyrm-vim'` with vim-plug. Your vimrc needs
`filetype plugin indent on` and `syntax on`.

## Options

| Variable | Default | Effect |
| --- | --- | --- |
| `g:wyrm_highlight_calls` | `0` | highlight the callee in `name(...)` as a function |
| `g:wyrm_recommended_style` | `1` | set `expandtab shiftwidth=4 softtabstop=4` |

## Language server

The plugin does not start `wyrm-lsp` (from [wypoc](https://github.com/Wyrm-Language/wypoc), `pip install -e ".[lsp]"`). Any Vim
LSP client can run it. For example, with [yegappan/lsp](https://github.com/yegappan/lsp):

```vim
call LspAddServer([#{name: 'wyrm-lsp', filetype: ['wyrm'], path: 'wyrm-lsp', args: []}])
```

## Development

```sh
vim -Nu NONE -i NONE -Es -S test/run.vim   # syntax and indent tests
```

`test/syntax/*.wy` use the assertion format of wyrm-vscode's `test/grammar/`, with Vim syntax
group names in place of TextMate scopes (`NONE` asserts no group). `test/indent/*.wy` must
come out unchanged from `gg=G`. Use `:echo synIDattr(synID(line('.'), col('.'), 1), 'name')`
to see the group under the cursor.
