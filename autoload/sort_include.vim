let s:save_cpo = &cpo
set cpo&vim

function! sort_include#sort() abort
  let start = 0
  let lines = []
  let last_include_type = ''
  for i in range(1, line('$'))
    let line = getline(i)
    if line =~# '^#\s*include\s*<.*>'
      if start > 0 && last_include_type == 'quote'
        call s:sort(start, lines)
        let start = 0
        let lines = []
      endif
      call add(lines, line)
      if start == 0
        let start = i
      endif
      let last_include_type = 'system'
    elseif line =~# '^#\s*include\s*".*"'
      if start > 0 && last_include_type == 'system'
        call s:sort(start, lines)
        let start = 0
        let lines = []
      endif
      call add(lines, line)
      if start == 0
        let start = i
      endif
      let last_include_type = 'quote'
    elseif start > 0
      call s:sort(start, lines)
      let start = 0
      let lines = []
    endif
  endfor
  if start != 0
    call s:sort(start, lines)
  endif
endfunction

function! s:sorter(lhs, rhs) abort
  let pattern = '\v^\s*#\s*include\s*[<"]([^>"]+)[>"].*$'
  let l = substitute(a:lhs, pattern, '\1', 'g')
  let r = substitute(a:rhs, pattern, '\1', 'g')

  return l > r ? 1 : -1
endfunction

function! s:sort(start, lines) abort
  if a:start > 0 && len(a:lines) > 1
    let sorted = sort(deepcopy(a:lines), 's:sorter')
    if a:lines !=# sorted
      call setline(a:start, sorted)
    endif
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
