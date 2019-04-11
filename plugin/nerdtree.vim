" ============================================================================
" File:        nerdtree.vim
" Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
" License:     This program is free software. It comes without any warranty,
"              to the extent permitted by applicable law. You can redistribute
"              it and/or modify it under the terms of the Do What The Fuck You
"              Want To Public License, Version 2, as published by Sam Hocevar.
"              See http://sam.zoy.org/wtfpl/COPYING for more details.
"
" ============================================================================
"
" SECTION: Script init stuff {{{1
"============================================================
if exists("loaded_nerdtree")
    finish
endif
if v:version < 800
    echoerr "NERDTree: this plugin requires vim >= 8. DOWNLOAD IT! You'll thank me later!"
    finish
endif
let loaded_nerdtree = 1

call nerdtree#defaultSetting("g:NERDTreeQuitOnOpen",            0)
call nerdtree#defaultSetting("g:NERDTreeDirArrowExpandable",    "▸")
call nerdtree#defaultSetting("g:NERDTreeDirArrowCollapsible",   "▾")
call nerdtree#defaultSetting("g:NERDTreeFile",                  "∙")
call nerdtree#defaultSetting('g:NERDTreeUpdateOnWrite',         1)             " Update git status TODO: Find better name!
call nerdtree#defaultSetting('g:NERDTreeUpdateOnCursorHold',    1)             " Update git status TODO: Find better name!
call nerdtree#defaultSetting('g:NERDTreeShowIgnoredStatus',     1)             " TODO Why should this be optional? Is it slow?
call nerdtree#defaultSetting("g:NERDTreeWinPos",                "left")
call nerdtree#defaultSetting("g:NERDTreeWinSize",               31)
call nerdtree#defaultSetting("g:NERDtreeTabsAutofind",          0)             " automatically find and select currently opened file
call nerdtree#defaultSetting('g:NERDTreeIndicatorMap', {
                            \   'Modified'  : '✹',
                            \   'Staged'    : '✚',
                            \   'Untracked' : '✭',
                            \   'Renamed'   : '➜',
                            \   'Unmerged'  : '═',
                            \   'Deleted'   : '✖',
                            \   'Dirty'     : '✗',
                            \   'Clean'     : '✔︎',
                            \   'Ignored'   : '☒',
                            \   'Unknown'   : '?'
                            \ })

" TODO Remove these:
call nerdtree#defaultSetting("g:NERDTreeRespectWildIgnore",     0)             " Deprecated: use nerdtree#api#addPathFilter()
call nerdtree#defaultSetting("g:NERDTreeHighlightCursorline",   1)             " Deprecated
call nerdtree#defaultSetting("g:NERDTreeNaturalSort",           0)             " Deprecated
call nerdtree#defaultSetting("g:NERDTreeSortHiddenFirst",       1)             " Deprecated
call nerdtree#defaultSetting('g:NERDTreeIgnore',            ['\~$', '\.swp$']) " Deprecated: use nerdtree#api#addPathFilter()
call nerdtree#defaultSetting("g:NERDTreeGlyphReadOnly",         "RO")          " Deprecated: TODO: find better default glyph
call nerdtree#defaultSetting('g:NERDTreeSortOrder', ['\/$', '*'])              " Deprecated: TODO Add Sort API
let g:NERDTreeOldSortOrder = []

" SECTION: Load class files{{{2

call nerdtree#loadClassFiles()

" SECTION: Auto commands {{{1
"============================================================

augroup NERDTree
    autocmd!
    autocmd BufEnter   * if &filetype == 'nerdtree' | call nerdtree#handler#bufferLeave() | endif
    autocmd BufEnter   * if &filetype == 'nerdtree' | call nerdtree#handler#bufferEnter() | endif
    autocmd DirChanged * if &filetype == 'nerdtree' | call nerdtree#handler#dirChanged()  | endif

    " Set key mappings
    autocmd FileType nerdtree call nerdtree#action#defaultMappings()

    " Hijack Netrw
    autocmd VimEnter * silent! autocmd! FileExplorer
    autocmd BufEnter,VimEnter * call nerdtree#checkForBrowse(expand("<amatch>"))
augroup END


" SECTION: Load extensions {{{1
"============================================================

call nerdtree#commands#setup()
call nerdtree#git#load()
call nerdtree#tabs#load()
call nerdtree#gitignore#registerFilter()

" vim: set sw=4 sts=4 et fdm=marker:
