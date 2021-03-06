" ============================================================================
" CLASS: TreeFileNode
"
" This class is the parent of the "TreeDirNode" class and is the "Component"
" part of the composite design pattern between the NERDTree node classes.
" ============================================================================


let s:TreeFileNode = {}
let g:NERDTreeFileNode = s:TreeFileNode

" FUNCTION: TreeFileNode.activate(...) {{{1
function! s:TreeFileNode.activate(...)
    call self.open(a:0 ? a:1 : {})
endfunction

" FUNCTION: TreeFileNode.cacheParent() {{{1
" initializes self.parent if it isnt already
function! s:TreeFileNode.cacheParent()
    if empty(self.parent)
        let parentPath = self.path.getParent()
        if parentPath.equals(self.path)
            throw "NERDTree.CannotCacheParentError: already at root"
        endif
        let self.parent = s:TreeFileNode.New(parentPath, self.getNerdtree())
    endif
endfunction

" FUNCTION: TreeFileNode.copy(dest) {{{1
function! s:TreeFileNode.copy(dest)
    call self.path.copy(a:dest)
    let newPath = g:NERDTreePath.New(a:dest)
    let parent = self.getNerdtree().root.findNode(newPath.getParent())
    if !empty(parent)
        call parent.refresh()
        return parent.findNode(newPath)
    else
        return {}
    endif
endfunction

" FUNCTION: TreeFileNode.displayString() {{{1
"
" Returns a string that specifies how the node should be represented as a
" string
"
" Return:
" a string that can be used in the view to represent this node
function! s:TreeFileNode.displayString(width)

    let l:flags = self.path.flagSet.renderToString()
    let l:flags = l:flags != '' ? ' ' .  l:flags : ''

    let l:symbol = g:NERDTreeFile
    let l:symbol .= ' '

    let l:lw = a:width - 3 - nerdtree#string#len(l:flags)

    let l:result = nerdtree#string#trunc(self.path.displayString(), l:lw)
    return ' ' . l:symbol . l:result . l:flags
endfunction

" FUNCTION: TreeFileNode.equals(treenode) {{{1
"
" Compares this treenode to the input treenode and returns 1 if they are the
" same node.
"
" Use this method instead of ==  because sometimes when the treenodes contain
" many children, vim seg faults when doing ==
"
" Args:
" treenode: the other treenode to compare to
function! s:TreeFileNode.equals(treenode)
    return self.path.str() ==# a:treenode.path.str()
endfunction

" FUNCTION: TreeFileNode.findNode(path) {{{1
" Returns self if this node.path.Equals the given path.
" Returns {} if not equal.
"
" Args:
" path: the path object to compare against
function! s:TreeFileNode.findNode(path)
    if a:path.equals(self.path)
        return self
    endif
    return {}
endfunction

" FUNCTION: TreeFileNode.findSibling(direction) {{{1
" Find the next or previous sibling of this node.
"
" Args:
" direction: 0 for previous, 1 for next
"
" Return:
" The next/previous TreeFileNode object or an empty dictionary if not found.
function! s:TreeFileNode.findSibling(direction)

    " There can be no siblings if there is no parent.
    if empty(self.parent)
        return {}
    endif

    let l:nodeIndex = self.parent.getChildIndex(self.path)

    if l:nodeIndex == -1
        return {}
    endif

    " Get the next index to begin the search.
    let l:nodeIndex += a:direction ? 1 : -1

    while 0 <= l:nodeIndex && l:nodeIndex < self.parent.getChildCount()

        " Return the next node if it is not ignored.
        if !self.parent.children[l:nodeIndex].path.ignore(self.getNerdtree())
            return self.parent.children[l:nodeIndex]
        endif

        let l:nodeIndex += a:direction ? 1 : -1
    endwhile

    return {}
endfunction

" FUNCTION: TreeFileNode.getNerdtree(){{{1
function! s:TreeFileNode.getNerdtree()
    return self._nerdtree
endfunction

" FUNCTION: TreeFileNode.GetRootForTab(){{{1
" get the root node for this tab
function! s:TreeFileNode.GetRootForTab()
    if g:NERDTree.ExistsForTab()
        return getbufvar(t:NERDTreeBufName, 'NERDTree').root
    end
    return {}
endfunction

" FUNCTION: TreeFileNode.GetSelected() {{{1
" If the cursor is currently positioned on a tree node, return the node.
" Otherwise, return the empty dictionary.
function! s:TreeFileNode.GetSelected()

    try
        let l:path = b:NERDTree.ui.getPath(line('.'))

        if empty(l:path)
            return {}
        endif

        return b:NERDTree.root.findNode(l:path)
    catch
        return {}
    endtry
