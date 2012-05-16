syntax match lvl1Heading /^:[^:].*$/
syntax match lvl2Heading /^::[^:].*$/
syntax match lvl3Heading /^:::[^:].*$/
syntax match lvl4Heading /^::::[^:].*$/
syntax match lvl5Heading /^:::::.*$/

highlight lvl1Heading guifg=#0000FF
highlight lvl2Heading guifg=#0075FF
highlight lvl3Heading guifg=#0095FF
highlight lvl4Heading guifg=#60B9FF
highlight lvl5Heading guifg=#90DCFF

