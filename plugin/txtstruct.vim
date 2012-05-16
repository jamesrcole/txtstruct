" vim:fo-=a


"requires SOnPlural (cur in _vimrc)

" up to usr_41.txt, ln 1884 "THE RESULT" 


" *** so in vim.org desc of this will have to warn user that it remaps n_C-J
" and n_C-K to scroll to next and prev headings.  
"
" *** >ic >ac (or 'd' instead of '>') dont seem to work w/ empty sections 
"
" *** i guess i should change all the 'function!' to just 'function'


" Vim global plugin for structured text documents which contain headings
" Last Change:	2010 Sep 20
" Maintainer:	James Cole <james.cole@gmail.com>
" License:	This file is available under the same licence as Vim. 


if exists("loaded_txtstruct")
  finish
endif
let loaded_txtstruct = 1

let s:save_cpo = &cpo
set cpo&vim


let s:UP   = 1
let s:DOWN = 0

" ***** get the following to work!
" if !hasmapto('<Plug>MultNextSection')
"   map <silent> <C-j> <Plug>MultNextSection
" endif
map <silent> <C-j> :<C-U>call <SID>MultNextSection()<CR>


":Jump to next/prev section


" 
" Move the cursor to the start of the next section.  The end of the file is considered
" a 'section'.
" Also returns the position of the start of the section.
" 
" ** refactoring: get this to return the section's entire details (not just its start pos)
"
" hmm, also coz the end of the file is like the start of an empty section,
" should this func not have that 'normal! $' bit??
"
function! s:NextSection_Orig()
    let res = search("^:", "W")
    if res == 0
        $
        normal! $
    endif
    return getpos(".")
endfunction


" jump to start of next section (but dont wrap around past end of file)
" new version that does work with a count
function! s:MultNextSection()
    execute "normal m'"
    let origLineNum = getpos(".")[1]
    for i in range(1, v:count1)
        call s:NextSection_Orig()
    endfor
    let newLineNum = getpos(".")[1]
    let diff = newLineNum - origLineNum
    redraw   " so the following echo isn't overwritten by scrolling
    echo( diff . " line" . SOnPlural(diff) . " down")
endfunction


" shouldnt be necess omap <C-j> :call <SID>NextSection()<CR>




" ** refactoring: should really be called 'PrevHeading' (similar 4
" NextSection) 
"
" ** consolidate with newer prev section in txtstruct.vim
function! s:PrevSection_Orig()
    let res = search("^:", "bW")
    if res == 0
        normal! gg
        normal! 0
    endif
    return getpos(".")
endfunction

" jump to start of previous section (but dont wrap around past start of file)
" new version that does work with a count
function! s:MultPrevSection()
    execute "normal m'"
    let origLineNum = getpos(".")[1]
    for i in range(1, v:count1)
        call s:PrevSection_Orig()
    endfor
    let newLineNum = getpos(".")[1]
    let diff = origLineNum - newLineNum
    redraw   " so the following echo isn't overwritten by scrolling
    echo( diff . " line" . SOnPlural(diff) . " up")
endfunction
map <silent> <C-k> :<C-U>call <SID>MultPrevSection()<CR>




": jump to start of this sections parent section

function! s:ParentSection()
    let currHeadingLine = getline(search("^:", "bnW"))
    let currHeadingLvl = strlen( matchstr( currHeadingLine, "^:\\+") )
    let parentHeadingLvl = repeat(":", currHeadingLvl - 1)
    let parentHeadingSearchPat = "^" . parentHeadingLvl . "[^:]"
    call search(parentHeadingSearchPat, "bWs")
endfunction

map <C-h> :call <SID>ParentSection()<CR>





":visual select to next/prev section


function! s:MultNextSection_V()
    normal! gV
    let selStart = getpos("'<")
    let selEnd = getpos("'>")
    call setpos(".", selEnd) 
    call s:MultNextSection()
    let finalPos = getpos(".")
    let down = 0
    call s:SetSelection([selStart, finalPos], down)
endfunction
vnoremap <silent> <C-j> :<C-U>call <SID>MultNextSection_V()<CR>



function! s:MultPrevSection_V()
    normal! gV
    let selEnd = getpos("'<")
    let selStart = getpos("'>")
    call setpos(".", selEnd) 
    call s:MultPrevSection()
    let finalPos = getpos(".")
    call s:SetSelection([finalPos, selStart], s:UP)
endfunction
vnoremap <silent> <C-k> :<C-U>call <SID>MultPrevSection_V()<CR>


":select ac (a section) and ic (innersection)


" to do 
" 
"   - get it working with a count. put it in normal mode at start of each
"   loop iter? 

" minor issue: flawed way of detecting selection direction.
" 
"     in that if you have char based selection from right to left it things the
" sel direction is downwards... not sure how to fix that though and i notice that
" if you do 'ip' to select it gets this 'wrong' as well.
" 
" 
" also, i think there is some sort of bug in the code... even though
" _functionally_ it works, some of the echo statemnets i was putting in seem to
" get called many many times (when it should only be called once).... also, it
" seems like it can take a while to do its processing.


"     meaning of 'ic' 
" 
"         is the meaning of heading lines and empty sections vis a vis the
"         notion of inner sections.  Because 'ic' will be more useful if we
"         can extend sections that start in these or go over these.  Or what
"         meaning they have regarding a count.
" 
"         if you have an entire 'inner section' selected, 'ic' it should
"         select up to the end of the next inner selection - selecting the
"         heading inbetween them.
" 
"         ic should always select up to the end of a inner section.  if sel
"         frontier is within an inner section, to the end of that inner
"         section.  if sel frontier is on a heading, should select to the end
"         of that section's inner section.  
"         
" 
"     what constitutes an 'innner section'
" 
"         one special case is a empty-section heading.  that is, where you
"         have a heading and next line is another heading.  in this case, the
"         heading counts as the 'inner section'.  so if ic should always
"         select up to the end of an inner section, if part of that heading
"         is selected, it should select up to the end of that heading.  if
"         all of htat heading is selected, it should select up to the end of
"         the next inner section. 
" 
"         so really, what this means is that 'inner section' means either: 
"         - the lines between one heading and the next, if these lines exist
"         - the entirty of an empty-section heading.  
" 


" TO DO? replace the 0 and 1 here w/ constants

noremap <silent> ac :<C-U>call <SID>SelectNextSection(0)<CR>
nunmap ac| sunmap ac
onoremap <silent> ac :normal Vac<CR>


noremap <silent> ic :<C-U>call <SID>SelectNextSection(1)<CR>
nunmap ic| sunmap ic
onoremap <silent> ic :normal Vic<CR>
" onoremap <silent> ic :<C-U>call <SID>OperatorSelectNextSection()<CR>
" 
" function! s:OperatorSelectNextSection()
"     normal Vic
"     silent! call repeat#set(">Vic",1) 
" endfunction



" 
" what it's trying to do: 
"     - expand the current selection to include
"         - if the current inner section fully selected: 
"               the next inner section 
"               (in the direction the selection is going in)
"         - otherwise, 
"               the full current inner section 
"               (in the direction the selection is going in)
" 
" function! s:SelectNextInnerSection()
"     let [selectedArea, selFrontier, selDirection] = s:GetSelectionDetails()
"     let currSection      = s:GetSectionBounds(selFrontier)
"     let currInnerSection = s:GetInnerSection(currSection)
"     if s:AreaGreaterThanOrEqualTo( selectedArea, currInnerSection )
"         let toInnerSection = s:GetInnerSection(s:NextSection(currSection, selDirection))
"     else
"         let toInnerSection = currInnerSection
"     endif
"     call s:AddToSelection( toInnerSection, selDirection )
" endfunction


function! s:SelectNextSection(innerOnly)
    let [selectedArea, selFrontier, selDirection] = s:GetSelectionDetails()
    let currSection  = s:GetSectionBounds(selFrontier)
    if a:innerOnly 
        let currSectToUse = s:GetInnerSection(currSection)
    else
        let currSectToUse = currSection 
    endif

    if s:AreaGreaterThanOrEqualTo( selectedArea, currSectToUse )
        let toSectToUse = s:NextSection(currSection, selDirection)
        if a:innerOnly 
            let toSectToUse = s:GetInnerSection(toSectToUse)
        endif
    else
        let toSectToUse = currSectToUse
    endif
    call s:AddToSelection( toSectToUse, selDirection )
endfunction




function! s:GetInnerSection(section) 
    let innerSection = deepcopy(a:section)
    if innerSection[0][1] != innerSection[1][1]   " i.e. non-empty section
        " except for the implicit section before first heading 
        if innerSection[0][1] != 1           
            let innerSection[0][1] = innerSection[0][1] + 1
        endif
    endif
    return innerSection
