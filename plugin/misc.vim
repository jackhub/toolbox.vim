" Script state variable define.
"=============================================================================
function! s:InitScriptStates()
    if exists("g:loaded_toolbox_misc ")
        return
    endif
    let g:loaded_toolbox_misc = 1

    let s:termBuf = 0
    let s:recordWinHeight = 0

    nnoremap <space>/ :set operatorfunc=<SID>LeaderFGrepOperator<cr>g@
    vnoremap <space>/ :<c-u>call <SID>LeaderFGrepOperator(visualmode())<cr>

endfunction
call s:InitScriptStates()

" Easy global search and replace.
"=============================================================================
function! s:LeaderFGrepOperator(type)
    let saved_unnamed_register = @@

    if a:type ==# 'v'
        normal! `<v`>y
    elseif a:type ==# 'char'
        normal! `[v`]y
    else
        return
    endif

    normal m0
    silent execute "Leaderf! rg --bottom " . shellescape(@@)

    let @/ = @@
    let @@ = saved_unnamed_register
endfunction
cab cf cfdo %s//

" Quickfix up and down
" default use leaderf quickfix, unless there is a vim buildin quickfix.
"=============================================================================
function! g:JK_QuickfixDown()
    let preBufwinnr = bufwinnr("%")
    execute "normal \<c-w>b"
    if preBufwinnr == bufwinnr("%")
        Leaderf --next
    else
        let bufType = getbufvar("%", "&filetype")
        execute "normal \<c-w>p"
        if bufType == "qf"
            cn
        else
            Leaderf --next
        endif
    endif
endfunction

function! g:JK_QuickfixUp()
    let preBufwinnr = bufwinnr("%")
    execute "normal \<c-w>b"
    if preBufwinnr == bufwinnr("%")
        Leaderf --previous
    else
        let bufType = getbufvar("%", "&filetype")
        execute "normal \<c-w>p"
        if bufType == "qf"
            cp
        else
            Leaderf --previous
        endif
    endif
endfunction

" ToggleTerminal
"=============================================================================
function! g:JK_ToggleTerminal() 
    if !s:termBuf
        silent execute "normal \<c-w>b:sp term://zsh\<CR>:set filetype=term\<CR>i"
        silent execute "normal :set nornu\<cr>:set nonu\<cr>"
        let s:termBuf = bufnr("%")
        echom "Create a new terminal buffer, number: " . s:termBuf
        return
    endif
    execute "normal \<c-w>b"
    let termBuf = bufnr("%")
    if termBuf == s:termBuf
        execute "normal :q\<CR>\<C-W>p"
    else
        if bufexists(s:termBuf)
            silent execute "normal :sp\<CR>:buf " . s:termBuf . " \<CR>i"
        else
            let s:termBuf = 0
            call g:JK_ToggleTerminal()
        endif
    endif
endfunction

" ToggleWindowHeight
"=============================================================================
function! g:JK_ToggleMaxWindow()
    let curWinHeight = winheight(0)
    if curWinHeight > 50
        execute "normal " .s:recordWinHeight ."\<c-w>_"
    else
        let s:recordWinHeight = curWinHeight
        execute "normal \<c-w>_"
    endif
endfunction

" Trim whitespace-only line.
command! JTrimWhiteLine execute "normal ma\<CR>:%s/^\\s\\+$//g\<CR>`a"


