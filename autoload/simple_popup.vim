" autoload/simple_popup.vim

if v:version < 802
  finish
endif

" ==============================================================================
" Core Popup Logic
" ==============================================================================

function! simple_popup#filter(winid, key) abort
    if a:key ==# "j"
        call win_execute(a:winid, "normal! j")
    elseif a:key ==# "k"
        call win_execute(a:winid, "normal! k")
    elseif a:key ==# "\<c-d>"
        call win_execute(a:winid, "normal! \<c-d>")
    elseif a:key ==# "\<c-u>"
        call win_execute(a:winid, "normal! \<c-u>")
    elseif a:key ==# "\<c-f>"
        call win_execute(a:winid, "normal! \<c-f>")
    elseif a:key ==# "\<c-b>"
        call win_execute(a:winid, "normal! \<c-b>")
    elseif a:key ==# "\<space>"
        call win_execute(a:winid, "normal! \<c-f>")
    elseif a:key ==# "u"
        call win_execute(a:winid, "normal! \<c-b>")
    elseif a:key ==# "v"
        call win_execute(a:winid, "normal! v")
    elseif a:key ==# "V"
        call win_execute(a:winid, "normal! V")
    elseif a:key ==# "y"
        call win_execute(a:winid, "normal! y")
    elseif a:key ==# "G"
        call win_execute(a:winid, "normal! G")
    elseif a:key ==# "g"
        call win_execute(a:winid, "normal! gg")
    elseif a:key ==# 'q'
        call popup_close(a:winid)
    else
        return v:false
    endif
    return v:true
endfunction

function! simple_popup#open_ex_command(excommand, from_start) abort
  let pop_width = float2nr(&columns * 0.8)
  let pop_height = float2nr(&lines * 0.8)
  let lines = split(execute(a:excommand, 'silent'), '\n')
  let popup_config = #{
        \ scrollbar: 1,
        \ maxheight: pop_height,
        \ minheight: pop_height,
        \ maxwidth: pop_width,
        \ minwidth: pop_width,
        \ filter: 'simple_popup#filter'
        \ }

  let winid = popup_menu(lines, popup_config)

  if !a:from_start
    call win_execute(winid, 'normal! G')
    call win_execute(winid, 'normal! \<c-b>')
  endif
endfunction

function! simple_popup#open_system_command(command, from_start) abort
  let pop_width = float2nr(&columns * 0.8)
  let pop_height = float2nr(&lines * 0.8)

  let lines = split(system(a:command), '\n')
  let popup_config = #{
        \ scrollbar: 1,
        \ maxheight: pop_height,
        \ minheight: pop_height,
        \ maxwidth: pop_width,
        \ minwidth: pop_width,
        \ filter: 'simple_popup#filter'
        \ }

  let winid = popup_menu(lines, popup_config)

  if !a:from_start
    call win_execute(winid, 'normal! G')
    call win_execute(winid, 'normal! \<c-b>')
  endif
endfunction

" ==============================================================================
" Lists Logic (Jumplist, Changelist)
" ==============================================================================

function! simple_popup#go_jumplist(id, result) abort
  let target_dict = s:jump_info_list[a:result-1]
  execute target_dict['cmd']
  normal zz
endfunction

function! simple_popup#open_jumplist() abort
  let pop_width = float2nr(&columns * 0.8)
  let pop_height = float2nr(&lines * 0.8)
  let lines = split(execute('jumps', 'silent'), '\n')

  let s:jump_info_list = []
  for line in lines[1:] " Skip header
    let info_dict = {}
    let parts = split(line)
    if len(parts) < 3 | continue | endif
    let linenr = parts[1]
    let rest = parts[3:]
    let file_text = join(rest, ' ')

    if empty(findfile(file_text)) && bufnr(file_text) == -1
      continue
    endif

    let info_dict['text'] = line
    let info_dict['cmd'] = 'edit +' . linenr . ' ' . file_text
    call add(s:jump_info_list, info_dict)
  endfor

  let popup_config = #{
        \ scrollbar: 1,
        \ maxheight: pop_height,
        \ minheight: pop_height,
        \ maxwidth: pop_width,
        \ minwidth: pop_width,
        \ callback: 'simple_popup#go_jumplist'
        \ }

  let winid = popup_menu(s:jump_info_list, popup_config)

  call win_execute(winid, 'normal! G')
  call win_execute(winid, 'normal! \<c-b>')
