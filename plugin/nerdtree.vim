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
if exists("loaded_nerd_tree")
    finish
endif
if v:version < 700
    echoerr "NERDTree: this plugin requires vim >= 7. DOWNLOAD IT! You'll thank me later!"
    finish
endif
let loaded_nerd_tree = 1

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
call s:initVariable("g:NERDTreeChDirMode", 0)
call s:initVariable("g:NERDTreeCreatePrefix", "silent")
if !exists("g:NERDTreeIgnore")
    let g:NERDTreeIgnore = ['\~$']
endif
call s:initVariable("g:NERDTreeHighlightCursorline", 1)
call s:initVariable("g:NERDTreeMouseMode", 1)
call s:initVariable("g:NERDTreeNotificationThreshold", 100)
call s:initVariable("g:NERDTreeQuitOnOpen", 0)
call s:initVariable("g:NERDTreeRespectWildIgnore", 0)
call s:initVariable("g:NERDTreeShowHidden", 0)

call s:initVariable("g:NERDTreeDirArrowExpandable", "▸")
call s:initVariable("g:NERDTreeDirArrowCollapsible", "▾")
call s:initVariable("g:NERDTreeCascadeOpenSingleChildDir", 1)
call s:initVariable("g:NERDTreeCascadeSingleChildDir", 1)

" Git options
call s:initVariable('g:NERDTreeUpdateOnWrite', 1)
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

if has("conceal")
    call s:initVariable("g:NERDTreeNodeDelimiter", "\x07")
elseif (g:NERDTreeDirArrowExpandable == "\u00a0" || g:NERDTreeDirArrowCollapsible == "\u00a0")
    call s:initVariable("g:NERDTreeNodeDelimiter", "\u00b7")
else
    call s:initVariable("g:NERDTreeNodeDelimiter", "\u00a0")
endif

if !exists('g:NERDTreeStatusline')

    "the exists() crap here is a hack to stop vim spazzing out when
    "loading a session that was created with an open nerd tree. It spazzes
    "because it doesnt store b:NERDTree(its a b: var, and its a hash)
    let g:NERDTreeStatusline = "%{exists('b:NERDTree')?b:NERDTree.root.path.str():''}"

endif
call s:initVariable("g:NERDTreeWinPos", "left")
call s:initVariable("g:NERDTreeWinSize", 31)

"init the shell commands that will be used to copy nodes, and remove dir trees

"SECTION: Init variable calls for key mappings {{{2
call s:initVariable("g:NERDTreeMapActivateNode", "o")
call s:initVariable("g:NERDTreeMapChangeRoot", "C")
call s:initVariable("g:NERDTreeMapChdir", "cd")
call s:initVariable("g:NERDTreeMapCloseChildren", "X")
call s:initVariable("g:NERDTreeMapCloseDir", "x")
call s:initVariable("g:NERDTreeMapJumpFirstChild", "K")
call s:initVariable("g:NERDTreeMapJumpLastChild", "J")
call s:initVariable("g:NERDTreeMapJumpNextSibling", "<C-j>")
call s:initVariable("g:NERDTreeMapJumpParent", "p")
call s:initVariable("g:NERDTreeMapJumpPrevSibling", "<C-k>")
call s:initVariable("g:NERDTreeMapJumpRoot", "P")
call s:initVariable("g:NERDTreeMapOpenExpl", "e")
call s:initVariable("g:NERDTreeMapOpenInTab", "t")
call s:initVariable("g:NERDTreeMapOpenInTabSilent", "T")
call s:initVariable("g:NERDTreeMapOpenRecursively", "O")
call s:initVariable("g:NERDTreeMapOpenSplit", "i")
call s:initVariable("g:NERDTreeMapOpenVSplit", "s")
call s:initVariable("g:NERDTreeMapPreview", "g" . NERDTreeMapActivateNode)
call s:initVariable("g:NERDTreeMapPreviewSplit", "g" . NERDTreeMapOpenSplit)
call s:initVariable("g:NERDTreeMapPreviewVSplit", "g" . NERDTreeMapOpenVSplit)
call s:initVariable("g:NERDTreeMapQuit", "q")
call s:initVariable("g:NERDTreeMapRefresh", "r")
call s:initVariable("g:NERDTreeMapRefreshRoot", "R")
call s:initVariable("g:NERDTreeMapToggleFiles", "F")
call s:initVariable("g:NERDTreeMapToggleFilters", "f")
call s:initVariable("g:NERDTreeMapToggleHidden", "I")
call s:initVariable("g:NERDTreeMapToggleZoom", "A")
call s:initVariable("g:NERDTreeMapUpdir", "u")
call s:initVariable("g:NERDTreeMapUpdirKeepOpen", "U")
call s:initVariable("g:NERDTreeMapCWD", "CD")

" === plugin configuration variables === {{{
"
" Open NERDTree on gvim/macvim startup. When set to `2`,
" open only if directory was given as startup argument.
call s:initVariable("g:nerdtree_tabs_open_on_gui_startup", 1)

" Open NERDTree on console vim startup (off by default). When set to `2`,
" open only if directory was given as startup argument.
call s:initVariable("g:nerdtree_tabs_open_on_console_startup", 0)

" do not open NERDTree if vim starts in diff mode
call s:initVariable('g:nerdtree_tabs_no_startup_for_diff', 1)

