" FUNCTION: nerdtree#ui_glue#setupCommands() {{{1
function! nerdtree#commands#setup()
    command! -n=? -complete=dir -bar  NERDTree             call nerdtree#api#create('<args>')
    command! -n=? -complete=dir -bar  NERDTreeToggle       call nerdtree#api#toggle('<args>')
    command! -n=0 -bar                NERDTreeClose        call nerdtree#api#close()
    command! -n=0 -bar                NERDTreeMirror       call nerdtree#api#ceateMirror()
    command! -n=? -complete=file -bar NERDTreeFind         call nerdtree#api#revealPath('<args>')
    command! -n=0 -bar                NERDTreeRefreshRoot  call nerdtree#api#refresh()
    command! -n=0 -bar                NERDTreeFocus        call nerdtree#api#focus()
    command! -n=0 -bar                NERDTreeCWD          call nerdtree#api#cwd()

    command!                          NERDTreeTabsOpen     call nerdtree#tabs#openAllTabs()
    command!                          NERDTreeTabsClose    call nerdtree#tabs#closeAllTabs()
    command!                          NERDTreeTabsToggle   call nerdtree#tabs#toggleAllTabs()
    command!                          NERDTreeTabsFind     call nerdtree#tabs#findFile()
    command!                          NERDTreeMirrorOpen   call nerdtree#tabs#mirrorOrCreate()
    command!                          NERDTreeMirrorToggle call nerdtree#tabs#mirrorToggle()
    command!                          NERDTreeSteppedOpen  call nerdtree#tabs#steppedOpen()
    command!                          NERDTreeSteppedClose call nerdtree#tabs#steppedClose()
    command!                          NERDTreeFocusToggle  call nerdtree#tabs#focusToggle()
endfunction