endfunction

function! simple_popup#go_changelist(id, result) abort
  let target_dict = s:change_info_list[a:result-1]
  execute target_dict['cmd']
  normal zz
endfunction

function! simple_popup#open_changelist() abort
  let pop_width = float2nr(&columns * 0.8)
  let pop_height = float2nr(&lines * 0.8)
  let lines = split(execute('changes', 'silent'), '\n')
  let s:change_info_list = []
  for line in lines[1:] " Skip header
    let info_dict = {}
    let parts = split(line)
    if len(parts) < 3 | continue | endif
    let linenr = parts[1]

    let info_dict['text'] = line
    let info_dict['cmd'] = 'normal ' . linenr . 'G'
    call add(s:change_info_list, info_dict)
  endfor
  let popup_config = #{
        \ scrollbar: 1,
        \ maxheight: pop_height,
        \ minheight: pop_height,
        \ maxwidth: pop_width,
        \ minwidth: pop_width,
        \ callback: 'simple_popup#go_changelist'
        \ }

  let winid = popup_menu(s:change_info_list, popup_config)

  call win_execute(winid, 'normal! G')
  call win_execute(winid, 'normal! \<c-b>')
endfunction

" ==============================================================================
" Buffer Logic
" ==============================================================================

function! simple_popup#load_buffer(id, result) abort
  let target_buffer = s:buf_dict[a:result - 1]
  execute 'buffer! ' . target_buffer.bufnr
endfunction

function! simple_popup#buffer_menu(search_text = '') abort
  " show loaded buffers on popup menu and open selected buffer
  let s:buf_dict = map(filter(getbufinfo(), 'v:val.listed'), '#{
        \ bufnr: v:val.bufnr,
        \ text: fnamemodify(expand(v:val.name), ":.:~")
        \ }')

  if len(a:search_text)
    " filter buf_dict text with search_text
    call filter(s:buf_dict, 'v:val.text =~ a:search_text')
    if len(s:buf_dict) == 0
      let popup_config = #{
      \   time: 3000,
      \   cursorline: 0,
      \   highlight: 'WarningMsg'
      \ }
      let empty_msg = 'there is no buffer with name matching ' . a:search_text
      call popup_menu(empty_msg, popup_config)
      return
    endif
  endif

  let popup_config = #{
  \   callback: 'simple_popup#load_buffer'
  \ }
  call popup_menu(s:buf_dict, popup_config)
endfunction

function! simple_popup#buffer_tabline() abort
  let curBuf = bufnr('%')
  let bufNameList = []

  for buf in filter(getbufinfo(), 'v:val.listed')
    let bufName = ''
    if buf.name == ''
      let bufName = '[No Name]'
    else
      let bufName = fnamemodify(expand(buf.name), ':.:t')
    endif
    if buf.changed == 1
      let bufName = bufName .. ' +'
    endif
    if buf.bufnr == curBuf
      let bufName = '< ' .. bufName .. ' >'
    endif
    call add(bufNameList, bufName)
  endfor

  let bufNameStr = join(bufNameList, ' | ')
  return bufNameStr
endfunction

" ==============================================================================
" Search Logic
" ==============================================================================

function! simple_popup#go_selected_file(id, result) abort
  let target_dict = s:search_info_list[a:result-1]
  execute target_dict['cmd']
  normal zz
endfunction

function! simple_popup#search_across_files(search_text) abort
  let grep_result = system('grep -Irn ' . shellescape(a:search_text))
  let search_results = split(grep_result, '\n')
  let s:search_info_list = []
  for search_result in search_results
    let info_dict = {}
    let length = len(search_result)
    " Find the second colon to separate file:line:text
    let index = match(search_result, ":", 0, 2)
    if index == -1 | continue | endif

    let file_info = search_result[:index-1]
    let parts = split(file_info, ':')
    let filename = parts[0]
    let linenumber = parts[1]

    let cmd = 'edit +' . linenumber . ' ' . filename
    let info_dict['cmd'] = cmd
    let info_dict['text'] = search_result
    call add(s:search_info_list, info_dict)
  endfor

  let popup_config = #{
        \ callback: 'simple_popup#go_selected_file',
        \ scrollbar: 1,
        \ maxheight: 20
        \ }

  call popup_menu(s:search_info_list, popup_config)
endfunction
