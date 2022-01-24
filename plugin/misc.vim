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
    nnoremap `_1 1gt
    nnoremap `_2 2gt
    nnoremap `_3 3gt
    nnoremap `_4 4gt
    nnoremap `_5 5gt
    nnoremap `_6 6gt
    nnoremap `_7 7gt
    inoremap `_1 <esc>1gt
    inoremap `_2 <esc>2gt
    inoremap `_3 <esc>3gt
    inoremap `_4 <esc>4gt
    inoremap `_5 <esc>5gt
    inoremap `_6 <esc>6gt
    inoremap `_7 <esc>7gt
    cnoremap `_1 <esc>1gt
    cnoremap `_2 <esc>2gt
    cnoremap `_3 <esc>3gt
    cnoremap `_4 <esc>4gt
    cnoremap `_5 <esc>5gt
    cnoremap `_6 <esc>6gt
    cnoremap `_7 <esc>7gt
    tnoremap `_1 <c-\><c-n>1gt
    tnoremap `_2 <c-\><c-n>2gt
    tnoremap `_3 <c-\><c-n>3gt
    tnoremap `_4 <c-\><c-n>4gt
    tnoremap `_5 <c-\><c-n>5gt
    tnoremap `_6 <c-\><c-n>6gt
    tnoremap `_7 <c-\><c-n>7gt
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
    " silent execute "lua require('telescope.builtin').grep_string({search=" . shellescape(@@) . "})"
    silent execute "Leaderf! rg --nowrap --bottom " . shellescape(@@)

    let @/ = @@
    let @@ = saved_unnamed_register
endfunction
cab cf cfdo %s//

" Quickfix up and down
" default use leaderf quickfix, unless there is a vim buildin quickfix.
" Need quickfix or leaderf window exist.
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
        silent execute "normal \<c-w>b:20sp term://zsh\<CR>:keepalt file zsh\<CR>:set ft=terminal\<CR>i"
        silent execute "normal :set nornu\<cr>:set nonu\<cr>"
        let s:termBuf = bufnr("%")
        echom "Create a new terminal buffer, number: " . s:termBuf
        return
    endif
    execute "normal \<c-w>b"
    let termBuf = bufnr("%")
    if termBuf == s:termBuf
        execute "normal i"
    else
        if bufexists(s:termBuf)
            silent execute "normal :20sp\<CR>:buf " . s:termBuf . " \<CR>i"
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

" Trim trailing bad whitespaces, it's bad for git diff, not perfect.
" Xcode can auto trailing whitespace, vim cannot, because sometime we indeed
" need a space at the end of a line.
"=============================================================================
command! JKTrimWhiteSpace execute "normal mx:%s/\\s\\+$//ge\<CR>`x"
command! JKShowWhiteSpace execute "normal mx:/\\s\\+$\<CR>`x"

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
        let s .= '   ' . (i + 1) .' %{MyTabLabel(' . (i + 1) . ')}   '
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
function! g:JK_RemoveSessionFile()
    let session_file = '~/.vim/session/' . substitute(getcwd(), '/', '\\%', 'g')
    let has_session = filereadable(expand(session_file))
    if has_session && argc() == 0
        echom "Remove session file: " . expand(session_file)
        exe "!rm " . session_file
    endif
endfunction


" MISC autocmd
"=============================================================================
augroup JMISC
    autocmd!
    autocmd VimEnter * nested call JK_LoadSessionFile()
augroup END


" Identify syntax highlight
" https://vim.fandom.com/wiki/Identify_the_syntax_highlighting_group_used_at_the_cursor
"=============================================================================
command! JKHighlight echo {l,c,n ->
        \   'hi<'    . synIDattr(synID(l, c, 1), n)             . '> '
        \  .'trans<' . synIDattr(synID(l, c, 0), n)             . '> '
        \  .'lo<'    . synIDattr(synIDtrans(synID(l, c, 1)), n) . '> '
        \ }(line("."), col("."), "name")


" VSplit a right window if needed.
"=============================================================================
function! g:JK_VSplitWindowIfNeeded()
    let oldw = winnr()
    silent! exe "normal! \<c-w>l"
    let neww = winnr()
    if oldw == neww
        vsp
    endif
endfunction
command! JKVSplitWindowIfNeeded call JK_VSplitWindowIfNeeded()


" Close all vSplit  right windows if needed.
"=============================================================================
function! g:JK_CloseVSplitWindowsIfNeeded()
    let oldw = winnr()
    while 1
        silent! exe "normal! \<c-w>l"
        let neww = winnr()
        if oldw == neww
            break
        else
            q
        endif
    endwhile
endfunction
command! JKCloseVSplitWindowsIfNeeded call JK_CloseVSplitWindowsIfNeeded()


" Check is most right bottom windows.
"=============================================================================
function! g:JKIsMostRightBottomWindow()
    let oldw = winnr()
    silent! exe "normal! \<c-w>l"
    silent! exe "normal! \<c-w>j"
    let neww = winnr()
    silent! exe oldw.'wincmd w'
    return oldw == neww
endfunction

" Hexmode
" https://vim.fandom.com/wiki/Improved_hex_editing
"=============================================================================
" ex command for toggling hex mode - define mapping if desired
command -bar Hexmode call ToggleHex()

" helper function to toggle hex mode
function ToggleHex()
    " hex mode should be considered a read-only operation
    " save values for modified and read-only for restoration later,
    " and clear the read-only flag for now
    let l:modified=&mod
    let l:oldreadonly=&readonly
    let &readonly=0
    let l:oldmodifiable=&modifiable
    let &modifiable=1
    if !exists("b:editHex") || !b:editHex
        " save old options
        let b:oldft=&ft
        let b:oldbin=&bin
        " set new options
        setlocal binary " make sure it overrides any textwidth, etc.
        silent :e " this will reload the file without trickeries 
        "(DOS line endings will be shown entirely )
        let &ft="xxd"
        " set status
        let b:editHex=1
        " switch to hex editor
        %!xxd
    else
        " restore old options
        let &ft=b:oldft
        if !b:oldbin
            setlocal nobinary
        endif
        " set status
        let b:editHex=0
        " return to normal editing
        %!xxd -r
    endif
    " restore values for modified and read only state
    let &mod=l:modified
    let &readonly=l:oldreadonly
    let &modifiable=l:oldmodifiable
endfunction

