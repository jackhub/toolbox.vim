"
" Modified: hujie.code@gmail.com
" Description:	An easy way to use cmake build with Vim
"

let s:project = '' 
let s:buildConfigs = ''
let s:isInit = 0

" autocmd ccf file updated.
autocmd BufWritePost .ccf call g:CMD_TryUpdate() | checktime

" Open config file.
nnoremap <leader>cc :call g:CMB_OpenConfigFile()<cr>

fun g:CMB_OpenConfigFile()
    let flag = filereadable(getcwd()."/".".ccf")
    if flag
        sp .ccf
    else
        call writefile(["Projects:", ".", ""], ".ccf")
        call writefile(["Build Defines:"], ".ccf", "a")
        sp .ccf
    endif
endf

fun g:CMD_TryUpdate()
    let flag = filereadable(getcwd()."/".".ccf")
    if flag && !s:isInit
        let s:isInit = 1
        call s:initSettings()
        call g:CMB_UpdateConfig()
    endif
endf

func s:initSettings()
    " Build
    nnoremap `_b :wa!<cr>:call g:CMB_Build()<cr> 
    inoremap `_b <ESC>:wa!<cr>:call g:CMB_Build()<cr> 
    tnoremap `_b <c-\><c-n>:wa!<cr>:call g:CMB_Build()<cr> 
    " Clean
    nnoremap `_K :call g:CMB_Clean()<cr> 
    inoremap `_K <ESC>:call g:CMB_Clean()<cr> 
    tnoremap `_K <c-\><c-n>:call g:CMB_Clean()<cr> 
endf

fun g:CMB_UpdateConfig()
    " Clear cached info.
    let s:project = ''
    let s:buildConfigs = ''

    let outputList = split(system("cat .ccf"), '\n')

    let configTypeEx = '[a-zA-Z ]*:'
    let typeSettingEx = '.*'

    for line in outputList 
        if match(line, configTypeEx) == 0
            let typeTitle = matchstr(line, configTypeEx)
        elseif match(line, typeSettingEx) == 0 
            let typeSetting = matchstr(line, typeSettingEx)
            if strlen(typeSetting) > 1
                if typeTitle == 'Projects:'
                    let s:project = typeSetting
                elseif typeTitle == 'Build Defines:'
                    let s:buildConfigs .= ' -D' . typeSetting
                endif
            endif
        endif
    endfor
endf

fun g:CMakeBuildCommand()
    let cmd = "cmake"
    if(!empty(s:project))
        let cmd .= " -S" . s:project
    endif
    let cmd .= " -B.build "
    if(!empty(s:buildConfigs))
        let cmd .= s:buildConfigs
    endif
    let cmd .= " && cmake --build .build"
    return cmd
endf

fun g:CMB_Build()
    call JK_ToggleTerminal()
    call feedkeys(g:CMakeBuildCommand() . "\<CR>")  
endf

fun g:CMB_Clean()
    call JK_ToggleTerminal()
    call feedkeys("rm -rf .build/*\<CR>")  
endf

" Init.
call g:CMD_TryUpdate()
