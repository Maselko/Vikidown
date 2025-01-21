function! Vikidown_Viki2Md()
    if &filetype ==# 'vimwiki'
	" Get the path of the current Vimwiki file
    	let vimwiki_file = expand('%')

    	" Read the Vimwiki file into a Vim buffer
    	let vimwiki_buffer = readfile(vimwiki_file)

    	" Convert Vimwiki syntax to Markdown syntax
    	let markdown_buffer = []
    	" Line by line substitution
    	for line in vimwiki_buffer
	    try
    	        " header substitution
	        let line = substitute(line, '^=\s\+\(.*\)\s\+=$', '# \1', 'g')
    	        let line = substitute(line, '^==\s\+\(.*\)\s\+==$', '## \1', 'g')
    	        let line = substitute(line, '^===\s\+\(.*\)\s\+===$', '### \1', 'g')
    	        let line = substitute(line, '^====\s\+\(.*\)\s\+====$','#### \1', 'g')
    	        let line = substitute(line, '^=====\s\+\(.*\)\s\+=====$', '##### \1','g')
    	        let line = substitute(line, '^======\s\+\(.*\)\s\+=====$', '###### \1','g')

	        " code block substitution
	        let line = substitute(line, '^{{{\(.*\)$', '```\1','g')
	        let line = substitute(line, '^}}}$', '```','g')

	        " weblink substitution
	        let line = substitute(line, '\[\[https:\([^]]*\)|\([^]]*\)\]\]', '[\2](https:\1)','g')
	        " filelink substitution
	        let line = substitute(line, '\[\[file:\/\([^]]*\)|\([^]]*\)\]\]', '[\2](./\1)','g')
	        " URLlink substitution
	        let line = substitute(line, '\[\[URL\/\([^]]*\)|\([^]]*\)\]\]', '[\2](./\1)','g')
	        " imagelink substitution
	        let line = substitute(line, '\[\[images\/\([^]]*\)|\([^]]*\)\]\]', '![\2!](./\1)','g')
	        " link substitution needs to be after weblink substitution
	        let line = substitute(line, '\[\[\([^]]*\)|\([^]]*\)\]\]', '[\2](./\1.md)','g')
	        " wikilink substitution needs to be after link substitution
	        let line = substitute(line, '\[\[\([^]]*\)\]\]', '[\1](./\1.md)','g')
    	    catch
    	    endtry
	    " Add the converted line to the Markdown buffer
	    call add(markdown_buffer, line)
	endfor

	" global substitution

    	try
    	    let line = substitute(line, '^}}}$', '```','g')
    	catch
    	endtry

    	" Write the Markdown buffer to a new file with the same name as the Vimwiki file but with a .md extension
    	let markdown_file = substitute(vimwiki_file, '\v\.wiki$', '.md', '')
    	call writefile(markdown_buffer, markdown_file)

    	" Open the converted Markdown file
    	execute 'edit ' . markdown_file
    else
	echom "ERROR: " . expand('%') . " does not have markdown(.md) extension or syntax."
    endif

endfunction


function! Vikidown_Viki2MdAll()
    " Get the path of the current Vimwiki file
    let current_file = expand('%')

    " Get the directory path of the current Vimwiki file
    let directory = expand('%:p:h')

    " Get a list of all Vimwiki files in the directory
    let files = glob(directory . '/*.wiki')

    " Loop through each file
    for file in files
        " Skip the current file
        if file ==# current_file
            continue
        endif

        " Set the current buffer to the file
        execute 'edit ' . file

        " Convert Vimwiki to Markdown
        call Vikidown_Viki2Md()
    endfor
endfunction


function! Vikidown_Md2Viki()
    if &filetype ==# 'Markdown'
	let markdown_file = expand('%')

    	" Read the Markdown file into a Vim buffer
    	let markdown_buffer = readfile(markdown_file)

    	" Convert Markdown syntax to Vimwiki syntax
    	let vimwiki_buffer = []
	for line in markdown_buffer
	    try
    	        " header replacements
    	        let line = substitute(line '^# \([^#]*\) *', '= \1 =', 'g')
    	        let line = substitute(line '^## \([^#]*\) *','== \1 ==','g')
    	        let line = substitute(line '^### \([^#]*\) *','=== \1 ===','g')
    	        let line = substitute(line '^#### \([^#]*\) *','==== \1 ====','g')
    	        let line = substitute(line '^##### \([^#]*\) *','===== \1 =====','g')
    	        let line = substitute(line '^###### \([^#]*\) *','====== \1 ======','g')

	        " code block substitution
	        let line = substitute(line, '^```\(.*\)$', '{{{\1','g')
	        let line = substitute(line, '^```$', '}}}','g')

	        " imagelink substitution
	        let line = substitute(line, '!\[\([^]]*\)!\]\(\([^]]*\)\)', '[images\/\2|\1]','g')
	        " weblink substitution
	        let line = substitute(line, '\[\([^]]*\)\]\(https:\([^]]*\)\)', '[[https:\2|\1]]','g')
	        " mdlink substitution
	        let line = substitute(line, '\[\/\([^]]*\)\]\(\([^]]*\).md\)', '[\2|\1]','g')
	        " filelink substitution
	        let line = substitute(line, '\[\/\([^]]*\)\]\(\([^]]*\)\)', '[\2|\1]','g')
    	    catch
    	    endtry
            " Add the converted line to the Vimwiki buffer
            call add(vimwiki_buffer, line)
	endfor
	try
    	    let vimwiki_buffer = substitute(vimwiki_buffer, '```\(.|\n\)*\)```', '{{{\1}}}', 'g')
    	catch
    	endtry

    	" Write the Vimwiki buffer to a new file with the same name as the Markdown file but with a .vimwiki extension
    	let vimwiki_file = substitute(markdown_file, '\v\.md$', '.wiki', '')
    	call writefile(vimwiki_buffer, vimwiki_file)

    	" Open the converted Vimwiki file
    	execute 'edit ' . vimwiki_file
    else
	echom "ERROR: " . expand('%') . " does not have markdown(.md) extension or syntax."
    endif
endfunction


function! Vikidown_Md2VikiAll()
    " Get the path of the current Markdown file
    let current_file = expand('%')

    " Get the directory path of the current Markdown file
    let directory = expand('%:p:h')

    " Get a list of all Markdown files in the directory
    let files = glob(directory . '/*.md')

    " Loop through each file
    for file in files
        " Skip the current file
        if file ==# current_file
            continue
        endif

        " Set the current buffer to the file
        execute 'edit ' . file

        " Convert Markdown to Vimwiki
        call Vikidown_Md2Viki()
endfunction