endfunction

" FUNCTION: TreeFileNode.isVisible() {{{1
" returns 1 if this node should be visible according to the tree filters and
" hidden file filters (and their on/off status)
function! s:TreeFileNode.isVisible()
    return !self.path.ignore(self.getNerdtree())
endfunction

" FUNCTION: TreeFileNode.isRoot() {{{1
function! s:TreeFileNode.isRoot()
    if !g:NERDTree.ExistsForBuf()
        throw "NERDTree.NoTreeError: No tree exists for the current buffer"
    endif

    return self.equals(self.getNerdtree().root)
endfunction

" FUNCTION: TreeFileNode.New(path, nerdtree) {{{1
" Returns a new TreeNode object with the given path and parent
"
" Args:
" path: file/dir that the node represents
" nerdtree: the tree the node belongs to
function! s:TreeFileNode.New(path, nerdtree)
    if a:path.isDirectory
        return g:NERDTreeDirNode.New(a:path, a:nerdtree)
    else
        let newTreeNode = copy(self)
        let newTreeNode.path = a:path
        let newTreeNode.parent = {}
        let newTreeNode._nerdtree = a:nerdtree
        return newTreeNode
    endif
endfunction

" FUNCTION: TreeFileNode.open() {{{1
function! s:TreeFileNode.open(...)
    let opts = a:0 ? a:1 : {}
    let opener = g:NERDTreeOpener.New(self.path, opts)
    call opener.open(self)
endfunction

" FUNCTION: TreeFileNode.putCursorHere(isJump, recurseUpward){{{1
" Places the cursor on the line number this node is rendered on
"
" Args:
" isJump: 1 if this cursor movement should be counted as a jump by vim
" recurseUpward: try to put the cursor on the parent if the this node isnt
" visible
function! s:TreeFileNode.putCursorHere(isJump, recurseUpward)
    let ln = self.getNerdtree().ui.getLineNum(self)
    if ln != -1
        if a:isJump
            mark '
        endif
        call cursor(ln, col("."))
    else
        if a:recurseUpward
            let node = self
            while node != {} && self.getNerdtree().ui.getLineNum(node) ==# -1
                let node = node.parent
                call node.open()
            endwhile
            call self._nerdtree.render()
            call node.putCursorHere(a:isJump, 0)
        endif
    endif
endfunction

" FUNCTION: TreeFileNode.refresh() {{{1
function! s:TreeFileNode.refresh()
    call self.path.refresh(self.getNerdtree())
endfunction

" FUNCTION: TreeFileNode.refreshFlags() {{{1
function! s:TreeFileNode.refreshFlags()
    call self.path.refreshFlags(self.getNerdtree())
endfunction

" FUNCTION: TreeFileNode.renderToString {{{1
" returns a string representation for this tree to be rendered in the view
function! s:TreeFileNode.renderToString()
    let self.registry = { 'idx': 0, 'items': {} }
    let self.idx = 0
    return self._renderToString(0, 0, self.registry)
endfunction

" Args:
" depth: the current depth in the tree for this call
" drawText: 1 if we should actually draw the line for this node (if 0 then the
" child nodes are rendered only)
" for each depth in the tree
function! s:TreeFileNode._renderToString(depth, drawText, reg)
    let output = ""
    if a:drawText ==# 1
        let treeParts = repeat("\u00A0", (a:depth - 1) * 2)

        let self.idx = a:reg.idx
        let idx = a:reg.idx
        let a:reg.items[idx] = self

        let line = treeParts . self.displayString(winwidth(0) - ((a:depth - 1) * 2))
        let a:reg.idx += 1

        let output = output . line . "\n"
    endif

    " if the node is an open dir, draw its children
    if self.path.isDirectory ==# 1 && self.isOpen ==# 1

        let childNodesToDraw = self.getVisibleChildren()

        if self.isCascadable() && a:depth > 0
            let childNodesToDraw[0].idx = self.idx
            let a:reg.items[self.idx] = childNodesToDraw[0]
            let output = output . childNodesToDraw[0]._renderToString(a:depth, 0, a:reg)

        elseif len(childNodesToDraw) > 0
            for i in childNodesToDraw
                let output = output . i._renderToString(a:depth + 1, 1, a:reg)
            endfor
        endif
    endif

    return output
endfunction

" vim: set sw=4 sts=4 et fdm=marker:
