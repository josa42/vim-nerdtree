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

" TODO Remove these:
call nerdtree#defaultSetting("g:NERDTreeRespectWildIgnore",     0)             " Deprecated: use nerdtree#api#addPathFilter()
call nerdtree#defaultSetting("g:NERDTreeHighlightCursorline",   1)             " Deprecated
call nerdtree#defaultSetting("g:NERDTreeNaturalSort",           0)             " Deprecated
call nerdtree#defaultSetting("g:NERDTreeSortHiddenFirst",       1)             " Deprecated
call nerdtree#defaultSetting("g:NERDtreeTabsFocusOnFiles",      0)             " Deprecated
                                                                               " when switching into a tab, make sure that focus will always be in file
                                                                               " editing window, not in NERDTree window (off by default)

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
call nerdtree#defaultSetting('g:NERDTreeIgnore',                ['\~$'])       " Deprecated: use nerdtree#api#addPathFilter()
call nerdtree#defaultSetting("g:NERDTreeGlyphReadOnly",         "RO")          " Deprecated: TODO: find better default glyph

call nerdtree#defaultSetting('g:NERDTreeSortOrder', [
                            \   '\/$', '*', '\.swp$',  '\.bak$', '\~$'
                            \ ])
                                                                               " Deprecated: TODO Add Sort API
let g:NERDTreeOldSortOrder = []

"the exists() crap here is a hack to stop vim spazzing out when
"loading a session that was created with an open NERDTree. It spazzes
"because it doesnt store b:NERDTree(its a b: var, and its a hash)
call nerdtree#defaultSetting('g:NERDTreeStatusline', "%{exists('b:NERDTree')?b:NERDTree.root.path.str():''}")
                                                                               " Deprecated TODO refactor statusline support!


"SECTION: Load class files{{{2

call nerdtree#loadClassFiles()

" SECTION: Auto commands {{{1
"============================================================

augroup NERDTree
    autocmd!
    "Save the cursor position whenever we close the NERDTree
    exec "autocmd BufLeave ". g:NERDTreeCreator.BufNamePrefix() ."* if g:NERDTree.IsOpen() | call b:NERDTree.ui.saveScreenState() | endif"

    "disallow insert mode in the NERDTree
    exec "autocmd BufEnter ". g:NERDTreeCreator.BufNamePrefix() ."* stopinsert"

    " Hijack Netrw
    autocmd VimEnter * silent! autocmd! FileExplorer
    autocmd BufEnter,VimEnter * call nerdtree#checkForBrowse(expand("<amatch>"))
augroup END

"reset &cpo back to users setting
" let &cpo = s:old_cpo


" SECTION: Load extensions {{{1
"============================================================

call nerdtree#commands#setup()
call nerdtree#git#load()
call nerdtree#tabs#load()
call nerdtree#gitignore#registerFilter()

augroup NERDTreeKeyMaps
    autocmd!
    autocmd FileType nerdtree call nerdtree#action#defaultMappings()
augroup END
" vim: set sw=4 sts=4 et fdm=marker:
