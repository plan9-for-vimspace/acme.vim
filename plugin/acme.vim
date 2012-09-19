"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" acme.vim
"
" acme-like mouse actions for vim.
"

" we must know how much space a single character needs.  these variables have
" to be changed so they match vim's cell geometry (can change for different
" fonts). these values work for Ubuntu Mono at 9pt at 96dpi, using ubuntu
" freetype. 
let g:cell_height = 12 
let g:cell_width = 6

" the height of the gui menu + foolbar, if any
let g:gui_offset = 0

" this only works reliably when there is only one window open, for now
function! MoveMouse(line, column)
	let l:numbers_offset = &number * (&numberwidth * g:cell_width) 
	let l:fdc_offset = &fdc * g:cell_width
	let l:x = l:fdc_offset + l:numbers_offset + (a:column * g:cell_width)
	let l:view_offset = (line("w0")- 1) * g:cell_height
	let l:y = g:gui_offset + (a:line * g:cell_height - l:view_offset)
	call system("xdotool search --name " . v:servername . " mousemove --window %1 " . l:x . " " . l:y . " click 1")
endfunction

function! EscapeForBang(text)
	return substitute(a:text, "!", "\\\\!", "g")
endfunction

function! Exec(text)
	botright new
	exec "0read !" . EscapeForBang(a:text)
	setlocal buftype=nofile
endfunction

function! B2(text)
	if executable(split(a:text)[0])
		call Exec(a:text)
	endif
endfunction

function! NB2(text)
	if executable(a:text)
		call Exec(a:text)
	else
		if a:text[0] == "|"
		elseif a:text[0] == "<"
		elseif a:text[0] == ">"
			call Exec("echo '".getreg("*"). "' | ". a:text[1:])
		endif
	endif
endfunction

function! B3(text)
	let l:move_mouse = 1
	let f_data = split(a:text, ":")
	let filename = f_data[0]
	if filereadable(filename)
		if !buffer_exists(filename)
			exe "botright split ".filename
			" it isn't safe to move the mouse, because we will have an offset
			let l:move_mouse = 0 
		else
			exe "buffer ".filename
		endif
		if len(f_data) > 1
			let address = f_data[1]
			if address[0] == "#"
				let a_char = address[1:]
				exe "go ". a_char
			elseif address[0] == "$"
				exe "normal G$"
			elseif address[0] == "/"
				exe "normal gg"
				exe address
			elseif address[0] == "?"
				exe "normal G"
				exe address
			else
				let range = split(address, ",")
				let a_line = range[0]
				exe "normal ". a_line . "G"
				if len(range) > 1
					" use :go so blanks don't mess the address
					let offset = line2byte(a_line) -1
					let a_char = offset + range[1]
					exe "go ".a_char
				endif
			endif
		endif
	else
		" search forward
		exe "silent normal *"
	endif
	if l:move_mouse == 1
		let l:line = line(".")
		let l:col = virtcol(".")
		call MoveMouse(l:line, l:col)
	endif
endfunction

" change B2 for NB2 here for <|> support (not yet complete)
nnoremap <silent> <MiddleMouse> <LeftMouse>:call B2(expand('<cWORD>'))<cr>
nnoremap <silent> <RightMouse> <LeftMouse>:call B3(expand('<cWORD>'))<cr>
vnoremap <silent> <MiddleMouse> :call B2(getreg("*"))<cr>
vnoremap <silent> <RightMouse> :call B3(getreg("*"))<cr>

" acme.vim:13
" acme.vim:#24
" acme.vim:35,5 
" acme.vim:/function/ goes to the definition of Mousemove
" acme.vim:?MoveMouse? goes to this line
" acme.vim:$
" /etc/fstab:2,3
" ls
" grep -nr function! acme.vim
" >cat
