#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

ofc003() {
	echo '+----------------------------------------------------------------+'
	echo '|                        shlibs Changelog                        |'
	echo '+----------------------------------------------------------------+'
	
	printf '\n\n'
	echo '***** shlibs v 1.0.0 / libs v 1.0.0'
	echo '- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - '
	echo 'The first release of shlibs and libraries'
	printf '\n'
}

ofc003_help() {
	echo 'shlibs Changelog Help'
	ofc003_examples
}


ofc003_examples() {
	echo 'Use "shlibs ofc003" to view the latest shlibs Changelog'
}
