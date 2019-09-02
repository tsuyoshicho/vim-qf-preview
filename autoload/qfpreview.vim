" ==============================================================================
" Preview file with quickfix error in a popup window
" File:         autoload/qfpreview.vim
" Author:       bfrg <https://github.com/bfrg>
" Website:      https://github.com/bfrg/vim-qf-preview
" Last Change:  Sep 2, 2019
" License:      Same as Vim itself (see :h license)
" ==============================================================================

scriptencoding utf-8

let s:save_cpo = &cpoptions
set cpoptions&vim

" Default options
let s:defaults = #{
        \ height: 15,
        \ title: v:true,
        \ scrollbar: v:true,
        \ mapping: v:false
        \ }

function! s:get(key) abort
    return get(b:, 'qfpreview', s:defaults)->has_key(a:key)
            \ ? get(b:, 'qfpreview', s:defaults)[a:key]
            \ : s:defaults[a:key]
endfunction

function! s:popup_filter(winid, key) abort
    if a:key ==# "\<c-k>"
        let firstline = popup_getoptions(a:winid).firstline
        let newline = (firstline - 2) > 0 ? (firstline - 2) : 1
        call popup_setoptions(a:winid, #{firstline: newline})
        return v:true
    elseif a:key ==# "\<c-j>"
        let firstline = popup_getoptions(a:winid).firstline
        call win_execute(a:winid, 'let g:nlines = line("$")')
        let newline = firstline < g:nlines ? (firstline + 2) : g:nlines
        unlet g:nlines
        call popup_setoptions(a:winid, #{firstline: newline})
        return v:true
    elseif a:key ==# 'g'
        call popup_setoptions(a:winid, #{firstline: 1})
        return v:true
    elseif a:key ==# 'G'
        let height = popup_getpos(a:winid).core_height
        call win_execute(a:winid, 'let g:nlines = line("$")')
        call popup_setoptions(a:winid, #{firstline: g:nlines - height + 1})
        unlet g:nlines
        return v:true
    elseif a:key ==# 'x' || a:key ==# "\<esc>"
        call popup_close(a:winid)
        return v:true
    endif
    return v:false
endfunction

function! qfpreview#open(idx) abort
    let wininfo = getwininfo(win_getid())[0]
    let qflist = wininfo.loclist ? getloclist(0) : getqflist()
    let qfitem = qflist[a:idx]

    let freespace = &lines - &cmdheight - wininfo.height - 3
    let height = freespace > s:get('height') ? s:get('height') : freespace

    hi def link QfPreview Pmenu

    silent let winid = popup_create(qfitem.bufnr, #{
            \ hidden: 1,
            \ line: wininfo.winrow - 1,
            \ col: wininfo.wincol,
            \ pos: 'botleft',
            \ minheight: height,
            \ maxheight: height,
            \ minwidth: wininfo.width - 2,
            \ maxwidth: wininfo.width - 2,
            \ padding: [1],
            \ firstline: qfitem.lnum,
            \ moved: 'any',
            \ mapping: s:get('mapping'),
            \ filter: function('s:popup_filter'),
            \ highlight: 'QfPreview',
            \ scrollbar: 0
            \ })

    if s:get('scrollbar')
        hi def link QfPreviewScrollbar PmenuSbar
        hi def link QfPreviewThumb PmenuThumb

        call popup_setoptions(winid, #{
                \ scrollbar: 1,
                \ scrollbarhighlight: 'QfPreviewScrollbar',
                \ thumbhighlight: 'QfPreviewThumb'
                \ })

        " Make sure popup window always has same width as quickfix window
        if popup_getpos(winid).scrollbar
            call popup_setoptions(winid, #{
                    \ minwidth: wininfo.width - 3,
                    \ maxwidth: wininfo.width - 3
                    \ })
        endif
    endif

    if s:get('title')
        hi def link QfPreviewTitle Pmenu
        let title = printf('%s (%d/%d)', bufname(qfitem.bufnr), a:idx+1, len(qflist))

        " Truncate long titles
        if len(title) > wininfo.width
            let width = wininfo.width - 4
            let title = '…' . title[-width:]
        endif

        call popup_setoptions(winid, #{
                \ title: title,
                \ close: 'button',
                \ padding: [0,1,1,1],
                \ border: [1,0,0,0],
                \ borderchars: [' '],
                \ borderhighlight: ['QfPreviewTitle'],
                \ })
    endif

    if !has('patch-8.1.1919')
        call setwinvar(winid, '&number', 0)
        call setwinvar(winid, '&relativenumber', 0)
        call setwinvar(winid, '&cursorline', 0)
        call setwinvar(winid, '&signcolumn', 'no')
        call setwinvar(winid, '&cursorcolumn', 0)
        call setwinvar(winid, '&foldcolumn' 0)
        call setwinvar(winid, '&colorcolumn', '')
        call setwinvar(winid, '&list', 0)
        call setwinvar(winid, '&scrolloff', 0)
    endif

    call popup_show(winid)
endfunction

let &cpoptions = s:save_cpo
