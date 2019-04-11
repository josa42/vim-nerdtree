function! nerdtree#handler#bufferEnter()
  stopinsert
  call nerdtree#api#cwd()
  call nerdtree#api#refresh()
endfunction

function! nerdtree#handler#bufferLeave()
  if g:NERDTree.IsOpen() | call b:NERDTree.ui.saveScreenState() | endif
endfunction


function! nerdtree#handler#dirChanged()
  call nerdtree#api#cwd()
endfunction