endfunction



function! s:NextSection(currentSection, direction)
    if a:direction == s:UP
        let pos = a:currentSection[0]
        let pos[1] = pos[1] - 1
    else
        let pos = a:currentSection[1]
        let pos[1] = pos[1] + 1
    endif
    return s:GetSectionBounds( pos )
endfunction


function! s:GetSectionBounds(position)
    let topBound    = s:GetSectionBound(a:position, s:UP)
    let bottomBound = s:GetSectionBound(topBound, s:DOWN)
    return [topBound, bottomBound]
endfunction 


"
" From a position within a section, find the next section 
" bound in a particular direction (up -> start, down -> end)
"
" bug:  a minor problem: 
" 
"     if the implicit section at the top of the file is a (totally) empty line.
"     then it reports an inner section from top of file to end of following 
"     inner section
" 
"         I'd thought that the problem was that 
" 
"         s:GetSectionBound(position, direction) 
" 
"         doesn't accept a match at the current position....
" 
"         ..which is a problem when there's only one char when you can be in
"         the section....
" 
"         -> but changing that hasn't fixed the problem.
"            i just tried :call search("^$", "c") 
"            and that doesn't work either, but surely should!
"            is this a vim bug??
" 
function! s:GetSectionBound(position, direction)
    if a:direction == s:UP
        let searchString = "^:"
        let searchParams = "bcW"
    else
        " in the follwing id orig tried  \\n^:
        " and "\\_$^:"    
        " the reason it needs to be the following is that 
        " the end of the section may be an _empty line_ 
        " as well as a line containing characters
        let searchString = "\\(^$\\n:\\)\\|\\(.\\n:\\)" 
        let searchParams = "cW"
    endif
    call setpos(".", a:position)
    let res = search(searchString, searchParams)
    if res == 0
        if a:direction == s:UP
            normal! gg
            normal! 0
        else     
            $
            normal! $
        endif
    endif
    return getpos(".")
endfunction



function! s:GetSelectionDetails()
    let selectedArea = s:GetSelectionArea()
    let selFrontier = s:GetSelectionFrontier()
    let selDirection = s:GetSelectionDirection( selectedArea, selFrontier )
    return [selectedArea, selFrontier, selDirection]
endfunction

function! s:GetSelectionArea()
    return [ getpos("'<"), getpos("'>") ]
endfunction

" 
" lesson learnt from doing this
" if you have a multi-line selection then press
" <ESC> the selection is removed and the cursor is just left where
" it was.  but if you type : to go into ex-mode and then press
" <ESC> the cursor is brought back to the origin line of the
" selection!  and i notice it is the same when you press <C-C>
" instead of <ESC>, too.  
" -> AH! no, it's crazy, if you : or you <C-C> the cursor is always 
"  left on the _top-most_ line!..
"
function! s:GetSelectionFrontier()
    " reinstate selection to get cursor back in pos it was in
    normal! gv
    let selFrontier = getpos(".")
    " remove the selection (so subsequent functions can assume selection isnt set)
    exec "normal! \e"
    return selFrontier  
endfunction


function! s:GetSelectionDirection(selectedArea, selFrontier)
    " is the top of the selection's line same as selFronteir's one? 
    " (note that we only compare the line, not the character, because in 
    "  line based selection the actual pos of the cursor may be anywhere in 
    "  the line, the entirety of which will be selected)
    let multiLineSelection = ( a:selectedArea[0][1] != a:selectedArea[1][1] )
    let selFrontierOnSameLineAsSelTop = ( a:selectedArea[0][1] == a:selFrontier[1] )
    return ( selFrontierOnSameLineAsSelTop && multiLineSelection )
endfunction


" 
" one question i have is: will anything before this change the values 
"    of '> and '<
" i.e. is anything after the user's command setting the selection? 
" ans: doesn't look like it 
" 
function! s:AddToSelection(area, selDirection)
    let selectionArea = s:GetSelectionArea()
    let newSelection = [ 
        \ s:MinPos([selectionArea[0], a:area[0]]), 
        \ s:MaxPos([selectionArea[1], a:area[1]]) 
    \ ]
    call s:SetSelection( newSelection, a:selDirection )
endfunction


function! s:SetSelection(selectionArea, selDirection)
    call setpos(".", a:selectionArea[0])
    normal! V
    call setpos(".", a:selectionArea[1])
    if a:selDirection == s:UP
        normal! o
    endif
endfunction



function! s:AreaGreaterThanOrEqualTo(area1, area2)
    let topLTOET = s:PosLessThanOrEqualTo(a:area1[0], a:area2[0])
    let bottomGTOET = s:PosGreaterThanOrEqualTo(a:area1[1], a:area2[1])
    return ( topLTOET && bottomGTOET)
endfunction


function! s:PosEquals(pos1, pos2)
    return ( a:pos1[1] == a:pos2[1] ) && ( a:pos1[2] == a:pos2[2] )
endfunction


function! s:PosLessThanOrEqualTo(pos1, pos2)
    if a:pos1[1] < a:pos2[1]
        return 1
    elseif (a:pos1[1] == a:pos2[1]) && (a:pos1[2] <= a:pos2[2])
        return 1
    else
        return 0
    endif
endfunction

function! s:PosGreaterThanOrEqualTo(pos1, pos2)
    if a:pos1[1] > a:pos2[1]
        return 1
    elseif (a:pos1[1] == a:pos2[1]) && (a:pos1[2] >= a:pos2[2])
        return 1
    else
        return 0
    endif
endfunction 


function! s:MinPos(posList)
    let minPos = a:posList[0]
    for pos in a:posList
        if ( s:PosLessThanOrEqualTo(pos, minPos) )
            let minPos = pos
        endif
    endfor
    return minPos
endfunction

function! s:MaxPos(posList)
    let maxPos = a:posList[0]
    for pos in a:posList
        if ( s:PosGreaterThanOrEqualTo(pos, maxPos) )
            let maxPos = pos
        endif
    endfor
    return maxPos
endfunction



": some other ones


function! s:PasteAppendSelectedSection()
    call s:GetHeadingSelectionAndJumpThere()
    " **NOTE... this is setting the apostrophe mark whichll cause probs!
    call s:NextSection_Orig()     
    if getpos(".")[1] == getpos("$")[1]
        normal! o
        normal! o
        normal! o
        normal! k
    else
        normal! O
        normal! O
        normal! O
        normal! j
    endif
    normal! "*p
endfunction

nmap <silent> ,sp :<C-U>call <SID>PasteAppendSelectedSection()<CR>



" note that there's nothing doing any error checking on the user's input
" note this function does not set any marks (like for returning to org
" position)
function! s:GetHeadingSelectionAndJumpThere()
    let headingLineNums = s:GetHeadingLineNums()
    let headingsMenuList = s:ConstructHeadingsMenuList(headingLineNums)
    let chosenHeadingNum = inputlist(headingsMenuList) - 1   
        " ^ subtract one coz inserted a prompt as first menu item
    call setpos(".", [0, headingLineNums[chosenHeadingNum], 1, 0])
endfunction


    " *** refactoring: i should break out a function called "get all matches" and
    "     have this func just call that.  but note if i did, i'd have to change it 
    "     to searching for next match to from the end of the curr match (and 
    "     probably change the regex I send it to match the entire heading line) 
    " *** bloody hell... just discovered that calling normal! is really touchy!
    "     if you have any spaces at end of line it doesn't work!
    "     was causing quite weird errors!
    " *** for some reason if youre on the first line of the file and do that
    "     search it misses a match on that first line! ****
    function! s:GetHeadingLineNums()
        normal! gg 
        " coz line-based commands like gg dont necess put cursor on col 1
        normal! 0
        let headingLineNums = []
        while 1 
            let lineNum = search("^:", "Wc")
            if lineNum == 0  " no match
                break
            else
                call add(headingLineNums, lineNum)
                if lineNum == getpos("$")[1]   " if at end of file
                    break
                else
                    normal! j   " coz we are allowing match at cursor
                    " and coz line based commands like j dont necess put cursor on col 1
                    normal! 0
                endif
            endif
        endwhile
        return headingLineNums
    endfunction

    function! s:ConstructHeadingsMenuList(headingLineNums)
        let optionsList = []
        call add(optionsList, "Select value:")
        for idx in range(len(a:headingLineNums))
            call add(
                \ optionsList, printf("%02d", idx + 1) . " " .  
                \ getline(a:headingLineNums[idx])
            \ )
        endfor
        return optionsList 
    endfunction






let &cpo = s:save_cpo


