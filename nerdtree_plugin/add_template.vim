" add_template.vim
" Created by jackjhu on 25/01/2022.
" Copyright © 2022 Tencent. All rights reserved.
" Description   : Add file with template.

if exists("s:loaded")
    finish
endif
let s:loaded = 1

" Reference: nerdtree/nerdtree_plugin/fs_menu.vim
function NewFileWithTemplate()
    let curDirNode = g:NERDTreeDirNode.GetSelected()
    redraw! " Clear the menu
    let newNodeName = substitute(input('New File: ', curDirNode.path.str() . nerdtree#slash(), 'file'), '\(^\s*\|\s*$\)', '', 'g')

    if newNodeName ==# ''
        call nerdtree#echo('Node Creation Aborted.')
        return
    endif

    q
    execute "edit " . newNodeName
    silent w

endfunction

call NERDTreeAddMenuItem({'text': '(n)ew with template', 'shortcut': 'n', 'callback': 'NewFileWithTemplate'})