" On startup - focus NERDTree when opening a directory, focus the file if
" editing a specified file. When set to `2`, always focus file after startup.
call s:initVariable("g:nerdtree_tabs_smart_startup_focus", 1)

" Open NERDTree on new tab creation if NERDTree was globally opened
" by :NERDTreeTabsToggle
call s:initVariable("g:nerdtree_tabs_open_on_new_tab", 1)

" unfocus NERDTree when leaving a tab so that you have descriptive tab names
" and not names like 'NERD_tree_1'
call s:initVariable("g:nerdtree_tabs_meaningful_tab_names", 1)

" close current tab if there is only one window in it and it's NERDTree
call s:initVariable("g:nerdtree_tabs_autoclose", 1)

" synchronize view of all NERDTree windows (scroll and cursor position)
call s:initVariable("g:nerdtree_tabs_synchronize_view", 1)

" synchronize focus when switching tabs (focus NERDTree after tab switch
" if and only if it was focused before tab switch)
call s:initVariable("g:nerdtree_tabs_synchronize_focus", 1)

" when switching into a tab, make sure that focus will always be in file
" editing window, not in NERDTree window (off by default)
call s:initVariable("g:nerdtree_tabs_focus_on_files", 0)

" when starting up with a directory name as a parameter, cd into it
call s:initVariable("g:nerdtree_tabs_startup_cd", 1)

" automatically find and select currently opened file
call s:initVariable("g:nerdtree_tabs_autofind", 0)

" }}}



"SECTION: Load class files{{{2
call nerdtree#loadClassFiles()

" SECTION: Commands {{{1
"============================================================
call nerdtree#ui_glue#setupCommands()

" SECTION: Auto commands {{{1
"============================================================
augroup NERDTree
    "Save the cursor position whenever we close the nerd tree
    exec "autocmd BufLeave ". g:NERDTreeCreator.BufNamePrefix() ."* if g:NERDTree.IsOpen() | call b:NERDTree.ui.saveScreenState() | endif"

    "disallow insert mode in the NERDTree
    exec "autocmd BufEnter ". g:NERDTreeCreator.BufNamePrefix() ."* stopinsert"
augroup END

" SECTION: Init git status {{{1
"============================================================

if executable('git')
    call g:NERDTreePathNotifier.AddListener('init',         'nerdtree#git#statusRefreshListener')
    call g:NERDTreePathNotifier.AddListener('refresh',      'nerdtree#git#statusRefreshListener')
    call g:NERDTreePathNotifier.AddListener('refreshFlags', 'nerdtree#git#statusRefreshListener')

    augroup nerdtreegit
        autocmd!
        autocmd CursorHold   *        silent! call nerdtree#git#cursorHoldUpdate()
        autocmd BufWritePost *                call nerdtree#git#fileUpdate(expand('%:p'))
        autocmd FileType     nerdtree         call nerdtree#git#addHighlighting()
    augroup END
endif

" SECTION: Public API {{{1
"============================================================
function! NERDTreeAddKeyMap(options)
    call g:NERDTreeKeyMap.Create(a:options)
endfunction

function! NERDTreeRender()
    call nerdtree#renderView()
endfunction

function! NERDTreeFocus()
    if g:NERDTree.IsOpen()
        call g:NERDTree.CursorToTreeWin()
    else
        call g:NERDTreeCreator.ToggleTabTree("")
    endif
endfunction

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


" === plugin mappings === {{{
"
noremap <silent> <script> <Plug>NERDTreeTabsOpen     :call nerdtree#tabs#openAllTabs()
noremap <silent> <script> <Plug>NERDTreeTabsClose    :call nerdtree#tabs#closeAllTabs()
noremap <silent> <script> <Plug>NERDTreeTabsToggle   :call nerdtree#tabs#toggleAllTabs()
noremap <silent> <script> <Plug>NERDTreeTabsFind     :call nerdtree#tabs#findFile()
noremap <silent> <script> <Plug>NERDTreeMirrorOpen   :call nerdtree#tabs#mirrorOrCreate()
noremap <silent> <script> <Plug>NERDTreeMirrorToggle :call nerdtree#tabs#mirrorToggle()
noremap <silent> <script> <Plug>NERDTreeSteppedOpen  :call nerdtree#tabs#steppedOpen()
noremap <silent> <script> <Plug>NERDTreeSteppedClose :call nerdtree#tabs#steppedClose()
noremap <silent> <script> <Plug>NERDTreeFocusToggle  :call nerdtree#tabs#focusToggle()
"
" }}}
" === plugin commands === {{{
"
command! NERDTreeTabsOpen     call nerdtree#tabs#openAllTabs()
command! NERDTreeTabsClose    call nerdtree#tabs#closeAllTabs()
command! NERDTreeTabsToggle   call nerdtree#tabs#toggleAllTabs()
command! NERDTreeTabsFind     call nerdtree#tabs#findFile()
command! NERDTreeMirrorOpen   call nerdtree#tabs#mirrorOrCreate()
command! NERDTreeMirrorToggle call nerdtree#tabs#mirrorToggle()
command! NERDTreeSteppedOpen  call nerdtree#tabs#steppedOpen()
command! NERDTreeSteppedClose call nerdtree#tabs#steppedClose()
command! NERDTreeFocusToggle  call nerdtree#tabs#focusToggle()
"
" }}}

call nerdtree#tabs#load()

" vim: set sw=4 sts=4 et fdm=marker:
