" Easy search and replace.
nnoremap <space>/ :set operatorfunc=<SID>LeaderFGrepOperator<cr>g@
vnoremap <space>/ :<c-u>call <SID>LeaderFGrepOperator(visualmode())<cr>
function! s:LeaderFGrepOperator(type)
    let saved_unnamed_register = @@

    if a:type ==# 'v'
        normal! `<v`>y
    elseif a:type ==# 'char'
        normal! `[v`]y
    else
        return
    endif

    silent execute "Leaderf! rg --bottom " . shellescape(@@)
    silent execute "normal Q"

    let @/ = @@
    let @@ = saved_unnamed_register
endfunction

cab cf cfdo %s//
