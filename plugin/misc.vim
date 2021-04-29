" Script state variable define.
"=============================================================================
function! s:InitScriptStates()
    if exists("g:loaded_toolbox_misc ")
        return
    endif
    let g:loaded_toolbox_misc = 1

    " Script level flags
    let s:termBuf = 0
    let s:recordWinHeight = 0
    let s:profileStarted = 0
    " End

    " Vim maping and setting.
    nnoremap <space>/ :set operatorfunc=<SID>LeaderFGrepOperator<cr>g@
    vnoremap <space>/ :<c-u>call <SID>LeaderFGrepOperator(visualmode())<cr>
    nnoremap g1 1gt
    nnoremap g2 2gt
    nnoremap g3 3gt
    nnoremap g4 4gt
    nnoremap g5 5gt
    nnoremap g6 6gt
    nnoremap g7 7gt
    set tabline=%!MyTabLine()

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
    silent execute "Leaderf! rg --nowrap --bottom " . shellescape(@@)

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
            silent! cn
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
            silent! cp
        else
            Leaderf --previous
        endif
    endif
endfunction

" ToggleTerminal
"=============================================================================
function! g:JK_ToggleTerminal() 
    if !s:termBuf
        silent execute "normal \<c-w>b:sp term://zsh\<CR>i"
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
"=============================================================================
command! JKTrimWhiteLine execute "normal ma\<CR>:%s/^\\s\\+$//g\<CR>`a"

" ToggleVerbose
"=============================================================================
function! g:JK_ToggleVerbose()
    if !&verbose
        silent execute "normal :!echo > /tmp/vim-verbose.log\<CR>"
        set verbosefile=/tmp/vim-verbose.log
        set verbose=15
    else
        set verbose=0
        set verbosefile=
    endif
endfunction
command! JKToggleVerbose call g:JK_ToggleVerbose()

" ToggleProfile
"=============================================================================
function! g:JK_ToggleProfile()
    if s:profileStarted
        silent execute "normal :profile stop\<CR>"
        let s:profileStarted = 0
    else
        silent execute "normal :!echo > /tmp/vim-profile.log\<CR>:profile start /tmp/vim-profile.log\<CR>:profile file *\<CR>:profile func *\<CR>"
        let s:profileStarted = 1
    endif
endfunction
command! JKToggleProfile call g:JK_ToggleProfile()


" Tabline
"=============================================================================
" copy and modify from help tabpage.txt / setting-tabline.
function MyTabLine()
    let s = ''
    for i in range(tabpagenr('$'))
        if i + 1 == tabpagenr()
            let s .= '%#TabLineSel#'
        else
            let s .= '%#TabLine#'
        endif
        let s .= '%' . (i + 1) . 'T'
        let s .= '   ' . (i + 1) .'_%{MyTabLabel(' . (i + 1) . ')}   '
        let s .= "\ufc63 "
    endfor
    let s .= '%#TabLineFill#%T'
    return s
endfunction
function MyTabLabel(n)
    let buflist = tabpagebuflist(a:n)
    let winnr = tabpagewinnr(a:n)
    return fnamemodify(bufname(buflist[winnr - 1]), ':t')
endfunction


" Auto load session
"=============================================================================
function! g:JK_LoadSessionFile()
    let session_file = '~/.vim/session/' . substitute(getcwd(), '/', '\\%', 'g')
    let has_session = filereadable(expand(session_file))
    if has_session && argc() == 0
        echom "Load session file: " . expand(session_file)
        exe "so " . session_file
    endif
endfunction
function! g:JK_SaveSessionFileIfNeeded(force)
    if winnr('$') != 1 || tabpagenr('$') != 1 || a:force
        " Use \\% to prevent expand % when make session
        let session_file = '~/.vim/session/' . substitute(getcwd(), '/', '\\%', 'g')
        wa
        exe "mksession! " . session_file
    endif
endfunction
command! JKLoadSession call JK_LoadSessionFile()


" MISC autocmd
"=============================================================================
augroup JMISC
    autocmd!
    autocmd VimEnter * nested call JK_LoadSessionFile()
augroup END
