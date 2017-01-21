let g:RegexShortcuts = {129: '.*', 130: '.+', 131: '.\{-}', 132: '[^', 133: '\ze', 135: '\{-}', 147: '\zs'}

function! GetRegex(slashCount)
  let c = getchar()
  let command = ""
  let slashes_seen = 0

  while c != 13 && c != 255
    if nr2char(c) == "/"
      let slashes_seen += 1
      if slashes_seen == a:slashCount
        break
      endif
    endif

    if nr2char(c) == "\\"
      let command .= "\\".nr2char(getchar())
    elseif has_key(g:RegexShortcuts, c)
      let command .= g:RegexShortcuts[c]
    elseif c > 128
      let command .= "\\".nr2char(c - 128)
    else
      let command .= nr2char(c)
    endif
    let c = getchar()
  endwhile

  return [command, slashes_seen]
endfunction

function! Search(com, count, mode)
  let search = GetRegex(0)[0]
  let visual = a:mode == 'x' ? 'gv' : ''

  if a:count
    call feedkeys(l:visual.a:count.a:com.l:search."\<CR>", "in")
  endif
endfunction

nnoremap / :<C-u>call Search("/", v:count1, "n")<CR>
nnoremap ? :<C-u>call Search("?", v:count1, "n")<CR>
nnoremap 0/ :<C-u>call Search("/", 0, "n")<CR>
nnoremap 0? :<C-u>call Search("?", 0, "n")<CR>
xnoremap / :<C-u>call Search("/", v:count1, "x")<CR>
xnoremap ? :<C-u>call Search("?", v:count1, "x")<CR>
xnoremap 0/ :<C-u>call Search("/", 0, "x")<CR>
xnoremap 0? :<C-u>call Search("?", 0, "x")<CR>

function! Substitute(com, global, mode)
  let info = GetRegex(3)
  let command = info[0]
  let slashes = info[1]
  
  while slashes < 2
    let command .= '/'
    let slashes += 1
  endwhile

  if a:global
    let command .= 'g'
  endif

  echo a:com.command

  call feedkeys(a:com.command."\<CR>", "in")
endfunction

nnoremap ó :<C-u>call Substitute(":s/", 0, 'n')<CR>
nnoremap Ó :<C-u>call Substitute(":s/", 1, 'n')<CR>
nnoremap í :<C-u>call Substitute(":%s/", 0, 'n')<CR>
nnoremap Í :<C-u>call Substitute(":%s/", 1, 'n')<CR>
xnoremap ó :<C-u>call Substitute(":'<,'>s/\%V", 0, 'x')<CR>
xnoremap Ó :<C-u>call Substitute(":'<,'>s/\%V", 1, 'x')<CR>
xnoremap í :<C-u>call Substitute(":'<,'>s/", 0, 'x')<CR>
xnoremap Í :<C-u>call Substitute(":'<,'>s/", 1, 'x')<CR>

function! Global(com)
  let c = getchar()
  let command = ""

  while c != char2nr('/')
    if nr2char(c) == "\\"
      let command .= "\\".nr2char(getchar())
    elseif has_key(g:RegexShortcuts, c)
      let command .= g:RegexShortcuts[c]
    elseif c == 255
      "If we get here, there's no point trying to parse the rest of the
      "command. Bail right now!
      return 0
    elseif c > 128
      let command .= "\\".nr2char(c - 128)
    else
      let command .= nr2char(c)
    endif
    let c = getchar()
  endwhile

  let command .= "/norm "

  let c = getchar()
  while c != 13 && c != 255
    let command .= nr2char(c)
    let c = getchar()
  endwhile

  let command .= nr2char(255)

  call feedkeys(a:com.command."\<CR>", "in")
endfunction

nnoremap ç :<C-u>call Global(":g/")<CR>
nnoremap Ç :<C-u>call Global(":g!/")<CR>
