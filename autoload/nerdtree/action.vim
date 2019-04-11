function! nerdtree#action#defaultMappings()

  " nmapclear <buffer>
  nnoremap <buffer> v <nop>
  nnoremap <buffer> V <nop>
  nnoremap <buffer> a <nop>
  nnoremap <buffer> A <nop>
  nnoremap <buffer> c <nop>
  nnoremap <buffer> C <nop>
  nnoremap <buffer> P <nop>
  nnoremap <buffer> > <nop>
  nnoremap <buffer> < <nop>
  nnoremap <buffer> q <nop>

  " Close
  nnoremap <silent><buffer> <Esc> :call nerdtree#tabs#unfocus()<cr>
  nnoremap <silent><buffer> q     :call nerdtree#api#close()<cr>

  " Navigate
  nnoremap <silent><buffer> <cr>  :call nerdtree#action#open()<cr>
  nnoremap <silent><buffer> o     :call nerdtree#action#open()<cr>
  noremap  <buffer> <2-LeftMouse> :call nerdtree#action#open()<cr>
  nnoremap <silent><buffer> go    :call nerdtree#action#openFile({'stay': 1, 'where': 'p', 'keepopen': 1})<cr>

  nnoremap <silent><buffer> O     :call nerdtree#action#openDirectoryRecursively()<cr>
  nnoremap <silent><buffer> x     :call nerdtree#action#closeCurrentDir()<cr>
  nnoremap <silent><buffer> X     :call nerdtree#action#closeChildren()<cr>

  nnoremap <silent><buffer> t     :call nerdtree#action#openFile({'where': 't', 'stay': 0})<cr>
  nnoremap <silent><buffer> T     :call nerdtree#action#openFile({'where': 't', 'stay': 1})<cr>

  nnoremap <silent><buffer> i     :call nerdtree#action#openFile({'where': 'h'})<cr>
  nnoremap <silent><buffer> gi    :call nerdtree#action#openFile({'where': 'h', 'stay': 1, 'keepopen': 1})<cr>
  nnoremap <silent><buffer> s     :call nerdtree#action#openFile({'where': 'v'})<cr>
  nnoremap <silent><buffer> gs    :call nerdtree#action#openFile({'where': 'v', 'stay': 1, 'keepopen': 1})<cr>

  " state
  nnoremap <silent><buffer> r     :call nerdtree#api#refresh()<cr>

  " Navigation
  nnoremap <silent><buffer> P     :call nerdtree#action#jumpToParent()<cr>
  nnoremap <silent><buffer> K     :call nerdtree#action#jumpToFirstChild()<cr>
  nnoremap <silent><buffer> J     :call nerdtree#action#jumpToLastChild()<cr>
  nnoremap <silent><buffer> <C-k> :call nerdtree#action#jumpToPrevSibling()<cr>
  nnoremap <silent><buffer> <C-j> :call nerdtree#action#jumpToNextSibling()<cr>

  " Filter
  nnoremap <silent><buffer> I     :call nerdtree#action#toggleIgnoreFilter()<cr>
  nnoremap <silent><buffer> f     :call nerdtree#action#toggleShowHidden()<cr>
endfunction

function! nerdtree#action#open()
  if nerdtree#action#toggleDirectory() | return | endif
  call nerdtree#action#openFile({'reuse': 'all', 'where': 'p'})
endfunction

function! nerdtree#action#toggleDirectory()
  let node = nerdtree#api#selectedNode()
  if !empty(node) && node.path.isDirectory
    call node.activate()
    return 1
  endif
  return 0
endfunction

function! nerdtree#action#openDirectoryRecursively()
  let node = nerdtree#api#selectedNode()
  if !empty(node) && node.path.isDirectory
      call node.openRecursively()
      call b:NERDTree.render()
  endif
endfunction

function! nerdtree#action#openFile(...)
  let node = nerdtree#api#selectedNode()
  if !empty(node) && !node.path.isDirectory
    call node.activate(a:0 ? a:1 : {})
    return 1
  endif
  return 0
endfunction

function! nerdtree#action#jumpToParent()
  let node = nerdtree#api#selectedNode()
  if !empty(node)
    let node = node.path.isDirectory ? node.getCascadeRoot() : node

    if l:node.isRoot()
      return
    endif

    if empty(l:node.parent)
      call nerdtree#echo('could not jump to parent node')
      return
    endif

    call l:node.parent.putCursorHere(1, 0)
  endif
endfunction

function! nerdtree#action#jumpToFirstChild()
  let node = nerdtree#api#selectedNode()
  if !empty(node)
    call s:jumpToChild(node, 0)
  endif
endfunction

function! nerdtree#action#jumpToLastChild()
  let node = nerdtree#api#selectedNode()
  if !empty(node)
    call s:jumpToChild(node, 1)
  endif
endfunction


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

function! nerdtree#action#jumpToNextSibling()
 let node = nerdtree#api#selectedNode()
  if !empty(node)
    call s:jumpToSibling(node, 1)
  endif
endfunction

" FUNCTION: s:jumpToPrevSibling(node) {{{1
function! nerdtree#action#jumpToPrevSibling()
  let node = nerdtree#api#selectedNode()
  if !empty(node)
    call s:jumpToSibling(node, 0)
  endif
endfunction

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

function! nerdtree#action#toggleIgnoreFilter()
    call b:NERDTree.ui.toggleIgnoreFilter()
endfunction

" toggles the display of hidden files
function! nerdtree#action#toggleShowHidden()
    call b:NERDTree.ui.toggleShowHidden()
endfunction

" closes all childnodes of the current node
function! nerdtree#action#closeChildren()
  let node = nerdtree#api#selectedNode()
  if !empty(node) && node.path.isDirectory
    call node.closeChildren()
    call b:NERDTree.render()
    call node.putCursorHere(0, 0)
  endif
endfunction

" Close the parent directory of the current node.
function! nerdtree#action#closeCurrentDir()
  let node = nerdtree#api#selectedNode()
  if !empty(node)

    if node.isRoot()
        call nerdtree#echo('cannot close parent of tree root')
        return
    endif

    let l:parent = node.parent

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
  endif
endfunction

