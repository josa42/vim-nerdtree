let s:tree_up_dir_line = '.. (up a dir)'
syn match NERDTreeIgnore #\~#
exec 'syn match NERDTreeIgnore #\['.g:NERDTreeGlyphReadOnly.'\]#'

"highlighting for the .. (up dir) line at the top of the tree
execute "syn match NERDTreeUp #\\V". s:tree_up_dir_line ."#"

"highlighting for sym links
syn match NERDTreeLinkTarget #->.*# containedin=NERDTreeDir,NERDTreeFile
syn match NERDTreeLinkFile #.* ->#me=e-3 containedin=NERDTreeFile
syn match NERDTreeLinkDir #.*/ ->#me=e-3 containedin=NERDTreeDir

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

"highlighing to conceal the delimiter around the file/dir name
exec 'syn match NERDTreeNodeDelimiters #\%d' . char2nr(g:NERDTreeNodeDelimiter) . '# conceal containedin=ALL'
setlocal conceallevel=3 concealcursor=nvic

syn match NERDTreeCWD #^[</].*$#

hi def link NERDTreePart Special
hi def link NERDTreePartFile Type
hi def link NERDTreeExecFile Title
hi def link NERDTreeDirSlash Identifier

hi def link NERDTreeToggleOn Question
hi def link NERDTreeToggleOff WarningMsg

hi def link NERDTreeLinkTarget Type
hi def link NERDTreeLinkFile Macro
hi def link NERDTreeLinkDir Macro

hi def link NERDTreeDir Directory
hi def link NERDTreeUp Directory
hi def link NERDTreeFile Normal
hi def link NERDTreeCWD Statement
hi def link NERDTreeOpenable Directory
hi def link NERDTreeClosable Directory
hi def link NERDTreeIgnore ignore
hi def link NERDTreeRO WarningMsg
hi def link NERDTreeFlags Number

hi def link NERDTreeCurrentNode Search
