
let s:ignored = []

function! nerdtree#gitignore#registerFilter()
  call nerdtree#gitignore#updateIgnored()
  call nerdtree#api#addPathFilter('nerdtree#gitignore#filter')

  augroup NERDTreeGitignore
    autocmd!
    autocmd BufWrite .gitignore call nerdtree#gitignore#updateIgnored()
    call nerdtree#api#refresh()
  augroup END
endfunction

function! nerdtree#gitignore#updateIgnored()
  let out = system("git clean -ndX | sed 's/^Would remove //' | sed 's/^Would skip repository //'")
  let s:ignored = split(out, "\n")
endfunction

function! nerdtree#gitignore#filter(params)
  let p = a:params['path']
  let r = substitute(p.str(), getcwd() . "/" , "", "")
  let r = p.isDirectory ? r . '/' : r
  return index(s:ignored, r) != -1
endfunction
