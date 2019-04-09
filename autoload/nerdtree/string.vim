function! nerdtree#string#trunc(s, l)
    let s = a:s
    if a:l == 0
        return ''
    endif

    let strlen = nerdtree#string#len(s)

    if strlen > a:l
        while nerdtree#string#len(s) > a:l-3 && strchars(s) > 0
            let s = substitute(s, '.$', '', '')
        endwhile
        return s . repeat('.', a:l - nerdtree#string#len(s))

    elseif strlen < a:l
        return a:s . repeat(' ', a:l - strlen)
    endif

    return a:s
endfunction


function! nerdtree#string#len(s)
    return strdisplaywidth(a:s)
endfunction
