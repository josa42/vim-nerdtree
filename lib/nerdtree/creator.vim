" ============================================================================
" CLASS: Creator
"
" This class is responsible for creating NERDTree instances.  The new NERDTree
" may be a tab tree, a window tree, or a mirrored tree.  In the process of
" creating a NERDTree, it sets up all of the window and buffer options and key
" mappings etc.
" ============================================================================


let s:Creator = {}
let g:NERDTreeCreator = s:Creator

" FUNCTION: s:Creator._broadcastInitEvent() {{{1
function! s:Creator._broadcastInitEvent()
    silent doautocmd User NERDTreeInit
endfunction


" FUNCTION: s:Creator.CreateTabTree(a:name) {{{1
function! s:Creator.CreateTabTree(name)
    let creator = s:Creator.New()
    call creator.createTabTree(a:name)
endfunction

" FUNCTION: s:Creator.createTabTree(a:name) {{{1
" name: the name of a bookmark or a directory
function! s:Creator.createTabTree(name)
    let l:path = self._pathForString(a:name)

    " Abort if an exception was thrown (i.e., if the bookmark or directory
    " does not exist).
    if empty(l:path)
        return
    endif

    if g:NERDTree.ExistsForTab()
        call g:NERDTree.Close()
        call self._removeTreeBufForTab()
    endif

    call self._createTreeWin()
    call self._createNERDTree(l:path, 'tab')
    call b:NERDTree.render()
    call b:NERDTree.root.putCursorHere(0, 0)

    call self._broadcastInitEvent()
endfunction

" FUNCTION: s:Creator.CreateWindowTree(dir) {{{1
function! s:Creator.CreateWindowTree(dir)
    let creator = s:Creator.New()
    call creator.createWindowTree(a:dir)
endfunction

" FUNCTION: s:Creator.createWindowTree(dir) {{{1
function! s:Creator.createWindowTree(dir)
    try
        let path = g:NERDTreePath.New(a:dir)
    catch /^NERDTree.InvalidArgumentsError/
        call nerdtree#echo("Invalid directory name:" . a:name)
        return
    endtry

    "we want the directory buffer to disappear when we do the :edit below
    setlocal bufhidden=wipe

    let previousBuf = expand("#")

    "we need a unique name for each window tree buffer to ensure they are
    "all independent
    exec "silent edit " . self._nextBufferName()

    call self._createNERDTree(path, "window")
    let b:NERDTree._previousBuf = bufnr(previousBuf)
    call self._setCommonBufOptions()

    call b:NERDTree.render()

    call self._broadcastInitEvent()
endfunction

" FUNCTION: s:Creator._createNERDTree(path) {{{1
function! s:Creator._createNERDTree(path, type)
    let b:NERDTree = g:NERDTree.New(a:path, a:type)

    " TODO: This assignment is kept for compatibility reasons.  Many other
    " plugins use "b:NERDTreeRoot" instead of "b:NERDTree.root".  Remove this
    " assignment in the future.
    let b:NERDTreeRoot = b:NERDTree.root

    call b:NERDTree.root.open()
endfunction

" FUNCTION: s:Creator.CreateMirror() {{{1
function! s:Creator.CreateMirror()
    let creator = s:Creator.New()
    call creator.createMirror()
endfunction

" FUNCTION: s:Creator.createMirror() {{{1
function! s:Creator.createMirror()
    "get the names off all the NERDTree buffers
    let treeBufNames = []
    for i in range(1, tabpagenr("$"))
        let nextName = self._tabpagevar(i, 'NERDTreeBufName')
        if nextName != -1 && (!exists("t:NERDTreeBufName") || nextName != t:NERDTreeBufName)
            call add(treeBufNames, nextName)
        endif
    endfor
    let treeBufNames = self._uniq(treeBufNames)

    "map the option names (that the user will be prompted with) to the nerd
    "tree buffer names
    let options = {}
    let i = 0
    while i < len(treeBufNames)
        let bufName = treeBufNames[i]
        let treeRoot = getbufvar(bufName, "NERDTree").root
        let options[i+1 . '. ' . treeRoot.path.str() . '  (buf name: ' . bufName . ')'] = bufName
        let i = i + 1
    endwhile

    "work out which tree to mirror, if there is more than 1 then ask the user
    let bufferName = ''
    if len(keys(options)) > 1
        let choices = ["Choose a tree to mirror"]
        let choices = extend(choices, sort(keys(options)))
        let choice = inputlist(choices)
        if choice < 1 || choice > len(options) || choice ==# ''
            return
        endif

        let bufferName = options[sort(keys(options))[choice-1]]
    elseif len(keys(options)) ==# 1
        let bufferName = values(options)[0]
    else
        call nerdtree#echo("No trees to mirror")
        return
    endif

    if g:NERDTree.ExistsForTab() && g:NERDTree.IsOpen()
        call g:NERDTree.Close()
    endif

    let t:NERDTreeBufName = bufferName
    call self._createTreeWin()
    exec 'buffer ' .  bufferName
    if !&hidden
        call b:NERDTree.render()
    endif
endfunction

" FUNCTION: s:Creator._createTreeWin() {{{1
" Initialize the NERDTree window.  Open the window, size it properly, set all
" local options, etc.
function! s:Creator._createTreeWin()
    let l:splitLocation = g:NERDTreeWinPos ==# 'left' ? 'topleft ' : 'botright '
    let l:splitSize = g:NERDTreeWinSize

    if !g:NERDTree.ExistsForTab()
        let t:NERDTreeBufName = self._nextBufferName()
        silent! execute l:splitLocation . 'vertical ' . l:splitSize . ' new'
        silent! execute 'edit ' . t:NERDTreeBufName
    else
        silent! execute l:splitLocation . 'vertical ' . l:splitSize . ' split'
        silent! execute 'buffer ' . t:NERDTreeBufName
    endif

    call self._setCommonBufOptions()

    clearjumps

    setlocal winfixwidth
endfunction

" FUNCTION: s:Creator._isBufHidden(nr) {{{1
function! s:Creator._isBufHidden(nr)
    redir => bufs
    silent ls!
    redir END

    return bufs =~ a:nr . '..h'
endfunction

" FUNCTION: s:Creator.New() {{{1
function! s:Creator.New()
    let newCreator = copy(self)
    return newCreator
endfunction

" FUNCTION: s:Creator._nextBufferName() {{{2
" returns the buffer name for the next NERDTree
function! s:Creator._nextBufferName()
    return 'NERDTree'
endfunction

" FUNCTION: s:Creator._pathForString(str) {{{1
" find a adirectory for the given string
function! s:Creator._pathForString(str)
    let path = {}
    let dir = a:str ==# '' ? getcwd() : a:str

    "hack to get an absolute path if a relative path is given
    if dir =~# '^\.'
        let dir = getcwd() . g:NERDTreePath.Slash() . dir
    endif
    let dir = g:NERDTreePath.Resolve(dir)

    try
        let path = g:NERDTreePath.New(dir)
    catch /^NERDTree.InvalidArgumentsError/
        call nerdtree#echo("No directory found for: " . a:str)
        return {}
    endtry
    if !path.isDirectory
        let path = path.getParent()
    endif

    return path
endfunction

" Function: s:Creator._removeTreeBufForTab()   {{{1
function! s:Creator._removeTreeBufForTab()
    let buf = bufnr(t:NERDTreeBufName)

    "if &hidden is not set then it will already be gone
    if buf != -1

        "nerdtree buf may be mirrored/displayed elsewhere
        if self._isBufHidden(buf)
            exec "bwipeout " . buf
        endif

    endif

    unlet t:NERDTreeBufName
endfunction

" FUNCTION: s:Creator._setCommonBufOptions() {{{1
function! s:Creator._setCommonBufOptions()

    " Options for a non-file/control buffer.
    setlocal bufhidden=hide
    setlocal buftype=nofile
    setlocal noswapfile

    " Options for controlling buffer/window appearance.
    setlocal foldcolumn=0
    setlocal foldmethod=manual
    setlocal nobuflisted
    setlocal nofoldenable
    setlocal nolist
    setlocal nospell
    setlocal nowrap
    setlocal nonu
    setlocal nornu
    setlocal signcolumn=no

    iabc <buffer>

    setlocal cursorline
    setlocal filetype=nerdtree
endfunction

" FUNCTION: s:Creator._tabpagevar(tabnr, var) {{{1
function! s:Creator._tabpagevar(tabnr, var)
    let currentTab = tabpagenr()
    let old_ei = &ei
    set ei=all

    exec "tabnext " . a:tabnr
    let v = -1
    if exists('t:' . a:var)
        exec 'let v = t:' . a:var
    endif
    exec "tabnext " . currentTab

    let &ei = old_ei

    return v
endfunction

" FUNCTION: s:Creator.ToggleTabTree(dir) {{{1
function! s:Creator.ToggleTabTree(dir)
    let creator = s:Creator.New()
    call creator.toggleTabTree(a:dir)
endfunction

" FUNCTION: s:Creator.toggleTabTree(dir) {{{1
" Toggles the NERDTree. I.e the NERDTree is open, it is closed, if it is
" closed it is restored or initialized (if it doesnt exist)
"
" Args:
" dir: the full path for the root node (is only used if the NERDTree is being
" initialized.
function! s:Creator.toggleTabTree(dir)
    if g:NERDTree.ExistsForTab()
        if !g:NERDTree.IsOpen()
            call self._createTreeWin()
            if !&hidden
                call b:NERDTree.render()
            endif
            call b:NERDTree.ui.restoreScreenState()
        else
            call g:NERDTree.Close()
        endif
    else
        call self.createTabTree(a:dir)
    endif
endfunction

" Function: s:Creator._uniq(list)   {{{1
" returns a:list without duplicates
function! s:Creator._uniq(list)
  let uniqlist = []
  for elem in a:list
    if index(uniqlist, elem) ==# -1
      let uniqlist += [elem]
    endif
  endfor
  return uniqlist
endfunction

" vim: set sw=4 sts=4 et fdm=marker:
