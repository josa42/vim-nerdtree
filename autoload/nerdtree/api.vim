function! nerdtree#api#selectedNode()
  return g:NERDTreeFileNode.GetSelected()
endfunction

function! nerdtree#api#refresh()
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

function! nerdtree#api#close()
    call nerdtree#tabs#closeAllTabs()

    " if b:NERDTree.isWinTree() && b:NERDTree.previousBuf() != -1
    "     exec "buffer " . b:NERDTree.previousBuf()
    " else
    "     if winnr("$") > 1
    "         call g:NERDTree.Close()
    "     else
    "         call nerdtree#echo("Cannot close last window")
    "     endif
    " endif
endfunction


function! nerdtree#api#openAllTabs()
  call nerdtree#tabs#openAllTabs()
endfunction


function! nerdtree#api#render()
    call nerdtree#renderView()
endfunction

function! nerdtree#api#focus()
    if g:NERDTree.IsOpen()
        call g:NERDTree.CursorToTreeWin()
    else
        call g:NERDTreeCreator.ToggleTabTree("")
    endif
endfunction

" TODO remove this from public API
" TODO call this if vim root directory changed
" Sync tree with cwd
function! nerdtree#api#cwd()

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

    call nerdtree#api#focus()

    if b:NERDTree.root.path.equals(l:cwdPath)
        return
    endif

    let l:newRoot = g:NERDTreeFileNode.New(l:cwdPath, b:NERDTree)
    call b:NERDTree.changeRoot(l:newRoot)
    normal! ^
endfunction

function! nerdtree#api#addPathFilter(callback)
    call g:NERDTree.AddPathFilter(a:callback)
endfunction

function! nerdtree#api#addListener(event, funcname)
  call g:NERDTreePathNotifier.AddListener(a:event, a:funcname)
endfunction

function! nerdtree#api#revealPath(pathStr)
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
        call nerdtree#api#focus()
        if !l:pathObj.isUnder(b:NERDTree.root.path)
            call nerdtree#echoWarning('path not in current root directory')
            return
        endif
    endif

    if l:pathObj.isHiddenUnder(b:NERDTree.root.path)
        call b:NERDTree.ui.setShowHidden(1)
    endif

    let l:node = b:NERDTree.root.reveal(l:pathObj)
    call b:NERDTree.render()
    call l:node.putCursorHere(1, 0)
endfunction


function! nerdtree#api#create(...)
  call g:NERDTreeCreator.CreateTabTree(a:0 ? a:1 : '')
endfunction

function! nerdtree#api#toggle(...)
   call g:NERDTreeCreator.ToggleTabTree(a:0 ? a:1 : '')
endfunction

function! nerdtree#api#close()
  call g:NERDTree.Close()
endfunction

function! nerdtree#api#ceateMirror()
  call g:NERDTreeCreator.CreateMirror()
endfunction


