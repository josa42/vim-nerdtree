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

