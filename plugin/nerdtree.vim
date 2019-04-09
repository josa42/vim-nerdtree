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
let s:old_cpo = &cpo
set cpo&vim

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
call s:initVariable("g:NERDTreeNaturalSort", 0)
call s:initVariable("g:NERDTreeSortHiddenFirst", 1)
if !exists("g:NERDTreeIgnore")
    let g:NERDTreeIgnore = ['\~$']
endif
call s:initVariable("g:NERDTreeHighlightCursorline", 1)
call s:initVariable("g:NERDTreeMouseMode", 1)
call s:initVariable("g:NERDTreeNotificationThreshold", 100)
call s:initVariable("g:NERDTreeQuitOnOpen", 0)
call s:initVariable("g:NERDTreeRespectWildIgnore", 0)
call s:initVariable("g:NERDTreeDirArrowExpandable", "▸")
call s:initVariable("g:NERDTreeDirArrowCollapsible", "▾")
call s:initVariable("g:NERDTreeCascadeOpenSingleChildDir", 1)
call s:initVariable("g:NERDTreeCascadeSingleChildDir", 1)
call s:initVariable('g:NERDTreeUpdateOnWrite', 1)                              " Update git status
call s:initVariable('g:NERDTreeUpdateOnCursorHold', 1)
call s:initVariable('g:NERDTreeShowIgnoredStatus', 0)

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

if !exists("g:NERDTreeSortOrder")
    let g:NERDTreeSortOrder = ['\/$', '*', '\.swp$',  '\.bak$', '\~$']
endif
let g:NERDTreeOldSortOrder = []

call s:initVariable("g:NERDTreeGlyphReadOnly", "RO")
call s:initVariable("g:NERDTreeNodeDelimiter", "\x07")

if !exists('g:NERDTreeStatusline')
    "the exists() crap here is a hack to stop vim spazzing out when
    "loading a session that was created with an open NERDTree. It spazzes
    "because it doesnt store b:NERDTree(its a b: var, and its a hash)
    let g:NERDTreeStatusline = "%{exists('b:NERDTree')?b:NERDTree.root.path.str():''}"

endif
call s:initVariable("g:NERDTreeWinPos", "left")
call s:initVariable("g:NERDTreeWinSize", 31)

"init the shell commands that will be used to copy nodes, and remove dir trees

"SECTION: Init variable calls for key mappings {{{2
"
" TODO remove as much of the configuration options as possible!

call s:initVariable("g:NERDTreeMapActivateNode",     "o")
call s:initVariable("g:NERDTreeMapCloseChildren",    "X")
call s:initVariable("g:NERDTreeMapCloseDir",         "x")
call s:initVariable("g:NERDTreeMapJumpFirstChild",   "K")
call s:initVariable("g:NERDTreeMapJumpLastChild",    "J")
call s:initVariable("g:NERDTreeMapJumpNextSibling",  "<C-j>")
call s:initVariable("g:NERDTreeMapJumpParent",       "p")
call s:initVariable("g:NERDTreeMapJumpPrevSibling",  "<C-k>")
call s:initVariable("g:NERDTreeMapJumpRoot",         "P")
call s:initVariable("g:NERDTreeMapOpenExpl",         "e")
call s:initVariable("g:NERDTreeMapOpenInTab",        "t")
call s:initVariable("g:NERDTreeMapOpenInTabSilent",  "T")
call s:initVariable("g:NERDTreeMapOpenRecursively",  "O")
call s:initVariable("g:NERDTreeMapOpenSplit",        "i")
call s:initVariable("g:NERDTreeMapOpenVSplit",       "s")
call s:initVariable("g:NERDTreeMapPreview",          "g" . NERDTreeMapActivateNode)
call s:initVariable("g:NERDTreeMapPreviewSplit",     "g" . NERDTreeMapOpenSplit)
call s:initVariable("g:NERDTreeMapPreviewVSplit",    "g" . NERDTreeMapOpenVSplit)
call s:initVariable("g:NERDTreeMapQuit",             "q")
call s:initVariable("g:NERDTreeMapRefresh",          "r")
call s:initVariable("g:NERDTreeMapRefreshRoot",      "R")
call s:initVariable("g:NERDTreeMapToggleFilters",    "f")
call s:initVariable("g:NERDTreeMapToggleHidden",     "I")
call s:initVariable("g:NERDtreeTabsFocusOnFiles",    0)                        " when switching into a tab, make sure that focus will always be in file
                                                                               " editing window, not in NERDTree window (off by default)
call s:initVariable("g:NERDtreeTabsAutofind",        0)                        " automatically find and select currently opened file


" }}}



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
augroup END


" SECTION: Public API {{{1
"============================================================
function! NERDTreeAddKeyMap(options)
    " TODO make NERDTreeKeyMap private
    call g:NERDTreeKeyMap.Create(a:options)
endfunction

" TODO Remove this?

function! NERDTreeRender()
    call nerdtree#renderView()
endfunction

function! NERDTreeFocus()
    " TODO make NERDTree private
    if g:NERDTree.IsOpen()
        call g:NERDTree.CursorToTreeWin()
    else
        call g:NERDTreeCreator.ToggleTabTree("")
    endif
endfunction

" TODO remove this from public API
" TODO call this if vim root directory changed
" Sync tree with cwd
function! NERDTreeCWD()

    if empty(getcwd())
        call nerdtree#echoWarning('current directory does not exist')
        return
    endif

    try
        let l:cwdPath = g:NERDTreePath.New(getcwd())
    catch /^NERDTree.InvalidArgumentsError/
        call nerdtree#echoWarning('current directory does not exist')
        return
    endtry

    call NERDTreeFocus()

    if b:NERDTree.root.path.equals(l:cwdPath)
        return
    endif

    let l:newRoot = g:NERDTreeFileNode.New(l:cwdPath, b:NERDTree)
    call b:NERDTree.changeRoot(l:newRoot)
    normal! ^
endfunction

function! NERDTreeAddPathFilter(callback)
    call g:NERDTree.AddPathFilter(a:callback)
endfunction

" SECTION: Post Source Actions {{{1
call nerdtree#postSourceActions()

"reset &cpo back to users setting
let &cpo = s:old_cpo


" SECTION: Load extensions {{{1
"============================================================
call nerdtree#git#load()
call nerdtree#tabs#load()

" vim: set sw=4 sts=4 et fdm=marker:
