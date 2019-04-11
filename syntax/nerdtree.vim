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

highlight default link NERDTreePart       Special
highlight default link NERDTreePartFile   Type
highlight default link NERDTreeExecFile   Title
highlight default link NERDTreeDirSlash   Comment

highlight default link NERDTreeLinkTarget Type
highlight default link NERDTreeLinkFile   NERDTreeFile
highlight default link NERDTreeLinkDir    NERDTreeDir

highlight default link NERDTreeDir        Directory
highlight default link NERDTreeFile       Normal
highlight default link NERDTreeOpenable   NERDTreeDir
highlight default link NERDTreeClosable   NERDTreeDir
highlight default link NERDTreeIgnore     ignore
highlight default link NERDTreeRO         WarningMsg
highlight default link NERDTreeFlags      Number

" highlight default link NERDTreeCurrentNode Search

" TODO review defaults
highlight default link NERDTreeGitStatusModified  Special
highlight default link NERDTreeGitStatusStaged    Function
highlight default link NERDTreeGitStatusRenamed   Title
highlight default link NERDTreeGitStatusUnmerged  Label
highlight default link NERDTreeGitStatusUntracked Comment
highlight default link NERDTreeGitStatusDirDirty  Tag
highlight default link NERDTreeGitStatusDirClean  DiffAdd
highlight default link NERDTreeGitStatusIgnored   DiffAdd
