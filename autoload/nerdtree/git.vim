" ============================================================================
" File:        git_status.vim
" Description: plugin for NERDTree that provides git status support
" Maintainer:  Xuyuan Pang <xuyuanp at gmail dot com>
" Last Change: 4 Apr 2014
" License:     This program is free software. It comes without any warranty,
"              to the extent permitted by applicable law. You can redistribute
"              it and/or modify it under the terms of the Do What The Fuck You
"              Want To Public License, Version 2, as published by Sam Hocevar.
"              See http://sam.zoy.org/wtfpl/COPYING for more details.
" ============================================================================
function! nerdtree#git#load()
  if executable('git')
      call g:NERDTreePathNotifier.AddListener('init',         'nerdtree#git#statusRefreshListener')
      call g:NERDTreePathNotifier.AddListener('refresh',      'nerdtree#git#statusRefreshListener')
      call g:NERDTreePathNotifier.AddListener('refreshFlags', 'nerdtree#git#statusRefreshListener')

      augroup nerdtreegit
          autocmd!
          autocmd CursorHold   *        silent! call s:cursorHoldUpdate()
          autocmd BufWritePost *                call s:fileUpdate(expand('%:p'))
          autocmd FileType     nerdtree         call s:addHighlighting()
      augroup END

      return 1
  endif

  return 0
endfunction

function! nerdtree#git#statusRefreshListener(event)
    if !exists('b:NOT_A_GIT_REPOSITORY')
        call s:statusRefresh()
    endif
    let l:path = a:event.subject
    let l:flag = s:statusPrefix(l:path)
    call l:path.flagSet.clearFlags('git')
    if l:flag !=# ''
        call l:path.flagSet.addFlag('git', l:flag)
    endif
endfunction

" FUNCTION: s:statusRefresh() {{{2
" refresh cached git status
function! s:statusRefresh()
    let b:NERDTreeCachedGitFileStatus = {}
    let b:NERDTreeCachedGitDirtyDir   = {}
    let b:NOT_A_GIT_REPOSITORY        = 1

    let l:root = fnamemodify(b:NERDTree.root.path.str(), ":p:S")
    let l:gitcmd = 'git -c color.status=false status -s'
    if g:NERDTreeShowIgnoredStatus
        let l:gitcmd = l:gitcmd . ' --ignored'
    endif
    if exists('g:NERDTreeGitStatusIgnoreSubmodules')
        let l:gitcmd = l:gitcmd . ' --ignore-submodules'
        if g:NERDTreeGitStatusIgnoreSubmodules ==# 'all' || g:NERDTreeGitStatusIgnoreSubmodules ==# 'dirty' || g:NERDTreeGitStatusIgnoreSubmodules ==# 'untracked'
            let l:gitcmd = l:gitcmd . '=' . g:NERDTreeGitStatusIgnoreSubmodules
        endif
    endif
    let l:statusesStr = system(l:gitcmd . ' ' . l:root)
    let l:statusesSplit = split(l:statusesStr, '\n')
    if l:statusesSplit != [] && l:statusesSplit[0] =~# 'fatal:.*'
        let l:statusesSplit = []
        return
    endif
    let b:NOT_A_GIT_REPOSITORY = 0

    for l:statusLine in l:statusesSplit
        " cache git status of files
        let l:pathStr = substitute(l:statusLine, '...', '', '')
        let l:pathSplit = split(l:pathStr, ' -> ')
        if len(l:pathSplit) == 2
            call s:cacheDirtyDir(l:pathSplit[0])
            let l:pathStr = l:pathSplit[1]
        else
            let l:pathStr = l:pathSplit[0]
        endif
        let l:pathStr = s:trimDoubleQuotes(l:pathStr)
        if l:pathStr =~# '\.\./.*'
            continue
        endif
        let l:statusKey = s:getFileGitStatusKey(l:statusLine[0], l:statusLine[1])
        let b:NERDTreeCachedGitFileStatus[fnameescape(l:pathStr)] = l:statusKey

        if l:statusKey == 'Ignored'
            if isdirectory(l:pathStr)
                let b:NERDTreeCachedGitDirtyDir[fnameescape(l:pathStr)] = l:statusKey
            endif
        else
            call s:cacheDirtyDir(l:pathStr)
        endif
    endfor
endfunction

function! s:cacheDirtyDir(pathStr)
    " cache dirty dir
    let l:dirtyPath = s:trimDoubleQuotes(a:pathStr)
    if l:dirtyPath =~# '\.\./.*'
        return
    endif
    let l:dirtyPath = substitute(l:dirtyPath, '/[^/]*$', '/', '')
    while l:dirtyPath =~# '.\+/.*' && has_key(b:NERDTreeCachedGitDirtyDir, fnameescape(l:dirtyPath)) == 0
        let b:NERDTreeCachedGitDirtyDir[fnameescape(l:dirtyPath)] = 'Dirty'
        let l:dirtyPath = substitute(l:dirtyPath, '/[^/]*/$', '/', '')
    endwhile
endfunction

function! s:trimDoubleQuotes(pathStr)
    let l:toReturn = substitute(a:pathStr, '^"', '', '')
    let l:toReturn = substitute(l:toReturn, '"$', '', '')
    return l:toReturn
endfunction

" FUNCTION: s:statusPrefix(path) {{{2
" return the indicator of the path
" Args: path
let s:gitStatusCacheTimeExpiry = 2
let s:gitStatusCacheTime = 0
function! s:statusPrefix(path)
    if localtime() - s:gitStatusCacheTime > s:gitStatusCacheTimeExpiry
        let s:gitStatusCacheTime = localtime()
        call s:statusRefresh()
    endif
    let l:pathStr = a:path.str()
    let l:cwd = b:NERDTree.root.path.str() . a:path.Slash()
    let l:cwd = substitute(l:cwd, '\~', '\\~', 'g')
    let l:pathStr = substitute(l:pathStr, l:cwd, '', '')
    let l:statusKey = ''
    if a:path.isDirectory
        let l:statusKey = get(b:NERDTreeCachedGitDirtyDir, fnameescape(l:pathStr . '/'), '')
    else
        let l:statusKey = get(b:NERDTreeCachedGitFileStatus, fnameescape(l:pathStr), '')
    endif
    return s:indicator(l:statusKey)
endfunction

" FUNCTION: s:getCWDGitStatus() {{{2
" return the indicator of cwd
function! g:NERDTreeGetCWDGitStatus()
    if b:NOT_A_GIT_REPOSITORY
        return ''
    elseif b:NERDTreeCachedGitDirtyDir == {} && b:NERDTreeCachedGitFileStatus == {}
        return s:indicator('Clean')
    endif
    return s:indicator('Dirty')
endfunction

function! s:indicator(statusKey)
    if exists('g:NERDTreeIndicatorMapCustom')
        let l:indicator = get(g:NERDTreeIndicatorMapCustom, a:statusKey, '')
        if l:indicator !=# ''
            return l:indicator
        endif
    endif
    let l:indicator = get(g:NERDTreeIndicatorMap, a:statusKey, '')
    if l:indicator !=# ''
        return l:indicator
    endif
    return ''
endfunction

function! s:getFileGitStatusKey(us, them)
    if a:us ==# '?' && a:them ==# '?'
        return 'Untracked'
    elseif a:us ==# ' ' && a:them ==# 'M'
        return 'Modified'
    elseif a:us =~# '[MAC]'
        return 'Staged'
    elseif a:us ==# 'R'
        return 'Renamed'
    elseif a:us ==# 'U' || a:them ==# 'U' || a:us ==# 'A' && a:them ==# 'A' || a:us ==# 'D' && a:them ==# 'D'
        return 'Unmerged'
    elseif a:them ==# 'D'
        return 'Deleted'
    elseif a:us ==# '!'
        return 'Ignored'
    else
        return 'Unknown'
    endif
endfunction
" Function: s:sID()   {{{2
function s:sID()
    if !exists('s:sid')
        let s:sid = matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
    endif
    return s:sid
endfun


" FUNCTION: s:cursorHoldUpdate() {{{2
function! s:cursorHoldUpdate()
    if g:NERDTreeUpdateOnCursorHold != 1
        return
    endif

    if !g:NERDTree.IsOpen()
        return
    endif

    " Do not update when a special buffer is selected
    if !empty(&l:buftype)
        return
    endif

    let l:winnr = winnr()
    let l:altwinnr = winnr('#')

    call g:NERDTree.CursorToTreeWin()
    call b:NERDTree.root.refreshFlags()
    call NERDTreeRender()

    exec l:altwinnr . 'wincmd w'
    exec l:winnr . 'wincmd w'
endfunction

" FUNCTION: s:fileUpdate(fname) {{{2
function! s:fileUpdate(fname)
    if g:NERDTreeUpdateOnWrite != 1
        return
    endif

    if !g:NERDTree.IsOpen()
        return
    endif

    let l:winnr = winnr()
    let l:altwinnr = winnr('#')

    call g:NERDTree.CursorToTreeWin()
    let l:node = b:NERDTree.root.findNode(g:NERDTreePath.New(a:fname))
    if l:node == {}
        return
    endif
    call l:node.refreshFlags()
    let l:node = l:node.parent
    while !empty(l:node)
        call l:node.refreshDirFlags()
        let l:node = l:node.parent
    endwhile

    call NERDTreeRender()

    exec l:altwinnr . 'wincmd w'
    exec l:winnr . 'wincmd w'
endfunction

function! s:addHighlighting()
    let l:synmap = {
      \   'NERDTreeGitStatusModified' : s:indicator('Modified'),
      \   'NERDTreeGitStatusStaged'   : s:indicator('Staged'),
      \   'NERDTreeGitStatusUntracked': s:indicator('Untracked'),
      \   'NERDTreeGitStatusRenamed'  : s:indicator('Renamed'),
      \   'NERDTreeGitStatusIgnored'  : s:indicator('Ignored'),
      \   'NERDTreeGitStatusDirDirty' : s:indicator('Dirty'),
      \   'NERDTreeGitStatusDirClean' : s:indicator('Clean')
      \ }

    for l:name in keys(l:synmap)
        exec 'syn match ' . l:name . ' #' . escape(l:synmap[l:name], '~') . '# containedin=NERDTreeFlags'
    endfor

    " TODO review defaults
    hi def link NERDTreeGitStatusModified  Special
    hi def link NERDTreeGitStatusStaged    Function
    hi def link NERDTreeGitStatusRenamed   Title
    hi def link NERDTreeGitStatusUnmerged  Label
    hi def link NERDTreeGitStatusUntracked Comment
    hi def link NERDTreeGitStatusDirDirty  Tag
    hi def link NERDTreeGitStatusDirClean  DiffAdd
    hi def link NERDTreeGitStatusIgnored   DiffAdd
endfunction
