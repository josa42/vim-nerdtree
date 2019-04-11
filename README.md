# The NERDTree

## Introduction

The NERDTree is a file system explorer for the Vim editor. Using this plugin,
users can visually browse complex directory hierarchies, quickly open files for
reading or editing.

This plugin can also be extended with custom mappings using a special API. The
details of this API and of other NERDTree features are described in the
included documentation.

![NERDTree Screenshot](https://github.com/josa42/vim-nerdtree/raw/master/screenshot.png)

## Features

- Git status build in
- Git ignore filter build in
- Optional mirror tree in all tabs

## Installation

```viml
Plug 'josa42/vim-nerdtree'
```

## FAQ

> Is there any support for `git` flags?

Yes.

---

> Can I have the nerdtree on every tab automatically?

Yes.

---
> How can I open a NERDTree automatically when vim starts up?

Stick this in your vimrc: `autocmd vimenter * NERDTree`

---
> How can I open a NERDTree automatically when vim starts up if no files were specified?

Stick this in your vimrc:

    autocmd StdinReadPre * let s:std_in=1
    autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

Note: Now start vim with plain `vim`, not `vim .`

---
> How can I open NERDTree automatically when vim starts up on opening a directory?

    autocmd StdinReadPre * let s:std_in=1
    autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif

This window is tab-specific, meaning it's used by all windows in the tab. This trick also prevents NERDTree from hiding when first selecting a file.

Note: Executing `vim ~/some-directory` will open NERDTree and a new edit window. `exe 'cd '.argv()[0]` sets the `pwd` of the new edit window to `~/some-directory`

---
> How can I map a specific key or shortcut to open NERDTree?

Stick this in your vimrc to open NERDTree with `Ctrl+n` (you can set whatever key you want):

    map <C-n> :NERDTreeToggle<CR>

---
> How can I close vim if the only window left open is a NERDTree?

Stick this in your vimrc:

    autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

---
> How can I change default arrows?

Use these variables in your vimrc. Note that below are default arrow symbols

    let g:NERDTreeDirArrowExpandable = '▸'
    let g:NERDTreeDirArrowCollapsible = '▾'

## Credit

- [`scrooloose/nerdtree`](https://github.com/scrooloose/nerdtree)
- [`Xuyuanp/nerdtree-git-plugin`](https://github.com/Xuyuanp/nerdtree-git-plugin)
- [`jistr/vim-nerdtree-tabs`](https://github.com/jistr/vim-nerdtree-tabs)

## LICENSE

[WTFPL](LICENSE)
