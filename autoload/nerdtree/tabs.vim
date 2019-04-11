" === plugin functions === {{{
"
" === NERDTree manipulation (opening, closing etc.) === {{{
"
" nerdtree#tabs#mirrorOrCreate() {{{
"
" switch NERDTree on for current tab -- mirror it if possible, otherwise create it
fun! nerdtree#tabs#mirrorOrCreate()
  let l:nerdtree_open = s:IsNERDTreeOpenInCurrentTab()

  " if NERDTree is not active in the current tab, try to mirror it
  if !l:nerdtree_open
    let l:previous_winnr = winnr("$")

    silent call nerdtree#api#ceateMirror()

    " if the window count of current tab didn't increase after NERDTreeMirror,
    " it means NERDTreeMirror was unsuccessful and a new NERDTree has to be created
    if l:previous_winnr == winnr("$")
      silent call nerdtree#api#toggle()
    endif
  endif
endfun

" }}}
" nerdtree#tabs#mirrorToggle() {{{
"
" toggle NERDTree in current tab, use mirror if possible
fun! nerdtree#tabs#mirrorToggle()
  let l:nerdtree_open = s:IsNERDTreeOpenInCurrentTab()

  if l:nerdtree_open
    silent NERDTreeClose
  else
    call nerdtree#tabs#mirrorOrCreate()
  endif
endfun

" }}}
" nerdtree#tabs#openAllTabs() {{{
"
" switch NERDTree on for all tabs while making sure there is only one NERDTree buffer
fun! nerdtree#tabs#openAllTabs()
  let s:nerdtree_globally_active = 1

  " tabdo doesn't preserve current tab - save it and restore it afterwards
  let l:current_tab = tabpagenr()
  tabdo call nerdtree#tabs#mirrorOrCreate()
  exe 'tabn ' . l:current_tab
  if g:NERDtreeTabsAutofind
    call nerdtree#tabs#unfocus()
    call nerdtree#tabs#findFile()
  endif
endfun

" }}}
" nerdtree#tabs#closeAllTabs() {{{
"
" close NERDTree across all tabs
fun! nerdtree#tabs#closeAllTabs()
  let s:nerdtree_globally_active = 0

  " tabdo doesn't preserve current tab - save it and restore it afterwards
  let l:current_tab = tabpagenr()
  tabdo silent NERDTreeClose
  exe 'tabn ' . l:current_tab
endfun

" }}}
" nerdtree#tabs#toggleAllTabs() {{{
"
" toggle NERDTree in current tab and match the state in all other tabs
fun! nerdtree#tabs#toggleAllTabs()
  let l:nerdtree_open = s:IsNERDTreeOpenInCurrentTab()
  let s:disable_handlers_for_tabdo = 1

  if l:nerdtree_open
    call nerdtree#tabs#closeAllTabs()
  else
    call nerdtree#tabs#openAllTabs()
    " force focus to NERDTree in current tab
    if exists("t:NERDTreeBufName") && bufwinnr(t:NERDTreeBufName) != -1
      exe bufwinnr(t:NERDTreeBufName) . "wincmd w"
    endif
  endif

  let s:disable_handlers_for_tabdo = 0
endfun

" }}}
" nerdtree#tabs#steppedOpen() {{{
"
" focus the NERDTree view, creating one first if none is present
fun! nerdtree#tabs#steppedOpen()
  if !s:IsCurrentWindowNERDTree()
    if s:IsNERDTreeOpenInCurrentTab()
      call nerdtree#tabs#focus()
    else
      call nerdtree#tabs#mirrorOrCreate()
    endif
  endif
endfun

" }}}
" nerdtree#tabs#steppedClose{() {{{
"
" unfocus the NERDTree view or closes it if it hadn't had focus at the time of
" the call
fun! nerdtree#tabs#steppedClose()
  if s:IsCurrentWindowNERDTree()
    call nerdtree#tabs#unfocus()
  else
    let l:nerdtree_open = s:IsNERDTreeOpenInCurrentTab()

    if l:nerdtree_open
      silent NERDTreeClose
    endif
  endif
endfun

" }}}
" nerdtree#tabs#focusToggle() {{{
"
" focus the NERDTree view or creates it if in a file,
" or unfocus NERDTree view if in NERDTree
fun! nerdtree#tabs#focusToggle()
  let s:disable_handlers_for_tabdo = 1
  if s:IsCurrentWindowNERDTree()
    call nerdtree#tabs#unfocus()
  else
    if !s:IsNERDTreeOpenInCurrentTab()
      call nerdtree#tabs#openAllTabs()
    endif
    call nerdtree#tabs#focus()
  endif
  let s:disable_handlers_for_tabdo = 0
endfun
" }}}
"
" === NERDTree manipulation (opening, closing etc.) === }}}
" === focus functions === {{{
"
" nerdtree#tabs#focus() {{{
"
" if the current window is NERDTree, move focus to the next window
fun! nerdtree#tabs#focus()
  if !s:IsCurrentWindowNERDTree() && exists("t:NERDTreeBufName") && bufwinnr(t:NERDTreeBufName) != -1
    exe bufwinnr(t:NERDTreeBufName) . "wincmd w"
  endif
endfun

" }}}
" nerdtree#tabs#unfocus() {{{
"
" if the current window is NERDTree, move focus to the next window
fun! nerdtree#tabs#unfocus()
  " save current window so that it's focus can be restored after switching
  " back to this tab
  let t:NERDTreeTabLastWindow = winnr()
  if s:IsCurrentWindowNERDTree()
    let l:winNum = s:NextNormalWindow()
    if l:winNum != -1
      exec l:winNum.'wincmd w'
    else
      wincmd w
    endif
  endif
endfun

" }}}
" nerdtree#tabs#restoreFocus() {{{
"
" restore focus to the window that was focused before leaving current tab
fun! nerdtree#tabs#restoreFocus()
  if s:is_nerdtree_globally_focused
    call nerdtree#tabs#focus()
  elseif exists("t:NERDTreeTabLastWindow") && exists("t:NERDTreeBufName") && t:NERDTreeTabLastWindow != bufwinnr(t:NERDTreeBufName)
    exe t:NERDTreeTabLastWindow . "wincmd w"
  endif
endfun

" }}}
" s:SaveGlobalFocus() {{{
"
fun! s:SaveGlobalFocus()
  let s:is_nerdtree_globally_focused = s:IsCurrentWindowNERDTree()
endfun

" }}}
" s:IfFocusOnStartup() {{{
"
fun! s:IfFocusOnStartup()
  return strlen(bufname('$')) == 0 || !getbufvar('$', '&modifiable')
endfun

" }}}
"
" === focus functions === }}}
" === utility functions === {{{
"
" s:NextNormalWindow() {{{
"
" find next window with a normal buffer
fun! s:NextNormalWindow()
  let l:i = 1
  while(l:i <= winnr('$'))
    let l:buf = winbufnr(l:i)

    " skip unlisted buffers
    if buflisted(l:buf) == 0
      let l:i = l:i + 1
      continue
    endif

    " skip un-modifiable buffers
    if getbufvar(l:buf, '&modifiable') != 1
      let l:i = l:i + 1
      continue
    endif

    " skip temporary buffers with buftype set
    if empty(getbufvar(l:buf, "&buftype")) != 1
      let l:i = l:i + 1
      continue
    endif

    return l:i
  endwhile
  return -1
endfun

" }}}
" s:CloseIfOnlyNerdTreeLeft() {{{
"
" Close all open buffers on entering a window if the only
" buffer that's left is the NERDTree buffer
fun! s:CloseIfOnlyNerdTreeLeft()
  if exists("t:NERDTreeBufName") && bufwinnr(t:NERDTreeBufName) != -1 && winnr("$") == 1
    q
  endif
endfun

" }}}
" s:IsCurrentWindowNERDTree() {{{
"
" returns 1 if current window is NERDTree, false otherwise
fun! s:IsCurrentWindowNERDTree()
  return exists("t:NERDTreeBufName") && bufwinnr(t:NERDTreeBufName) == winnr()
endfun

" }}}
" s:IsNERDTreeOpenInCurrentTab() {{{
"
" check if NERDTree is open in current tab
fun! s:IsNERDTreeOpenInCurrentTab()
  return exists("t:NERDTreeBufName") && bufwinnr(t:NERDTreeBufName) != -1
endfun

" }}}
" s:IsNERDTreePresentInCurrentTab() {{{
"
" check if NERDTree is present in current tab (not necessarily visible)
fun! s:IsNERDTreePresentInCurrentTab()
  return exists("t:NERDTreeBufName")
endfun

" }}}
"
" === utility functions === }}}
" === NERDTree view manipulation (scroll and cursor positions) === {{{
"
" s:SaveNERDTreeViewIfPossible() {{{
"
fun! s:SaveNERDTreeViewIfPossible()
  if exists("t:NERDTreeBufName") && bufwinnr(t:NERDTreeBufName) == winnr()
    " save scroll and cursor etc.
    let s:nerdtree_view = winsaveview()

    " save NERDTree window width
    let s:nerdtree_width = winwidth(winnr())

    " save buffer name (to be able to correct desync by commands spawning
    " a new NERDTree instance)
    let s:nerdtree_buffer = bufname("%")
  endif
endfun

" }}}
" s:RestoreNERDTreeViewIfPossible() {{{
"
fun! s:RestoreNERDTreeViewIfPossible()
  " if nerdtree exists in current tab, it is the current window and if saved
  " state is available, restore it
  let l:view_state_saved = exists('s:nerdtree_view') && exists('s:nerdtree_width')
  if s:IsNERDTreeOpenInCurrentTab() && l:view_state_saved
    let l:current_winnr = winnr()
    let l:nerdtree_winnr = bufwinnr(t:NERDTreeBufName)

    " switch to NERDTree window
    exe l:nerdtree_winnr . "wincmd w"
    " load the correct NERDTree buffer if not already loaded
    if exists('s:nerdtree_buffer') && t:NERDTreeBufName != s:nerdtree_buffer
      silent call nerdtree#api#close()
      silent call nerdtree#api#ceateMirror()
    endif
    " restore cursor, scroll and window width
    call winrestview(s:nerdtree_view)
    exe "vertical resize " . s:nerdtree_width

    " switch back to whatever window was focused before
    exe l:current_winnr . "wincmd w"
  endif
endfun

" }}}
" nerdtree#tabs#findFile() {{{
"
fun! nerdtree#tabs#findFile()
  if s:IsNERDTreeOpenInCurrentTab()
    silent NERDTreeFind
  endif
endfun

" }}}
"
" === NERDTree view manipulation (scroll and cursor positions) === }}}
"
" === plugin functions ===  }}}
" === plugin event handlers === {{{
"
" nerdtree#tabs#load() {{{
"
fun! nerdtree#tabs#load()
  if exists('g:nerdtree_tabs_loaded')
    return
  endif

  let s:disable_handlers_for_tabdo = 0

  " global on/off NERDTree state
  " the exists check is to enable script reloading without resetting the state
  if !exists('s:nerdtree_globally_active')
    let s:nerdtree_globally_active = 0
  endif

  " global focused/unfocused NERDTree state
  " the exists check is to enable script reloading without resetting the state
  if !exists('s:is_nerdtree_globally_focused')
    call s:SaveGlobalFocus()
  end

  augroup NERDTreeTabs
    autocmd!
    autocmd TabEnter * call <SID>TabEnterHandler()
    autocmd TabLeave * call <SID>TabLeaveHandler()
    " We enable nesting for this autocommand (see :h autocmd-nested) so that
    " exiting Vim when NERDTree is the last window triggers the VimLeave event.
    autocmd WinEnter * nested call <SID>WinEnterHandler()
    autocmd WinLeave * call <SID>WinLeaveHandler()
    autocmd BufWinEnter * call <SID>BufWinEnterHandler()
    autocmd BufRead * call <SID>BufReadHandler()
  augroup END

  let g:nerdtree_tabs_loaded = 1
endfun


" }}} s:NewTabCreated {{{
"
" A flag to indicate that a new tab has just been created.
"
" We will handle the remaining work for this newly created tab separately in
" BufWinEnter event.
"
let s:NewTabCreated = 0

" }}}
" s:TabEnterHandler() {{{
"
fun! s:TabEnterHandler()
  if s:disable_handlers_for_tabdo
    return
  endif

  if s:nerdtree_globally_active && !s:IsNERDTreeOpenInCurrentTab()
    call nerdtree#tabs#mirrorOrCreate()

    " move focus to the previous window
    wincmd p

    " Turn on the 'NewTabCreated' flag
    let s:NewTabCreated = 1
  endif

  call s:RestoreNERDTreeViewIfPossible()

  if !s:NewTabCreated
    call nerdtree#tabs#restoreFocus()
  endif
endfun

" }}}
" s:TabLeaveHandler() {{{
"
fun! s:TabLeaveHandler()
  call s:SaveGlobalFocus()
  call nerdtree#tabs#unfocus()
endfun

" }}}
" s:WinEnterHandler() {{{
"
fun! s:WinEnterHandler()
  if s:disable_handlers_for_tabdo
    return
  endif

  " We need to handle VimLeave properly.
  " But we shouldn't nest redefined autocmds
  let s:ei = &eventignore
  let &eventignore = 'VimEnter,TabEnter,TabLeave,WinEnter,WinLeave,BufWinEnter,BufRead'
  call s:CloseIfOnlyNerdTreeLeft()
  let &eventignore = s:ei
endfun

" }}}
" s:WinLeaveHandler() {{{
"
fun! s:WinLeaveHandler()
  if s:disable_handlers_for_tabdo
    return
  endif

  call s:SaveNERDTreeViewIfPossible()
endfun

" }}}
" s:BufWinEnterHandler() {{{
"
" BufWinEnter event only gets triggered after a new buffer has been
" successfully loaded, it is a proper time to finish the remaining
" work for newly opened tab.
"
fun! s:BufWinEnterHandler()
  if s:NewTabCreated
    " Turn off the 'NewTabCreated' flag
    let s:NewTabCreated = 0

    " Restore focus to NERDTree if necessary
    call nerdtree#tabs#restoreFocus()
  endif
endfun

" }}}
" s:BufReadHandler() {{{
"
" BufRead event gets triggered after a new buffer has been
" successfully read from file.
"
fun! s:BufReadHandler()
  " Refresh NERDTree to show currently opened file
  if g:NERDtreeTabsAutofind
    call nerdtree#tabs#findFile()
    call nerdtree#tabs#unfocus()
  endif
endfun

" }}}
"

