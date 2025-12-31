" plugin/simple_popup.vim

if exists('g:loaded_simple_popup')
  finish
endif
let g:loaded_simple_popup = 1

" --- Popup Commands ---
command! -nargs=1 -complete=command PopupEx call simple_popup#open_ex_command(<q-args>, v:true)
command! -nargs=1 -complete=command PopupExTail call simple_popup#open_ex_command(<q-args>, v:false)
command! -nargs=1 -complete=shellcmd PopupSystem call simple_popup#open_system_command(<q-args>, v:true)

" --- List Commands ---
command! PopupJumps call simple_popup#open_jumplist()
command! PopupChanges call simple_popup#open_changelist()

" --- Buffer Commands ---
command! -nargs=? BufferMenu call simple_popup#buffer_menu(<f-args>)

" --- Search Commands ---
command! -nargs=1 SearchAcrossFiles call simple_popup#search_across_files(<f-args>)

