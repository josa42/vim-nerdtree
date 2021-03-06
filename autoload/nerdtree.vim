if exists("g:loaded_nerdtree_autoload")
    finish
endif
let g:loaded_nerdtree_autoload = 1

function! nerdtree#version()
    return '5.0.0'
endfunction

" SECTION: General Functions {{{1
"============================================================
"
function! nerdtree#noop()
endfunction

"FUNCTION: nerdtree#checkForBrowse(dir) {{{2
"inits a window tree in the current buffer if appropriate
function! nerdtree#checkForBrowse(dir)
    if !isdirectory(a:dir)
        return
    endif

    if s:reuseWin(a:dir)
        return
    endif

    call g:NERDTreeCreator.CreateWindowTree(a:dir)
endfunction

"FUNCTION: s:reuseWin(dir) {{{2
"finds a NERDTree buffer with root of dir, and opens it.
function! s:reuseWin(dir) abort
    let path = g:NERDTreePath.New(fnamemodify(a:dir, ":p"))

    for i in range(1, bufnr("$"))
        unlet! nt
        let nt = getbufvar(i, "NERDTree")
        if empty(nt)
            continue
        endif

        if nt.isWinTree() && nt.root.path.equals(path)
            call nt.setPreviousBuf(bufnr("#"))
            exec "buffer " . i
            return 1
        endif
    endfor

    return 0
endfunction

"FUNCTION: nerdtree#compareNodes(dir) {{{2
function! nerdtree#compareNodes(n1, n2)
    return a:n1.path.compareTo(a:n2.path)
endfunction

"FUNCTION: nerdtree#compareNodesBySortKey(n1, n2) {{{2
function! nerdtree#compareNodesBySortKey(n1, n2)
    let sortKey1 = a:n1.path.getSortKey()
    let sortKey2 = a:n2.path.getSortKey()
    let i = 0
    while i < min([len(sortKey1), len(sortKey2)])
        " Compare chunks upto common length.
        " If chunks have different type, the one which has
        " integer type is the lesser.
        if type(sortKey1[i]) == type(sortKey2[i])
            if sortKey1[i] <# sortKey2[i]
                return - 1
            elseif sortKey1[i] ># sortKey2[i]
                return 1
            endif
        elseif type(sortKey1[i]) == v:t_number
            return -1
        elseif type(sortKey2[i]) == v:t_number
            return 1
        endif
        let i = i + 1
    endwhile

    " Keys are identical upto common length.
    " The key which has smaller chunks is the lesser one.
    if len(sortKey1) < len(sortKey2)
        return -1
    elseif len(sortKey1) > len(sortKey2)
        return 1
    else
        return 0
    endif
endfunction

" FUNCTION: nerdtree#exec(cmd) {{{2
" Same as :exec cmd but with eventignore set for the duration
" to disable the autocommands used by NERDTree (BufEnter,
" BufLeave and VimEnter)
function! nerdtree#exec(cmd)
    let old_ei = &ei
    set ei=BufEnter,BufLeave,VimEnter
    exec a:cmd
    let &ei = old_ei
endfunction

" FUNCTION: nerdtree#has_opt(options, name) {{{2
function! nerdtree#has_opt(options, name)
    return has_key(a:options, a:name) && a:options[a:name] == 1
endfunction

" FUNCTION: nerdtree#loadClassFiles() {{{2
function! nerdtree#loadClassFiles()
    runtime lib/nerdtree/path.vim
    runtime lib/nerdtree/tree_file_node.vim
    runtime lib/nerdtree/tree_dir_node.vim
    runtime lib/nerdtree/opener.vim
    runtime lib/nerdtree/creator.vim
    runtime lib/nerdtree/flag_set.vim
    runtime lib/nerdtree/nerdtree.vim
    runtime lib/nerdtree/ui.vim
    runtime lib/nerdtree/event.vim
    runtime lib/nerdtree/notifier.vim
endfunction

" SECTION: View Functions {{{1
"============================================================

"FUNCTION: nerdtree#echo  {{{2
"A wrapper for :echo. Appends 'NERDTree:' on the front of all messages
"
"Args:
"msg: the message to echo
function! nerdtree#echo(msg)
    redraw
    echomsg "NERDTree: " . a:msg
endfunction

"FUNCTION: nerdtree#echoError {{{2
"Wrapper for nerdtree#echo, sets the message type to errormsg for this message
"Args:
"msg: the message to echo
function! nerdtree#echoError(msg)
    echohl errormsg
    call nerdtree#echo(a:msg)
    echohl normal
endfunction

"FUNCTION: nerdtree#echoWarning {{{2
"Wrapper for nerdtree#echo, sets the message type to warningmsg for this message
"Args:
"msg: the message to echo
function! nerdtree#echoWarning(msg)
    echohl warningmsg
    call nerdtree#echo(a:msg)
    echohl normal
endfunction

"FUNCTION: nerdtree#renderView {{{2
function! nerdtree#renderView()
    call b:NERDTree.render()
endfunction


function! nerdtree#defaultSetting(var, value)
    if !exists(a:var)
        exec 'let ' . a:var . ' = a:value'
    endif
endfunction


" vim: set sw=4 sts=4 et fdm=marker:

