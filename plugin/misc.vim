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

" ToggleTerminal
let s:termBuf = 0
function! g:JK_ToggleTerminal() 
    if !s:termBuf
        execute "normal \<c-w>b:22sp term://zsh\<CR>i"
        let bufName = bufname("%")
        let s:termBuf = bufnr(bufName)
        silent echom "New Term buffer, number: " . s:termBuf
        execute "normal :set nornu\<cr>"
        execute "normal :set nonu\<cr>"
        return
    endif
    execute "normal \<c-w>b"
    let bufName = bufname("%")
    let termBuf = bufnr(bufName)
    if termBuf == s:termBuf
        execute "normal :q\<CR>\<c-w>p"
    else
        execute "normal \<c-w>b:22sp\<CR>:buf " . s:termBuf . " \<CR>i"
    endif
endfunction

" ToggleWindowHeight
let s:recordWinHeight = 0
function! g:JK_ToggleMaxWindow()
    let curWinHeight = winheight(0)
    if curWinHeight > 80
        execute "normal " .s:recordWinHeight ."\<c-w>_"
    else
        let s:recordWinHeight = curWinHeight
        execute "normal \<c-w>_"
    endif
endfunction
