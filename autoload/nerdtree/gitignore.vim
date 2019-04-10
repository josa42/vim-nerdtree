
let s:ignored = []

function! nerdtree#gitignore#registerFilter()
  call nerdtree#gitignore#updateIgnored()
  call NERDTreeAddPathFilter('nerdtree#gitignore#filter')

  augroup NERDTreeGitignore
    autocmd!
    autocmd BufWrite .gitignore call nerdtree#gitignore#updateIgnored()
    NERDTreeRefreshRoot
  augroup END
endfunction

function! nerdtree#gitignore#updateIgnored()
  let out = system("git clean -ndX | sed 's/^Would remove //'")
  let s:ignored = split(out, "\n")
endfunction

function nerdtree#gitignore#filter(params)
  let p = a:params['path']
  let r = substitute(p.str(), getcwd() . "/" , "", "")
  let r = p.isDirectory ? r . '/' : r
  return index(s:ignored, r) != -1
endfunction