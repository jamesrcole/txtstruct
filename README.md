
txtstruct
=========

Vim script for headings in text documents - syntax highlighting, mappings to jump between headings etc


the 'ctagsDefn' file
--------------------

txtstruct is compatible with the [Taglist plugin](http://www.vim.org/scripts/script.php?script_id=273).  It is possible to have the Taglist show a listing of the headings in the document.  Taglist uses the [ctags utility](http://ctags.sourceforge.net/) to generate the list of items it will display.  For Taglist to show the headings we need to tell ctags how to find them in our text documents.  The `ctagsDefn` file included in txtstruct contains the definitions required by ctags for this purpose.

Ctags uses a configuration file located in 
`~/.ctags` in Unix-based systems
or in 
`$HOME/ctags.cnf` on Windows.

If you already have such a file on your system, you can copy and paste the contents of `ctagsDefn` into it.

Or if you don't, you can just create the file from a copy of `ctagsDefn`, or create it as a symlink to the `ctagsDefn` file.

