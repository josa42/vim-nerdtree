syn match NERDTreeIgnore #\~#
exec 'syn match NERDTreeIgnore #\['.g:NERDTreeGlyphReadOnly.'\]#'

"highlighting for sym links
syn match NERDTreeLinkTarget #->.*#         containedin=NERDTreeDir,NERDTreeFile
syn match NERDTreeLinkFile   #.* ->#me=e-3  containedin=NERDTreeFile
syn match NERDTreeLinkDir    #.*/ ->#me=e-3 containedin=NERDTreeDir

"highlighing for directory nodes and file nodes
syn match NERDTreeDirSlash #/# containedin=NERDTreeDir

exec 'syn match NERDTreeClosable #' . escape(g:NERDTreeDirArrowCollapsible, '~') . '\ze .*/# containedin=NERDTreeDir,NERDTreeFile'
exec 'syn match NERDTreeOpenable #' . escape(g:NERDTreeDirArrowExpandable, '~') . '\ze .*/# containedin=NERDTreeDir,NERDTreeFile'

let s:dirArrows = escape(g:NERDTreeDirArrowCollapsible, '~]\-').escape(g:NERDTreeDirArrowExpandable, '~]\-')
exec 'syn match NERDTreeDir #[^'.s:dirArrows.' ].*/#'
syn match NERDTreeExecFile  #^ .*\*\($\| \)# contains=NERDTreeRO
exec 'syn match NERDTreeFile  #^[^"\.'.s:dirArrows.'] *[^'.s:dirArrows.']*# contains=NERDTreeLink,NERDTreeRO,NERDTreeExecFile'

"highlighting for readonly files
exec 'syn match NERDTreeRO # *\zs.*\ze \['.g:NERDTreeGlyphReadOnly.'\]# contains=NERDTreeIgnore,NERDTreeFile'

syn match NERDTreeFlags #^ *\zs\[[^\]]*\]# containedin=NERDTreeFile,NERDTreeExecFile
syn match NERDTreeFlags #\[[^\]]*\]# containedin=NERDTreeDir

hi def link NERDTreePart     Special
hi def link NERDTreePartFile Type
hi def link NERDTreeExecFile Title
hi def link NERDTreeDirSlash Comment

hi def link NERDTreeLinkTarget Type
hi def link NERDTreeLinkFile   NERDTreeFile
hi def link NERDTreeLinkDir    NERDTreeDir

hi def link NERDTreeDir      Directory
hi def link NERDTreeFile     Normal
hi def link NERDTreeOpenable NERDTreeDir
hi def link NERDTreeClosable NERDTreeDir
hi def link NERDTreeIgnore   ignore
hi def link NERDTreeRO       WarningMsg
hi def link NERDTreeFlags    Number

" hi def link NERDTreeCurrentNode Search

