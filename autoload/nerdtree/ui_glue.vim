if exists("g:loaded_nerdtree_ui_glue_autoload")
    finish
endif
let g:loaded_nerdtree_ui_glue_autoload = 1

" FUNCTION: nerdtree#ui_glue#createDefaultBindings() {{{1
function! nerdtree#ui_glue#createDefaultBindings()
    let s = '<SNR>' . s:SID() . '_'

    call NERDTreeAddKeyMap({ 'key': '<LeftRelease>', 'scope': "all", 'callback': s."handleLeftClick" })
    call NERDTreeAddKeyMap({ 'key': '<2-LeftMouse>', 'scope': "DirNode", 'callback': s."activateDirNode" })
    call NERDTreeAddKeyMap({ 'key': '<2-LeftMouse>', 'scope': "FileNode", 'callback': s."activateFileNode" })
    call NERDTreeAddKeyMap({ 'key': '<2-LeftMouse>', 'scope': "all", 'callback': s."activateAll" })

    call NERDTreeAddKeyMap({ 'key': g:NERDTreeMapActivateNode, 'scope': "DirNode", 'callback': s."activateDirNode" })
    call NERDTreeAddKeyMap({ 'key': g:NERDTreeMapActivateNode, 'scope': "FileNode", 'callback': s."activateFileNode" })
    call NERDTreeAddKeyMap({ 'key': g:NERDTreeMapActivateNode, 'scope': "all", 'callback': s."activateAll" })

    call NERDTreeAddKeyMap({ 'key': g:NERDTreeMapOpenSplit, 'scope': "Node", 'callback': s."openHSplit" })
    call NERDTreeAddKeyMap({ 'key': g:NERDTreeMapOpenVSplit, 'scope': "Node", 'callback': s."openVSplit" })

    call NERDTreeAddKeyMap({ 'key': g:NERDTreeMapPreview, 'scope': "Node", 'callback': s."previewNodeCurrent" })
    call NERDTreeAddKeyMap({ 'key': g:NERDTreeMapPreviewVSplit, 'scope': "Node", 'callback': s."previewNodeVSplit" })
    call NERDTreeAddKeyMap({ 'key': g:NERDTreeMapPreviewSplit, 'scope': "Node", 'callback': s."previewNodeHSplit" })

    call NERDTreeAddKeyMap({ 'key': g:NERDTreeMapOpenRecursively, 'scope': "DirNode", 'callback': s."openNodeRecursively" })

    call NERDTreeAddKeyMap({ 'key': g:NERDTreeMapUpdir, 'scope': 'all', 'callback': s . 'upDirCurrentRootClosed' })
    call NERDTreeAddKeyMap({ 'key': g:NERDTreeMapUpdirKeepOpen, 'scope': 'all', 'callback': s . 'upDirCurrentRootOpen' })
    call NERDTreeAddKeyMap({ 'key': g:NERDTreeMapChangeRoot, 'scope': 'Node', 'callback': s . 'chRoot' })

    call NERDTreeAddKeyMap({ 'key': g:NERDTreeMapChdir, 'scope': "Node", 'callback': s."chCwd" })

    call NERDTreeAddKeyMap({ 'key': g:NERDTreeMapQuit, 'scope': "all", 'callback': s."closeTreeWindow" })

    call NERDTreeAddKeyMap({ 'key': g:NERDTreeMapCWD, 'scope': "all", 'callback': "nerdtree#ui_glue#chRootCwd" })

    call NERDTreeAddKeyMap({ 'key': g:NERDTreeMapRefreshRoot, 'scope': "all", 'callback': s."refreshRoot" })
    call NERDTreeAddKeyMap({ 'key': g:NERDTreeMapRefresh, 'scope': "Node", 'callback': s."refreshCurrent" })

    call NERDTreeAddKeyMap({ 'key': g:NERDTreeMapToggleZoom, 'scope': "all", 'callback': s."toggleZoom" })
    call NERDTreeAddKeyMap({ 'key': g:NERDTreeMapToggleHidden, 'scope': "all", 'callback': s."toggleShowHidden" })
    call NERDTreeAddKeyMap({ 'key': g:NERDTreeMapToggleFilters, 'scope': "all", 'callback': s."toggleIgnoreFilter" })
    call NERDTreeAddKeyMap({ 'key': g:NERDTreeMapToggleFiles, 'scope': "all", 'callback': s."toggleShowFiles" })

    call NERDTreeAddKeyMap({ 'key': g:NERDTreeMapCloseDir, 'scope': "Node", 'callback': s."closeCurrentDir" })
    call NERDTreeAddKeyMap({ 'key': g:NERDTreeMapCloseChildren, 'scope': "DirNode", 'callback': s."closeChildren" })

    call NERDTreeAddKeyMap({ 'key': g:NERDTreeMapJumpParent, 'scope': "Node", 'callback': s."jumpToParent" })
    call NERDTreeAddKeyMap({ 'key': g:NERDTreeMapJumpFirstChild, 'scope': "Node", 'callback': s."jumpToFirstChild" })
    call NERDTreeAddKeyMap({ 'key': g:NERDTreeMapJumpLastChild, 'scope': "Node", 'callback': s."jumpToLastChild" })
    call NERDTreeAddKeyMap({ 'key': g:NERDTreeMapJumpRoot, 'scope': "all", 'callback': s."jumpToRoot" })
    call NERDTreeAddKeyMap({ 'key': g:NERDTreeMapJumpNextSibling, 'scope': "Node", 'callback': s."jumpToNextSibling" })
    call NERDTreeAddKeyMap({ 'key': g:NERDTreeMapJumpPrevSibling, 'scope': "Node", 'callback': s."jumpToPrevSibling" })

    call NERDTreeAddKeyMap({ 'key': g:NERDTreeMapOpenInTab, 'scope': 'Node', 'callback': s . 'openInNewTab' })
    call NERDTreeAddKeyMap({ 'key': g:NERDTreeMapOpenInTabSilent, 'scope': 'Node', 'callback': s . 'openInNewTabSilent' })

    call NERDTreeAddKeyMap({ 'key': g:NERDTreeMapOpenExpl, 'scope': "DirNode", 'callback': s."openExplorer" })
endfunction


"SECTION: Interface bindings {{{1
"============================================================

"FUNCTION: s:activateAll() {{{1
"handle the user activating the updir line
function! s:activateAll()
    if getline(".") ==# g:NERDTreeUI.UpDirLine()
        return nerdtree#ui_glue#upDir(0)
    endif
endfunction

" FUNCTION: s:activateDirNode(directoryNode) {{{1
function! s:activateDirNode(directoryNode)

    if a:directoryNode.isRoot() && a:directoryNode.isOpen
        call nerdtree#echo('cannot close tree root')
        return
    endif

    call a:directoryNode.activate()
endfunction

"FUNCTION: s:activateFileNode() {{{1
"handle the user activating a tree node
function! s:activateFileNode(node)
    call a:node.activate({'reuse': 'all', 'where': 'p'})
endfunction

" FUNCTION: s:chCwd(node) {{{1
function! s:chCwd(node)
    try
        call a:node.path.changeToDir()
    catch /^NERDTree.PathChangeError/
        call nerdtree#echoWarning("could not change cwd")
    endtry
endfunction

" FUNCTION: s:chRoot(node) {{{1
" changes the current root to the selected one
function! s:chRoot(node)
    call b:NERDTree.changeRoot(a:node)
endfunction

" FUNCTION: s:nerdtree#ui_glue#chRootCwd() {{{1
" Change the NERDTree root to match the current working directory.
function! nerdtree#ui_glue#chRootCwd()
    NERDTreeCWD
endfunction

" FUNCTION: s:closeChildren(node) {{{1
" closes all childnodes of the current node
function! s:closeChildren(node)
    call a:node.closeChildren()
    call b:NERDTree.render()
    call a:node.putCursorHere(0, 0)
endfunction

" FUNCTION: s:closeCurrentDir(node) {{{1
" Close the parent directory of the current node.
function! s:closeCurrentDir(node)

    if a:node.isRoot()
        call nerdtree#echo('cannot close parent of tree root')
        return
    endif

    let l:parent = a:node.parent

    while l:parent.isCascadable()
        let l:parent = l:parent.parent
    endwhile

    if l:parent.isRoot()
        call nerdtree#echo('cannot close tree root')
        return
    endif

    call l:parent.close()
    call b:NERDTree.render()
    call l:parent.putCursorHere(0, 0)
endfunction

" FUNCTION: s:closeTreeWindow() {{{1
" close the tree window
function! s:closeTreeWindow()
    if b:NERDTree.isWinTree() && b:NERDTree.previousBuf() != -1
        exec "buffer " . b:NERDTree.previousBuf()
    else
        if winnr("$") > 1
            call g:NERDTree.Close()
        else
            call nerdtree#echo("Cannot close last window")
        endif
    endif
endfunction

" FUNCTION: s:findAndRevealPath(pathStr) {{{1
function! s:findAndRevealPath(pathStr)
    let l:pathStr = !empty(a:pathStr) ? a:pathStr : expand('%:p')

    if empty(l:pathStr)
        call nerdtree#echoWarning('no file for the current buffer')
        return
    endif

    try
        let l:pathStr = g:NERDTreePath.Resolve(l:pathStr)
        let l:pathObj = g:NERDTreePath.New(l:pathStr)
    catch /^NERDTree.InvalidArgumentsError/
        call nerdtree#echoWarning('invalid path')
        return
    endtry

    if !g:NERDTree.ExistsForTab()
        try
            let l:cwd = g:NERDTreePath.New(getcwd())
        catch /^NERDTree.InvalidArgumentsError/
            call nerdtree#echo('current directory does not exist.')
            let l:cwd = l:pathObj.getParent()
        endtry

        if l:pathObj.isUnder(l:cwd)
            call g:NERDTreeCreator.CreateTabTree(l:cwd.str())
        else
            call g:NERDTreeCreator.CreateTabTree(l:pathObj.getParent().str())
        endif
    else
        NERDTreeFocus

        if !l:pathObj.isUnder(b:NERDTree.root.path)
            call s:chRoot(g:NERDTreeDirNode.New(l:pathObj.getParent(), b:NERDTree))
        endif
    endif

    if l:pathObj.isHiddenUnder(b:NERDTree.root.path)
        call b:NERDTree.ui.setShowHidden(1)
    endif

    let l:node = b:NERDTree.root.reveal(l:pathObj)
    call b:NERDTree.render()
    call l:node.putCursorHere(1, 0)
endfunction

"FUNCTION: s:handleLeftClick() {{{1
"Checks if the click should open the current node
function! s:handleLeftClick()
    let currentNode = g:NERDTreeFileNode.GetSelected()
    if currentNode != {}

        "the dir arrows are multibyte chars, and vim's string functions only
        "deal with single bytes - so split the line up with the hack below and
        "take the line substring manually
        let line = split(getline(line(".")), '\zs')
        let startToCur = ""
        for i in range(0,len(line)-1)
            let startToCur .= line[i]
        endfor

        if currentNode.path.isDirectory
            if startToCur =~# g:NERDTreeUI.MarkupReg() && startToCur =~# '[+~'.g:NERDTreeDirArrowExpandable.g:NERDTreeDirArrowCollapsible.'] \?$'
                call currentNode.activate()
                return
            endif
        endif

        if (g:NERDTreeMouseMode ==# 2 && currentNode.path.isDirectory) || g:NERDTreeMouseMode ==# 3
            let char = strpart(startToCur, strlen(startToCur)-1, 1)
            if char !~# g:NERDTreeUI.MarkupReg()
                if currentNode.path.isDirectory
                    call currentNode.activate()
                else
                    call currentNode.activate({'reuse': 'all', 'where': 'p'})
                endif
                return
            endif
        endif
    endif
endfunction

" FUNCTION: nerdtree#ui_glue#invokeKeyMap(key) {{{1
"this is needed since I cant figure out how to invoke dict functions from a
"key map
function! nerdtree#ui_glue#invokeKeyMap(key)
    call g:NERDTreeKeyMap.Invoke(a:key)
endfunction

" FUNCTION: s:jumpToFirstChild(node) {{{1
function! s:jumpToFirstChild(node)
    call s:jumpToChild(a:node, 0)
endfunction

" FUNCTION: s:jumpToLastChild(node) {{{1
function! s:jumpToLastChild(node)
    call s:jumpToChild(a:node, 1)
endfunction

" FUNCTION: s:jumpToChild(node, last) {{{2
" Jump to the first or last child node at the same file system level.
"
" Args:
" node: the node on which the cursor currently sits
" last: 1 (true) if jumping to last child, 0 (false) if jumping to first
function! s:jumpToChild(node, last)
    let l:node = a:node.path.isDirectory ? a:node.getCascadeRoot() : a:node

    if l:node.isRoot()
        return
    endif

    let l:parent = l:node.parent
    let l:children = l:parent.getVisibleChildren()

    let l:target = a:last ? l:children[len(l:children) - 1] : l:children[0]

    call l:target.putCursorHere(1, 0)
endfunction

" FUNCTION: s:jumpToParent(node) {{{1
" Move the cursor to the parent of the specified node.  For a cascade, move to
" the parent of the cascade's first node.  At the root node, do nothing.
function! s:jumpToParent(node)
    let l:node = a:node.path.isDirectory ? a:node.getCascadeRoot() : a:node

    if l:node.isRoot()
        return
    endif

    if empty(l:node.parent)
        call nerdtree#echo('could not jump to parent node')
        return
    endif

    call l:node.parent.putCursorHere(1, 0)
endfunction

" FUNCTION: s:jumpToRoot() {{{1
" moves the cursor to the root node
function! s:jumpToRoot()
    call b:NERDTree.root.putCursorHere(1, 0)
endfunction

" FUNCTION: s:jumpToNextSibling(node) {{{1
function! s:jumpToNextSibling(node)
    call s:jumpToSibling(a:node, 1)
endfunction

" FUNCTION: s:jumpToPrevSibling(node) {{{1
function! s:jumpToPrevSibling(node)
    call s:jumpToSibling(a:node, 0)
endfunction

" FUNCTION: s:jumpToSibling(node, forward) {{{2
" Move the cursor to the next or previous node at the same file system level.
"
" Args:
" node: the node on which the cursor currently sits
" forward: 0 to jump to previous sibling, 1 to jump to next sibling
function! s:jumpToSibling(node, forward)
    let l:node = a:node.path.isDirectory ? a:node.getCascadeRoot() : a:node
    let l:sibling = l:node.findSibling(a:forward)

    if empty(l:sibling)
        return
    endif

    call l:sibling.putCursorHere(1, 0)
endfunction

" FUNCTION: s:openHSplit(target) {{{1
function! s:openHSplit(target)
    call a:target.activate({'where': 'h'})
endfunction

" FUNCTION: s:openVSplit(target) {{{1
function! s:openVSplit(target)
    call a:target.activate({'where': 'v'})
endfunction

" FUNCTION: s:openExplorer(node) {{{1
function! s:openExplorer(node)
    call a:node.openExplorer()
endfunction

" FUNCTION: s:openInNewTab(target) {{{1
function! s:openInNewTab(target)
    let l:opener = g:NERDTreeOpener.New(a:target.path, {'where': 't'})
    call l:opener.open(a:target)
endfunction

" FUNCTION: s:openInNewTabSilent(target) {{{1
function! s:openInNewTabSilent(target)
    let l:opener = g:NERDTreeOpener.New(a:target.path, {'where': 't', 'stay': 1})
    call l:opener.open(a:target)
endfunction

" FUNCTION: s:openNodeRecursively(node) {{{1
function! s:openNodeRecursively(node)
    call nerdtree#echo("Recursively opening node. Please wait...")
    call a:node.openRecursively()
    call b:NERDTree.render()
    redraw!
endfunction

"FUNCTION: s:previewNodeCurrent(node) {{{1
function! s:previewNodeCurrent(node)
    call a:node.open({'stay': 1, 'where': 'p', 'keepopen': 1})
endfunction

"FUNCTION: s:previewNodeHSplit(node) {{{1
function! s:previewNodeHSplit(node)
    call a:node.open({'stay': 1, 'where': 'h', 'keepopen': 1})
endfunction

"FUNCTION: s:previewNodeVSplit(node) {{{1
function! s:previewNodeVSplit(node)
    call a:node.open({'stay': 1, 'where': 'v', 'keepopen': 1})
endfunction

" FUNCTION: s:refreshRoot() {{{1
" Reloads the current root. All nodes below this will be lost and the root dir
" will be reloaded.
function! s:refreshRoot()
    if !g:NERDTree.IsOpen()
        return
    endif
    call nerdtree#echo("Refreshing the root node. This could take a while...")

    let l:curWin = winnr()
    call nerdtree#exec(g:NERDTree.GetWinNum() . "wincmd w")
    call b:NERDTree.root.refresh()
    call b:NERDTree.render()
    redraw!
    call nerdtree#exec(l:curWin . "wincmd w")
endfunction

" FUNCTION: s:refreshCurrent(node) {{{1
" refreshes the root for the current node
function! s:refreshCurrent(node)
    let node = a:node
    if !node.path.isDirectory
        let node = node.parent
    endif

    call nerdtree#echo("Refreshing node. This could take a while...")
    call node.refresh()
    call b:NERDTree.render()
    redraw!
endfunction

" FUNCTION: nerdtree#ui_glue#setupCommands() {{{1
function! nerdtree#ui_glue#setupCommands()
    command! -n=? -complete=dir -bar NERDTree :call g:NERDTreeCreator.CreateTabTree('<args>')
    command! -n=? -complete=dir -bar NERDTreeToggle :call g:NERDTreeCreator.ToggleTabTree('<args>')
    command! -n=0 -bar NERDTreeClose :call g:NERDTree.Close()
    command! -n=0 -bar NERDTreeMirror call g:NERDTreeCreator.CreateMirror()
    command! -n=? -complete=file -bar NERDTreeFind call s:findAndRevealPath('<args>')
    command! -n=0 -bar NERDTreeRefreshRoot call s:refreshRoot()
    command! -n=0 -bar NERDTreeFocus call NERDTreeFocus()
    command! -n=0 -bar NERDTreeCWD call NERDTreeCWD()
endfunction

" Function: s:SID()   {{{1
function s:SID()
    if !exists("s:sid")
        let s:sid = matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
    endif
    return s:sid
endfun

" FUNCTION: s:toggleIgnoreFilter() {{{1
function! s:toggleIgnoreFilter()
    call b:NERDTree.ui.toggleIgnoreFilter()
endfunction

" FUNCTION: s:toggleShowFiles() {{{1
function! s:toggleShowFiles()
    call b:NERDTree.ui.toggleShowFiles()
endfunction

" FUNCTION: s:toggleShowHidden() {{{1
" toggles the display of hidden files
function! s:toggleShowHidden()
    call b:NERDTree.ui.toggleShowHidden()
endfunction

" FUNCTION: s:toggleZoom() {{{1
function! s:toggleZoom()
    call b:NERDTree.ui.toggleZoom()
endfunction

" FUNCTION: nerdtree#ui_glue#upDir(preserveState) {{{1
" Move the NERDTree up one level.
"
" Args:
" preserveState: if 1, the current root is left open when the new tree is
" rendered; if 0, the current root node is closed
function! nerdtree#ui_glue#upDir(preserveState)

    try
        call b:NERDTree.root.cacheParent()
    catch /^NERDTree.CannotCacheParentError/
        call nerdtree#echo('already at root directory')
        return
    endtry

    let l:oldRoot = b:NERDTree.root
    let l:newRoot = b:NERDTree.root.parent

    call l:newRoot.open()
    call l:newRoot.transplantChild(l:oldRoot)

    if !a:preserveState
        call l:oldRoot.close()
    endif

    call b:NERDTree.changeRoot(l:newRoot)
    call l:oldRoot.putCursorHere(0, 0)
endfunction

" FUNCTION: s:upDirCurrentRootOpen() {{{1
function! s:upDirCurrentRootOpen()
    call nerdtree#ui_glue#upDir(1)
endfunction

" FUNCTION: s:upDirCurrentRootClosed() {{{1
function! s:upDirCurrentRootClosed()
    call nerdtree#ui_glue#upDir(0)
endfunction

" vim: set sw=4 sts=4 et fdm=marker:
