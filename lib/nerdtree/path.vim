" ============================================================================
" CLASS: Path
"
" The Path class provides an abstracted representation of a file system
" pathname.  Various operations on pathnames are provided and a number of
" representations of a given path name can be accessed here.
" ============================================================================


let s:Path = {}
let g:NERDTreePath = s:Path

" FUNCTION: Path.AbsolutePathFor(pathStr) {{{1
function! s:Path.AbsolutePathFor(pathStr)
    let l:prependWorkingDir = 0
    let l:prependWorkingDir = a:pathStr !~# '^/'
    let l:result = a:pathStr

    if l:prependWorkingDir
        let l:result = getcwd()

        if l:result[-1:] == s:Path.Slash()
            let l:result = l:result . a:pathStr
        else
            let l:result = l:result . s:Path.Slash() . a:pathStr
        endif
    endif

    return l:result
endfunction

" FUNCTION: Path.cacheDisplayString() {{{1
function! s:Path.cacheDisplayString() abort
    let self.cachedDisplayString = self.getLastPathComponent(1)

    if self.isExecutable
        let self.cachedDisplayString = self.cachedDisplayString . '*'
    endif

    if self.isSymLink
        let self.cachedDisplayString = self.cachedDisplayString . ' -> ' . self.symLinkDest
    endif

    if self.isReadOnly
        let self.cachedDisplayString = self.cachedDisplayString . ' ['.g:NERDTreeGlyphReadOnly.']'
    endif
endfunction

" FUNCTION: Path.compareTo() {{{1
"
" Compares this Path to the given path and returns 0 if they are equal, -1 if
" this Path is "less than" the given path, or 1 if it is "greater".
"
" Args:
" path: the path object to compare this to
"
" Return:
" 1, -1 or 0
function! s:Path.compareTo(path)
    let thisPath = self.getLastPathComponent(1)
    let thatPath = a:path.getLastPathComponent(1)

    "if the paths are the same then clearly we return 0
    if thisPath ==# thatPath
        return 0
    endif

    let thisSS = self.getSortOrderIndex()
    let thatSS = a:path.getSortOrderIndex()

    "compare the sort sequences, if they are different then the return
    "value is easy
    if thisSS < thatSS
        return -1
    elseif thisSS > thatSS
        return 1
    else
        if !g:NERDTreeSortHiddenFirst
            let thisPath = substitute(thisPath, '^[._]', '', '')
            let thatPath = substitute(thatPath, '^[._]', '', '')
        endif
        "if the sort sequences are the same then compare the paths
        "alphabetically
        return thisPath <? thatPath ? -1 : 1
    endif
endfunction

" FUNCTION: Path.displayString() {{{1
"
" Returns a string that specifies how the path should be represented as a
" string
function! s:Path.displayString()
    if self.cachedDisplayString ==# ""
        call self.cacheDisplayString()
    endif

    return self.cachedDisplayString
endfunction

" FUNCTION: Path.edit() {{{1
function! s:Path.edit()
    exec "edit " . self.str({'format': 'Edit'})
endfunction

" FUNCTION: Path.extractDriveLetter(fullpath) {{{1
"
" If running windows, cache the drive letter for this path
function! s:Path.extractDriveLetter(fullpath)
    let self.drive = ''

endfunction

" FUNCTION: Path.exists() {{{1
" return 1 if this path points to a location that is readable or is a directory
function! s:Path.exists()
    let p = self.str()
    return filereadable(p) || isdirectory(p)
endfunction

" FUNCTION: Path._escChars() {{{1
function! s:Path._escChars()
    return " \\`\|\"#%&,?()\*^<>[]$"
endfunction

" FUNCTION: Path.getDir() {{{1
"
" Returns this path if it is a directory, else this paths parent.
"
" Return:
" a Path object
function! s:Path.getDir()
    if self.isDirectory
        return self
    else
        return self.getParent()
    endif
endfunction

" FUNCTION: Path.getParent() {{{1
"
" Returns a new path object for this paths parent
"
" Return:
" a new Path object
function! s:Path.getParent()
    let path = '/'. join(self.pathSegments[0:-2], '/')

    return s:Path.New(path)
endfunction

" FUNCTION: Path.getLastPathComponent(dirSlash) {{{1
"
" Gets the last part of this path.
"
" Args:
" dirSlash: if 1 then a trailing slash will be added to the returned value for
" directory nodes.
function! s:Path.getLastPathComponent(dirSlash)
    if empty(self.pathSegments)
        return ''
    endif
    let toReturn = self.pathSegments[-1]
    if a:dirSlash && self.isDirectory
        let toReturn = toReturn . '/'
    endif
    return toReturn
endfunction

" FUNCTION: Path.getSortOrderIndex() {{{1
" returns the index of the pattern in g:NERDTreeSortOrder that this path matches
function! s:Path.getSortOrderIndex()
    let i = 0
    while i < len(g:NERDTreeSortOrder)
        if  self.getLastPathComponent(1) =~# g:NERDTreeSortOrder[i]
            return i
        endif
        let i = i + 1
    endwhile

    return index(g:NERDTreeSortOrder, '*')
endfunction

" FUNCTION: Path._splitChunks(path) {{{1
" returns a list of path chunks
function! s:Path._splitChunks(path)
    let chunks = split(a:path, '\(\D\+\|\d\+\)\zs')
    let i = 0
    while i < len(chunks)
        "convert number literals to numbers
        if match(chunks[i], '^\d\+$') == 0
            let chunks[i] = str2nr(chunks[i])
        endif
        let i = i + 1
    endwhile
    return chunks
endfunction

" FUNCTION: Path.getSortKey() {{{1
" returns a key used in compare function for sorting
function! s:Path.getSortKey()
    let l:ascending = index(g:NERDTreeSortOrder,'[[timestamp]]')
    let l:descending = index(g:NERDTreeSortOrder,'[[-timestamp]]')
    if !exists("self._sortKey") || g:NERDTreeSortOrder !=# g:NERDTreeOldSortOrder || l:ascending >= 0 || l:descending >= 0
        let self._sortKey = [self.getSortOrderIndex()]

        if l:descending >= 0
            call insert(self._sortKey, -getftime(self.str()), l:descending == 0 ? 0 : len(self._sortKey))
        elseif l:ascending >= 0
            call insert(self._sortKey, getftime(self.str()), l:ascending == 0 ? 0 : len(self._sortKey))
        endif

        let path = self.getLastPathComponent(1)
        if !g:NERDTreeSortHiddenFirst
            let path = substitute(path, '^[._]', '', '')
        endif
        let path = tolower(path)

        call extend(self._sortKey, (g:NERDTreeNaturalSort ? self._splitChunks(path) : [path]))
    endif
    return self._sortKey
endfunction

" FUNCTION: Path.isHiddenUnder(path) {{{1
function! s:Path.isHiddenUnder(path)

    if !self.isUnder(a:path)
        return 0
    endif

    let l:startIndex = len(a:path.pathSegments)
    let l:segments = self.pathSegments[l:startIndex : ]

    for l:segment in l:segments
        if l:segment =~# '^\.'
            return 1
        endif
    endfor

    return 0
endfunction

" FUNCTION: Path.isUnixHiddenFile() {{{1
" check for unix hidden files
function! s:Path.isUnixHiddenFile()
    return self.getLastPathComponent(0) =~# '^\.'
endfunction

" FUNCTION: Path.isUnixHiddenPath() {{{1
" check for unix path with hidden components
function! s:Path.isUnixHiddenPath()
    if self.getLastPathComponent(0) =~# '^\.'
        return 1
    else
        for segment in self.pathSegments
            if segment =~# '^\.'
                return 1
            endif
        endfor
        return 0
    endif
endfunction

" FUNCTION: Path.ignore(nerdtree) {{{1
" returns true if this path should be ignored
function! s:Path.ignore(nerdtree)
    "filter out the user specified paths to ignore
    if a:nerdtree.ui.isIgnoreFilterEnabled()
        for i in g:NERDTreeIgnore
            if self._ignorePatternMatches(i)
                return 1
            endif
        endfor

        for callback in g:NERDTree.PathFilters()
            if {callback}({'path': self, 'nerdtree': a:nerdtree})
                return 1
            endif
        endfor
    endif

    "dont show hidden files unless instructed to
    if !a:nerdtree.ui.getShowHidden() && self.isUnixHiddenFile()
        return 1
    endif

    return 0
endfunction

" FUNCTION: Path._ignorePatternMatches(pattern) {{{1
" returns true if this path matches the given ignore pattern
function! s:Path._ignorePatternMatches(pattern)
    let pat = a:pattern
    if strpart(pat,len(pat)-7) == '[[dir]]'
        if !self.isDirectory
            return 0
        endif
        let pat = strpart(pat,0, len(pat)-7)
    elseif strpart(pat,len(pat)-8) == '[[file]]'
        if self.isDirectory
            return 0
        endif
        let pat = strpart(pat,0, len(pat)-8)
    endif

    return self.getLastPathComponent(0) =~# pat
endfunction

" FUNCTION: Path.isAncestor(path) {{{1
" return 1 if this path is somewhere above the given path in the filesystem.
"
" a:path should be a dir
function! s:Path.isAncestor(path)
    if !self.isDirectory
        return 0
    endif

    let this = self.str()
    let that = a:path.str()
    return stridx(that, this) == 0
endfunction

" FUNCTION: Path.isUnder(path) {{{1
" return 1 if this path is somewhere under the given path in the filesystem.
function! s:Path.isUnder(path)
    if a:path.isDirectory == 0
        return 0
    endif

    let this = self.str()
    let that = a:path.str()
    return stridx(this, that . s:Path.Slash()) == 0
endfunction

" FUNCTION: Path.JoinPathStrings(...) {{{1
function! s:Path.JoinPathStrings(...)
    let components = []
    for i in a:000
        let components = extend(components, split(i, '/'))
    endfor
    return '/' . join(components, '/')
endfunction

" FUNCTION: Path.equals() {{{1
"
" Determines whether 2 path objects are "equal".
" They are equal if the paths they represent are the same
"
" Args:
" path: the other path obj to compare this with
function! s:Path.equals(path)
    return self.str() ==# a:path.str()
endfunction

" FUNCTION: Path.New(pathStr) {{{1
function! s:Path.New(pathStr)
    let l:newPath = copy(self)

    call l:newPath.readInfoFromDisk(s:Path.AbsolutePathFor(a:pathStr))

    let l:newPath.cachedDisplayString = ''
    let l:newPath.flagSet = g:NERDTreeFlagSet.New()

    return l:newPath
endfunction

" FUNCTION: Path.Slash() {{{1
" Return the path separator used by the underlying file system.  Special
" consideration is taken for the use of the 'shellslash' option on Windows
" systems.
function! s:Path.Slash()
    return '/'
endfunction

" FUNCTION: Path.Resolve() {{{1
" Invoke the vim resolve() function and return the result
" This is necessary because in some versions of vim resolve() removes trailing
" slashes while in other versions it doesn't.  This always removes the trailing
" slash
function! s:Path.Resolve(path)
    let tmp = resolve(a:path)
    return tmp =~# '.\+/$' ? substitute(tmp, '/$', '', '') : tmp
endfunction

" FUNCTION: Path.readInfoFromDisk(fullpath) {{{1
"
"
" Throws NERDTree.Path.InvalidArguments exception.
function! s:Path.readInfoFromDisk(fullpath)
    call self.extractDriveLetter(a:fullpath)

    let fullpath = a:fullpath

    if getftype(fullpath) ==# "fifo"
        throw "NERDTree.InvalidFiletypeError: Cant handle FIFO files: " . a:fullpath
    endif

    let self.pathSegments = filter(split(fullpath, '/'), '!empty(v:val)')

    let self.isReadOnly = 0
    if isdirectory(a:fullpath)
        let self.isDirectory = 1
    elseif filereadable(a:fullpath)
        let self.isDirectory = 0
        let self.isReadOnly = filewritable(a:fullpath) ==# 0
    else
        throw "NERDTree.InvalidArgumentsError: Invalid path = " . a:fullpath
    endif

    let self.isExecutable = 0
    if !self.isDirectory
        let self.isExecutable = getfperm(a:fullpath) =~# 'x'
    endif

    "grab the last part of the path (minus the trailing slash)
    let lastPathComponent = self.getLastPathComponent(0)

    "get the path to the new node with the parent dir fully resolved
    let hardPath = s:Path.Resolve(self.strTrunk()) . '/' . lastPathComponent

    "if  the last part of the path is a symlink then flag it as such
    let self.isSymLink = (s:Path.Resolve(hardPath) != hardPath)
    if self.isSymLink
        let self.symLinkDest = s:Path.Resolve(fullpath)

        "if the link is a dir then slap a / on the end of its dest
        if isdirectory(self.symLinkDest)
            let self.symLinkDest = self.symLinkDest . '/'
        endif
    endif
endfunction

" FUNCTION: Path.refresh(nerdtree) {{{1
function! s:Path.refresh(nerdtree)
    call self.readInfoFromDisk(self.str())
    call g:NERDTreePathNotifier.NotifyListeners('refresh', self, a:nerdtree, {})
    call self.cacheDisplayString()
endfunction

" FUNCTION: Path.refreshFlags(nerdtree) {{{1
function! s:Path.refreshFlags(nerdtree)
    call g:NERDTreePathNotifier.NotifyListeners('refreshFlags', self, a:nerdtree, {})
    call self.cacheDisplayString()
endfunction

" FUNCTION: Path.str() {{{1
" Return a string representation of this Path object.
"
" Args:
" This function takes a single dictionary (optional) with keys and values that
" specify how the returned pathname should be formatted.
"
" The dictionary may have the following keys:
"  'format'
"
" The 'format' key may have a value of:
"  'Edit' - a string to be used with ":edit" and similar commands
"
" The 'escape' key, if specified, will cause the output to be escaped with
" Vim's internal "shellescape()" function.
function! s:Path.str(...)
    let options = a:0 ? a:1 : {}
    let toReturn = ""

    if has_key(options, 'format')
        let format = options['format']
        if has_key(self, '_strFor' . format)
            exec 'let toReturn = self._strFor' . format . '()'
        else
            throw 'NERDTree.UnknownFormatError: unknown format "'. format .'"'
        endif
    else
        let toReturn = self._str()
    endif

    return toReturn
endfunction


" FUNCTION: Path._strForEdit() {{{1
" Return a string representation of this Path that is suitable for use as an
" argument to Vim's internal ":edit" command.
function! s:Path._strForEdit()

    " Make the path relative to the current working directory, if possible.
    let l:result = fnamemodify(self.str(), ':.')
    let l:result = fnameescape(l:result)

    if empty(l:result)
        let l:result = '.'
    endif

    return l:result
endfunction

" FUNCTION: Path._strForGlob() {{{1
function! s:Path._strForGlob()
    let lead = s:Path.Slash()
    let toReturn = lead . join(self.pathSegments, s:Path.Slash())
    let toReturn = escape(toReturn, self._escChars())

    return toReturn
endfunction

" FUNCTION: Path._str() {{{1
" Return the absolute pathname associated with this Path object.  The pathname
" returned is appropriate for the underlying file system.
function! s:Path._str()
    let l:separator = s:Path.Slash()
    let l:leader = l:separator
    return l:leader . join(self.pathSegments, l:separator)
endfunction

" FUNCTION: Path.strTrunk() {{{1
" Gets the path without the last segment on the end.
function! s:Path.strTrunk()
    return self.drive . '/' . join(self.pathSegments[0:-2], '/')
endfunction

" FUNCTION: Path.tabnr() {{{1
" return the number of the first tab that is displaying this file
"
" return 0 if no tab was found
function! s:Path.tabnr()
    let str = self.str()
    for t in range(tabpagenr('$'))
        for b in tabpagebuflist(t+1)
            if str ==# expand('#' . b . ':p')
                return t+1
            endif
        endfor
    endfor
    return 0
endfunction

" vim: set sw=4 sts=4 et fdm=marker:
