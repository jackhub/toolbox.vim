" Modified: hujie.code@gmail.com
" Description:	An easy way to use xcodebuild with Vim
" Author: Jerry Marino <@jerrymarino>
" License: Vim license
" Version .45

let s:project = '' 
let s:target = ''
let s:buildConfig = ''
let s:scheme = ''
let s:destination = ''
let s:sdk = ''
let s:projects = []
let s:targets = []
let s:buildConfigs = []
let s:schemes = []
let s:destinations = []
let s:sdks = []
let s:noProjectError = 'Missing .xcodeproj'
let s:xcodeproj_info_file = '.xcm'
let s:isInit = 0

" Open config file.
nn <leader>xc :call g:XCB_OpenXCM()<cr>
autocmd BufWritePost .xcm call g:XCB_Update() | checktime

fun g:XCB_Update()
    call g:XCB_GenerateOrUpdateBuildInfoIfNeeded()

    if s:projectIsValid() && !s:isInit
        let s:isInit = 1
        call s:initSettings()
    endif
endf

fun s:projectIsValid()
    if !empty(s:project)
        return 1
    endif
    return 0
endf

func s:initSettings()
    set errorformat=
                \%f:%l:%c:{%*[^}]}:\ error:\ %m,
                \%f:%l:%c:{%*[^}]}:\ fatal\ error:\ %m,
                \%f:%l:%c:{%*[^}]}:\ warning:\ %m,
                \%f:%l:%c:\ error:\ %m,
                \%f:%l:%c:\ fatal\ error:\ %m,
                \%f:%l:%c:\ warning:\ %m,
                \%f:%l:\ Error:\ %m,
                \%f:%l:\ error:\ %m,
                \%f:%l:\ fatal\ error:\ %m,
                \%f:%l:\ warning:\ %m

    " Build current target
    nn `_b :wa!<cr>:call g:XCB_Build()<cr> 
    " Clean current target
    nn `_K :call g:XCB_Clean()<cr> 
    " Open xcode with current project
    nn <space>x :wa!<cr>:call g:XCB_OpenXCode()<cr>

    " Show build command 
    nn <leader>xi :call g:XCB_BuildCommandInfo()<cr> 
    " Generate compile_commands
    nn <leader>xg :call g:XCB_GenerateCompileCommands()<cr>:CocRestart<cr>
endf

fun g:XCB_OpenXCM()
    let flag = filereadable(getcwd()."/".".xcm")
    if flag
        sp .xcm
    else
        call writefile(["Projects:"], ".xcm")
        sp .xcm
    endif
endf

func s:isWorkSpace()
    let wkEx = 'workspace'
    if match(s:project, wkEx) > 0
        return 1
    else
        return 0
    endif
endf

fun g:XCB_GenerateOrUpdateBuildInfoIfNeeded()
    let s:project = s:findProjectFileName()
    let has_info_file = filereadable(getcwd()."/".s:xcodeproj_info_file)
    " No xcoderoject found and no project setting.
    if empty(s:project) && !has_info_file
        return 
    endif

    " Found xcodeproj in current dir, add xcode build info file.
    if !has_info_file
        call system("touch ".s:xcodeproj_info_file)
    endif

    call g:XCB_UpdateXCConfig()

    " No scheme found need generate.
    if !len(s:scheme)
        " Clear cached info.
        let s:targets = []
        let s:buildConfigs = []
        let s:schemes = []
        let s:destinations = []
        let s:sdks = []

        if s:isWorkSpace()
            let outputList = split(system("xcodebuild -list -workspace ".s:project), '\n')
        else
            let outputList = split(system("xcodebuild -list -project ".s:project), '\n')
        endif
        let configTypeEx = '[^ :0-9"][a-zA-Z ]*:'
        let typeSettingEx = '[^ ]\(\w\|[-_]\)\+$'

        let configVarToTitleDict = {'Build Configurations:' : s:buildConfigs, 'Targets:' : s:targets, 'Schemes:' : s:schemes}
        let configVar = []
        for line in outputList 
            if match(line, configTypeEx) > 1
                let typeTitle = matchstr(line, configTypeEx)
                if has_key(configVarToTitleDict, typeTitle)  	
                    let configVar = get(configVarToTitleDict, typeTitle, 'default') 
                endif
            elseif match(line, typeSettingEx) > 1 
                let typeSetting = matchstr(line, typeSettingEx)
                if strlen(typeSetting) > 1
                    call add(configVar, typeSetting)
                endif
            endif
        endfor

        " Default select first one, write configuration to file.
        let s:schemes[0] = '* '.s:schemes[0]

        let write_items = ['Destinations:', '"platform=iOS,name=jack’s iPhone"', '"platform=iOS Simulator,name=iPhone 12"', '',
                    \ 'SDKs:', 'iphoneos', 'iphonesimulator', 'macosx']

        call extend(write_items, ['', 'Build Configurations:'])
        call extend(write_items, s:buildConfigs)

        call extend(write_items, ['', 'Targets:'])
        call extend(write_items, s:targets)

        call extend(write_items, ['', 'Schemes:'])
        call extend(write_items, s:schemes)

        call writefile(write_items, s:xcodeproj_info_file, "a")
    endif
endf

fun g:XCB_UpdateXCConfig()
    " Clear cached info.
    let s:target = ''
    let s:buildConfig = ''
    let s:scheme = ''
    let s:destination = ''
    let s:sdk = ''

    let outputList = split(system("cat ".s:xcodeproj_info_file), '\n')

    let configTypeEx = '[a-zA-Z ]*:'
    let typeSettingEx = '^* .*'

    let configVarToTitleDict = {'Projects:' : s:projects, 'SDKs:' : s:sdks, 'Build Configurations:' : s:buildConfigs,
                \ 'Targets:' : s:targets, 'Schemes:' : s:schemes}

    for line in outputList 
        if match(line, configTypeEx) == 0
            let typeTitle = matchstr(line, configTypeEx)
        elseif match(line, typeSettingEx) == 0 
            let typeSetting = matchstr(line, typeSettingEx)
            if strlen(typeSetting) > 1
                if typeTitle == 'Projects:'
                    let s:project = typeSetting[2:]
                elseif typeTitle == 'SDKs:'
                    let s:sdk = typeSetting[2:]
                elseif typeTitle == 'Destinations:'
                    let s:destination = typeSetting[2:]
                elseif typeTitle == 'Build Configurations:'
                    let s:buildConfig = typeSetting[2:]
                elseif typeTitle == 'Targets:'
                    let s:target = typeSetting[2:]
                elseif typeTitle == 'Schemes:'
                    let s:scheme = typeSetting[2:]
                endif
            endif
        endif
    endfor
endf

fun s:XcodeCommandWithTarget(target)
    let cmd = "xcodebuild"
    if(!empty(s:sdk))
        let cmd .= " -sdk " . s:sdk
    endif
    if(!empty(s:destination))
        let cmd .= " -destination " . s:destination
    endif
    if(!empty(s:buildConfig))
        let cmd .= " -configuration " . s:buildConfig
    endif
    if(!empty(s:scheme))
        let cmd .= " -scheme " . s:scheme
    endif
    if (!empty(s:project))
        if s:isWorkSpace()
            let cmd .= " -workspace " . s:project
        else
            let cmd .= " -project " . s:project
        endif
    endif
    return cmd
endf

fun g:XCB_Build()
    if !s:projectIsValid()	
        echoerr s:noProjectError
        return
    endif
    call s:asyncRunBuildCommand(s:XcodeCommandWithTarget(s:target) . ' build')
endf

fun g:XCB_Clean()
    if !s:projectIsValid()	
        echoerr s:noProjectError
        return
    endif
    call s:asyncRunBuildCommand(s:XcodeCommandWithTarget(s:target) . ' clean')
endf

fun g:XCB_BuildCommandInfo()
    if !s:projectIsValid()	
        echoerr s:noProjectError
        return
    endif
    echo s:XcodeCommandWithTarget(s:target) . ' build'
endf	

fun s:findProjectFileName()
    let s:projectFile = globpath(expand('.'), '*.xcodeproj')
    if (empty(s:projectFile))
        let s:projectFile = globpath(expand('.'), '*.xcworkspace')
    endif

    return s:projectFile
endf

fun g:XCB_GenerateCompileCommands()
    if !s:projectIsValid()	
        return
    endif

    " if !filereadable(getcwd()."/compile_commands.json")
    " Clean first, needed for objc/objcpp header files. Maybe try later.
    exec "!" . s:XcodeCommandWithTarget(s:target) . ' clean'
    let build_cmd = s:XcodeCommandWithTarget(s:target) . ' build | xcpretty -r json-compilation-database --output compile_commands.json'
    call system(build_cmd)
    "
    " clangd not support modules, disable it. It sames clangd 13 fix this
    " problem, comment this right now.
    " -e "s/[^ ]*[gf]modules[^ ]*//g"
    "
    call system('gsed -e "s/-index-store-path [^ ]*//g" -i compile_commands.json')
    " end
endf

fun s:asyncRunBuildCommand(cmd)
    exec "AsyncRun " . a:cmd 
endf

fun g:XCB_OpenXCode()
    call system("open ". s:project)
endf

call g:XCB_Update()
