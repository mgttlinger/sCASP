

compile_tclp_asp:
	ciaoc -x -o tclp_asp src/tclp_asp.pl

clean:
	@-ciao clean-tree .
	@-find . -name "*~" -type f -delete
	@rm tclp_asp
