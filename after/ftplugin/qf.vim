" ==============================================================================
" Preview file with quickfix error in a popup window
" File:         after/ftplugin/qf.vim
" Author:       bfrg <https://github.com/bfrg>
" Website:      https://github.com/bfrg/vim-qf-preview
" Last Change:  Aug 31, 2019
" License:      Same as Vim itself (see :h license)
" ==============================================================================

let s:save_cpo = &cpoptions
set cpoptions&vim

" Stop here if user doesn't want ftplugin mappings
if exists('g:no_plugin_maps')
    finish
endif

nnoremap <silent> <buffer> p :<c-u>call qfpreview#open(line('.')-1)<cr>

let b:undo_ftplugin = get(b:, 'undo_ftplugin', 'execute') . '| execute "nunmap <buffer> p"'

let &cpoptions = s:save_cpo