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

"for line continuation - i.e dont want C in &cpo

"Function: s:initVariable() function {{{2
"This function is used to initialise a given variable to a given value. The
"variable is only initialised if it does not exist prior
"
"Args:
"var: the name of the var to be initialised
"value: the value to initialise var to
"
"Returns:
"1 if the var is set, 0 otherwise
function! s:initVariable(var, value)
    if !exists(a:var)
        exec 'let ' . a:var . ' = ' . "'" . substitute(a:value, "'", "''", "g") . "'"
        return 1
    endif
    return 0
endfunction

"SECTION: Init variable calls and other random constants {{{2

call s:initVariable("g:NERDTreeQuitOnOpen",            0)
call s:initVariable("g:NERDTreeDirArrowExpandable",    "▸")
call s:initVariable("g:NERDTreeDirArrowCollapsible",   "▾")
call s:initVariable("g:NERDTreeFile",                  "∙")
call s:initVariable('g:NERDTreeUpdateOnWrite',         1)                      " Update git status TODO: Find better name!
call s:initVariable('g:NERDTreeUpdateOnCursorHold',    1)                      " Update git status TODO: Find better name!
call s:initVariable('g:NERDTreeShowIgnoredStatus',     1)                      " TODO Why should this be optional? Is it slow?
call s:initVariable("g:NERDTreeWinPos",                "left")
call s:initVariable("g:NERDTreeWinSize",               31)
call s:initVariable("g:NERDtreeTabsAutofind",          0)                      " automatically find and select currently opened file

" TODO Remove these:
call s:initVariable("g:NERDTreeRespectWildIgnore",     0)                      " Deprecated: use nerdtree#api#addPathFilter()
call s:initVariable("g:NERDTreeHighlightCursorline",   1)                      " Deprecated
call s:initVariable("g:NERDTreeNaturalSort",           0)                      " Deprecated
call s:initVariable("g:NERDTreeSortHiddenFirst",       1)                      " Deprecated
call s:initVariable("g:NERDtreeTabsFocusOnFiles",      0)                      " Deprecated

if !exists('g:NERDTreeIndicatorMap')
    let g:NERDTreeIndicatorMap = {
                \ 'Modified'  : '✹',
                \ 'Staged'    : '✚',
                \ 'Untracked' : '✭',
                \ 'Renamed'   : '➜',
                \ 'Unmerged'  : '═',
                \ 'Deleted'   : '✖',
                \ 'Dirty'     : '✗',
                \ 'Clean'     : '✔︎',
                \ 'Ignored'   : '☒',
                \ 'Unknown'   : '?'
                \ }
endif
                                                                               " when switching into a tab, make sure that focus will always be in file
                                                                               " editing window, not in NERDTree window (off by default)
if !exists("g:NERDTreeIgnore") | let g:NERDTreeIgnore = ['\~$'] | endif        " Deprecated: use nerdtree#api#addPathFilter()
call s:initVariable("g:NERDTreeGlyphReadOnly",         "RO")                   " Deprecated TODO: find better default glyph

if !exists("g:NERDTreeSortOrder")
    let g:NERDTreeSortOrder = ['\/$', '*', '\.swp$',  '\.bak$', '\~$']
endif                                                                          " Deprecated: TODO Add Sort API
let g:NERDTreeOldSortOrder = []


if !exists('g:NERDTreeStatusline')                                             " Deprecated TODO refactor statusline support!
    "the exists() crap here is a hack to stop vim spazzing out when
    "loading a session that was created with an open NERDTree. It spazzes
    "because it doesnt store b:NERDTree(its a b: var, and its a hash)
    let g:NERDTreeStatusline = "%{exists('b:NERDTree')?b:NERDTree.root.path.str():''}"

endif

"SECTION: Load class files{{{2
call nerdtree#loadClassFiles()

" SECTION: Commands {{{1
"============================================================
call nerdtree#ui_glue#setupCommands()

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
call nerdtree#git#load()
call nerdtree#tabs#load()
call nerdtree#gitignore#registerFilter()

augroup NERDTreeKeyMaps
    autocmd!
    autocmd FileType nerdtree call nerdtree#action#defaultMappings()
augroup END
" vim: set sw=4 sts=4 et fdm=marker:
