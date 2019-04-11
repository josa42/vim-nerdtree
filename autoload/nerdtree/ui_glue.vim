if exists("g:loaded_nerdtree_ui_glue_autoload")
    finish
endif
let g:loaded_nerdtree_ui_glue_autoload = 1


"SECTION: Interface bindings {{{1
"============================================================


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


" Function: s:SID()   {{{1
function s:SID()
    if !exists("s:sid")
        let s:sid = matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
    endif
    return s:sid
endfun

" FUNCTION: nerdtree#ui_glue#setupCommands() {{{1
function! nerdtree#ui_glue#setupCommands()
    command! -n=? -complete=dir -bar  NERDTree           :call g:NERDTreeCreator.CreateTabTree('<args>')
    command! -n=? -complete=dir -bar  NERDTreeToggle     :call g:NERDTreeCreator.ToggleTabTree('<args>')
    command! -n=0 -bar                NERDTreeClose      :call g:NERDTree.Close()
    command! -n=0 -bar                NERDTreeMirror      call g:NERDTreeCreator.CreateMirror()
    command! -n=? -complete=file -bar NERDTreeFind        call s:findAndRevealPath('<args>')
    command! -n=0 -bar                NERDTreeRefreshRoot call nerdtree#api#refresh()
    command! -n=0 -bar                NERDTreeFocus       call NERDTreeFocus()
    command! -n=0 -bar                NERDTreeCWD         call NERDTreeCWD()
endfunction
