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

" FUNCTION: s:UI.getPath(ln) {{{1
" Return the "Path" object for the node that is rendered on the given line
" number.  If the "up a dir" line is selected, return the "Path" object for
" the parent of the root.  Return the empty dictionary if the given line
" does not reference a tree node.
function! s:UI.getPath(ln)
    let line = getline(a:ln)

    let rootLine = self.getRootLineNum()

    if a:ln == rootLine
        return self.nerdtree.root.path
    endif

    if a:ln < rootLine
        return {}
    endif

    let indent = self._indentLevelFor(line)

    " remove the tree parts and the leading space
    let curFile = self._stripMarkup(line)

    let dir = ""
    let lnum = a:ln
    while lnum > 0
        let lnum = lnum - 1
        let curLine = getline(lnum)
        let curLineStripped = self._stripMarkup(curLine)

        " have we reached the top of the tree?
        if lnum == rootLine
            let dir = self.nerdtree.root.path.str({'format': 'UI'}) . dir
            break
        endif
        if curLineStripped =~# '/$'
            let lpindent = self._indentLevelFor(curLine)
            if lpindent < indent
                let indent = indent - 1

                let dir = substitute (curLineStripped,'^\\', "", "") . dir
                continue
            endif
        endif
    endwhile
    let curFile = self.nerdtree.root.path.drive . dir . curFile
    let toReturn = g:NERDTreePath.New(curFile)
    return toReturn
endfunction

" FUNCTION: s:UI.getLineNum(node) {{{1
" Return the line number where the given node is rendered.  Return -1 if the
" given node is not visible.
function! s:UI.getLineNum(node)

    if a:node.isRoot()
        return self.getRootLineNum()
    endif

    let l:pathComponents = [substitute(self.nerdtree.root.path.str({'format': 'UI'}), '/\s*$', '', '')]
    let l:currentPathComponent = 1

    let l:fullPath = a:node.path.str({'format': 'UI'})

    for l:lineNumber in range(self.getRootLineNum() + 1, line('$'))
        let l:currentLine = getline(l:lineNumber)
        let l:indentLevel = self._indentLevelFor(l:currentLine)

        if l:indentLevel != l:currentPathComponent
            continue
        endif

        let l:currentLine = self._stripMarkup(l:currentLine)
        let l:currentPath =  join(l:pathComponents, '/') . '/' . l:currentLine

        " Directories: If the current path "starts with" the full path, then
        " either the paths are equal or the line is a cascade containing the
        " full path.
        if l:fullPath[-1:] == '/' && stridx(l:currentPath, l:fullPath) == 0
            return l:lineNumber
        endif

        " Files: The paths must exactly match.
        if l:fullPath ==# l:currentPath
            return l:lineNumber
        endif

        " Otherwise: If the full path starts with the current path and the
        " current path is a directory, we add a new path component.
        if stridx(l:fullPath, l:currentPath) == 0 && l:currentPath[-1:] == '/'
            let l:currentLine = substitute(l:currentLine, '/\s*$', '', '')
            call add(l:pathComponents, l:currentLine)
            let l:currentPathComponent += 1
        endif
    endfor

    return -1
endfunction

" FUNCTION: s:UI.getRootLineNum(){{{1
" gets the line number of the root node
function! s:UI.getRootLineNum()
    let rootLine = 1
    while getline(rootLine) !~# '^\(/\|<\)'
        let rootLine = rootLine + 1
    endwhile
    return rootLine
endfunction

" FUNCTION: s:UI.getShowHidden() {{{1
function! s:UI.getShowHidden()
    return self._showHidden
endfunction

" FUNCTION: s:UI._indentLevelFor(line) {{{1
function! s:UI._indentLevelFor(line)
    " have to do this work around because match() returns bytes, not chars
    let numLeadBytes = match(a:line, '\M\[^ '.g:NERDTreeDirArrowExpandable.g:NERDTreeDirArrowCollapsible.']')
    " The next line is a backward-compatible workaround for strchars(a:line(0:numLeadBytes-1]). strchars() is in 7.3+
    let leadChars = len(split(a:line[0:numLeadBytes-1], '\zs'))

    return leadChars / s:UI.IndentWid()
endfunction

" FUNCTION: s:UI.IndentWid() {{{1
function! s:UI.IndentWid()
    return 2
endfunction

" FUNCTION: s:UI.isIgnoreFilterEnabled() {{{1
function! s:UI.isIgnoreFilterEnabled()
    return self._ignoreEnabled == 1
endfunction

" FUNCTION: s:UI.MarkupReg() {{{1
function! s:UI.MarkupReg()
    return '^ *['.g:NERDTreeDirArrowExpandable.g:NERDTreeDirArrowCollapsible.']\? '
endfunction

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

" FUNCTION: s:UI.setShowHidden(val) {{{1
function! s:UI.setShowHidden(val)
    let self._showHidden = a:val
endfunction

" FUNCTION: s:UI._stripMarkup(line){{{1
" find the filename in the given line, and return it.
"
" Args:
" line: the subject line
function! s:UI._stripMarkup(line)
    let l:line = substitute(a:line, '^.\{-}' . g:NERDTreeNodeDelimiter, '', '')
    return substitute(l:line, g:NERDTreeNodeDelimiter.'.*$', '', '')
endfunction

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

    " draw the header line
    let header = self.nerdtree.root.path.str({'format': 'UI', 'truncateTo': winwidth(0)})
    call setline(line(".")+1, header)
    call cursor(line(".")+1, col("."))

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

" FUNCTION: s:UI.toggleIgnoreFilter() {{{1
" toggles the use of the NERDTreeIgnore option
function! s:UI.toggleIgnoreFilter()
    let self._ignoreEnabled = !self._ignoreEnabled
    call self.renderViewSavingPosition()
endfunction


" FUNCTION: s:UI.toggleShowHidden() {{{1
" toggles the display of hidden files
function! s:UI.toggleShowHidden()
    let self._showHidden = !self._showHidden
    call self.renderViewSavingPosition()
endfunction

" vim: set sw=4 sts=4 et fdm=marker:
