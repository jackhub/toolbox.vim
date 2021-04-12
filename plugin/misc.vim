" Easy global search and replace.
"=============================================================================
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

    let @/ = @@
    let @@ = saved_unnamed_register
endfunction
cab cf cfdo %s//

" Quickfix up and down
" default use leaderf quickfix, unless there is a vim buildin quickfix.
"=============================================================================
function g:JK_QuickfixDown()
    let preBufwinnr = bufwinnr("%")
    execute "normal \<c-w>b"
    if preBufwinnr == bufwinnr("%")
        Leaderf quickfix --next
    else
        let bufType = getbufvar("%", "&filetype")
        execute "normal \<c-w>p"
        if bufType == "qf"
            cn
        else
            Leaderf quickfix --next
        endif
    endif
endfunction

function g:JK_QuickfixUp()
    let preBufwinnr = bufwinnr("%")
    execute "normal \<c-w>b"
    if preBufwinnr == bufwinnr("%")
        Leaderf quickfix --previous
    else
        let bufType = getbufvar("%", "&filetype")
        execute "normal \<c-w>p"
        if bufType == "qf"
            cp
        else
            Leaderf quickfix --previous
        endif
    endif
endfunction

" ToggleTerminal
"=============================================================================
let s:termBuf = 0
function! g:JK_ToggleTerminal() 
    if !s:termBuf
        execute "normal \<c-w>b:22sp term://zsh\<CR>:set filetype=term\<CR>i"
        let s:termBuf = bufnr("%")
        echom "Create a new term buffer, number: " . s:termBuf
        execute "normal :set nornu\<cr>:set nonu\<cr>"
        return
    endif
    execute "normal \<c-w>b"
    let termBuf = bufnr("%")
    if termBuf == s:termBuf
        execute "normal :q\<CR>\<C-W>p"
    else
        execute "normal :22sp\<CR>:buf " . s:termBuf . " \<CR>i"
    endif
endfunction

" ToggleWindowHeight
"=============================================================================
let s:recordWinHeight = 0
function! g:JK_ToggleMaxWindow()
    let curWinHeight = winheight(0)
    if curWinHeight > 50
        execute "normal " .s:recordWinHeight ."\<c-w>_"
    else
        let s:recordWinHeight = curWinHeight
        execute "normal \<c-w>_"
    endif
endfunction

" NeadTree mapping
"=============================================================================
function! s:CustomNeadTreeMapping()
    if exists("g:loaded_nerdtree_custom_maps")
        return
    endif
    let g:loaded_nerdtree_custom_maps = 1

    call NERDTreeAddKeyMap({
                \ 'scope': 'Node',
                \ 'key': '<C-J>',
                \ 'override': '1',
                \ 'callback': 'NERDTreeCustomJumpDown',
                \ 'quickhelpText': 'quick jump down' })

    call NERDTreeAddKeyMap({
                \ 'scope': 'Node',
                \ 'key': '<C-K>',
                \ 'override': '1',
                \ 'callback': 'NERDTreeCustomJumpUp',
                \ 'quickhelpText': 'quick jump up' })

endfunction
function! NERDTreeCustomJumpDown(fnode)
    normal 9j
endfunction
function! NERDTreeCustomJumpUp(fnode)
    normal 9k
endfunction
call s:CustomNeadTreeMapping()


