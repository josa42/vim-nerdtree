" ============================================================================
" CLASS: UI
" ============================================================================

let s:UI = {}
let g:NERDTreeUI = s:UI

" FUNCTION: s:UI.new(nerdtree) {{{1
function! s:UI.New(nerdtree)
    let newObj = copy(self)
    let newObj.nerdtree = a:nerdtree
    let newObj._ignoreEnabled = 1
    let newObj._showHidden = 1

    return newObj
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" SECTION: Path, IDx and LineNum
"
" TODO: Move this else where!

" FUNCTION: s:UI.getPath(ln) {{{1
" Return the "Path" object for the node that is rendered on the given line
" number.  If the "up a dir" line is selected, return the "Path" object for
" the parent of the root.  Return the empty dictionary if the given line
" does not reference a tree node.
function! s:UI.getPath(ln)
    if a:ln <  1 | return {} | endif
    return self.nerdtree.root.registry.items[a:ln - 1].path
endfunction

" FUNCTION: s:UI.getLineNum(node) {{{1
" Return the line number where the given node is rendered.  Return -1 if the
" given node is not visible.
function! s:UI.getLineNum(node)
    if a:node.idx >= 0
        return a:node.idx + 1
    endif
    return -1
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" SECTION: Filter

" FUNCTION: s:UI.getShowHidden() {{{1
function! s:UI.getShowHidden()
    return self._showHidden
endfunction

" FUNCTION: s:UI.setShowHidden(val) {{{1
function! s:UI.setShowHidden(val)
    let self._showHidden = a:val
endfunction

" FUNCTION: s:UI.toggleShowHidden() {{{1
" toggles the display of hidden files
function! s:UI.toggleShowHidden()
    let self._showHidden = !self._showHidden
    call self.renderViewSavingPosition()
endfunction

" FUNCTION: s:UI.isIgnoreFilterEnabled() {{{1
function! s:UI.isIgnoreFilterEnabled()
    return self._ignoreEnabled == 1
endfunction

" FUNCTION: s:UI.toggleIgnoreFilter() {{{1
" toggles the use of the NERDTreeIgnore option
function! s:UI.toggleIgnoreFilter()
    let self._ignoreEnabled = !self._ignoreEnabled
    call self.renderViewSavingPosition()
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" SECTION: State

" FUNCTION: s:UI.restoreScreenState() {{{1
"
" Sets the screen state back to what it was when nerdtree#saveScreenState was last
" called.
"
" Assumes the cursor is in the NERDTree window
function! s:UI.restoreScreenState()
    if !has_key(self, '_screenState')
        return
    endif
    exec("silent vertical resize " . self._screenState['oldWindowSize'])

    let old_scrolloff=&scrolloff
    let &scrolloff=0
    call cursor(self._screenState['oldTopLine'], 0)
    normal! zt
    call setpos(".", self._screenState['oldPos'])
    let &scrolloff=old_scrolloff
endfunction

" FUNCTION: s:UI.saveScreenState() {{{1
" Saves the current cursor position in the current buffer and the window
" scroll position
function! s:UI.saveScreenState()
    let win = winnr()
    call g:NERDTree.CursorToTreeWin()
    let self._screenState = {}
    let self._screenState['oldPos'] = getpos(".")
    let self._screenState['oldTopLine'] = line("w0")
    let self._screenState['oldWindowSize']= winwidth("")
    call nerdtree#exec(win . "wincmd w")
endfunction

" FUNCTION: UI.renderViewSavingPosition {{{1
" Renders the tree and ensures the cursor stays on the current node or the
" current nodes parent if it is no longer available upon re-rendering
function! s:UI.renderViewSavingPosition()
    let currentNode = g:NERDTreeFileNode.GetSelected()

    " go up the tree till we find a node that will be visible or till we run
    " out of nodes
    while currentNode != {} && !currentNode.isVisible() && !currentNode.isRoot()
        let currentNode = currentNode.parent
    endwhile

    call self.render()

    if currentNode != {}
        call currentNode.putCursorHere(0, 0)
    endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" SECTION: Render


" FUNCTION: s:UI.render() {{{1
function! s:UI.render()
    setlocal noreadonly modifiable

    " remember the top line of the buffer and the current line so we can
    " restore the view exactly how it was
    let curLine = line(".")
    let curCol = col(".")
    let topLine = line("w0")

    " delete all lines in the buffer (being careful not to clobber a register)
    silent 1,$delete _

    " for i in range(1, winheight(0))
    "     call setline(i, repeat(' ', winwidth(0)))
    " endfor

    " for i in range(1, 1)
    "     call setline(i, "")
    " endfor

    call cursor(1, col("."))

    " draw the tree
    silent put =self.nerdtree.root.renderToString()

    " delete the blank line at the top of the buffer
    silent 1,1delete _

    " restore the view
    let old_scrolloff=&scrolloff
    let &scrolloff=0
    call cursor(topLine, 1)
    normal! zt
    call cursor(curLine, curCol)
    let &scrolloff = old_scrolloff

    setlocal readonly nomodifiable
endfunction

" vim: set sw=4 sts=4 et fdm=marker:
