" FUNCTION: nerdtree#ui_glue#setupCommands() {{{1
function! nerdtree#commands#setup()
    command! -n=0 -bar                NERDTree             call nerdtree#api#open()
    command! -n=0 -bar                NERDTreeToggle       call nerdtree#api#toggle()
    command! -n=0 -bar                NERDTreeClose        call nerdtree#api#close()
    command! -n=0 -bar                NERDTreeMirror       call nerdtree#api#createMirror()
    command! -n=? -complete=file -bar NERDTreeFind         call nerdtree#api#revealPath('<args>')
    command! -n=0 -bar                NERDTreeFocus        call nerdtree#api#focus()

    " command! -n=0 -bar                NERDTreeTabsOpen     call nerdtree#tabs#openAllTabs()
    " command! -n=0 -bar                NERDTreeTabsClose    call nerdtree#tabs#closeAllTabs()
    " command! -n=0 -bar                NERDTreeTabsToggle   call nerdtree#tabs#toggleAllTabs()
    " command! -n=0 -bar                NERDTreeTabsFind     call nerdtree#tabs#findFile()
    " command! -n=0 -bar                NERDTreeMirrorOpen   call nerdtree#tabs#mirrorOrCreate()
    " command! -n=0 -bar                NERDTreeMirrorToggle call nerdtree#tabs#mirrorToggle()
    " command! -n=0 -bar                NERDTreeSteppedOpen  call nerdtree#tabs#steppedOpen()
    " command! -n=0 -bar                NERDTreeSteppedClose call nerdtree#tabs#steppedClose()
    " command! -n=0 -bar                NERDTreeFocusToggle  call nerdtreeVtabs#focusToggle()
endfunction

