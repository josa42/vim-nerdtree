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

    call NERDTreeFocus()

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
