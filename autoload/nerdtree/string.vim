function! nerdtree#string#trunc(s, l)
    let s = a:s
    if a:l == 0
        return ''
    endif

    let strlen = nerdtree#string#len(s)

    if strlen > a:l
        let s = strcharpart(s, -1,  a:l-3)
        return s . repeat('.', a:l - nerdtree#string#len(s) - 1)
    elseif strlen < a:l
        return a:s . repeat("\u00A0", a:l - strlen)
    endif

    return a:s
endfunction

function! nerdtree#string#truncDir(s, l)
    let s = a:s
    if a:l == 0
        return ''
    endif

    let strlen = nerdtree#string#len(s)

    if strlen > a:l
        let s = strcharpart(s, -1,  a:l-4)
        return s . repeat('.', a:l - nerdtree#string#len(s) - 1) . '/'
    elseif strlen < a:l
        return a:s . repeat("\u00A0", a:l - strlen)
    endif

    return a:s
endfunction

function! nerdtree#string#len(s)
    return strwidth(a:s)
endfunction:
