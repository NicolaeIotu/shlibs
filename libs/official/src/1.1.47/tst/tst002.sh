#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

tst002() {
	mltext='This is multiline sample text

You can use this Text to Test various shlibs libraries

It contains empty lines
 
Lines with just a space char
Punctuation chars: .,;^
Numbers are present as well: 1967452186456
			
Multiple tabs above
UPPERCASE TEXT MAY BE USEFUL WHEN TESTING
Titlecase Could Be Useful As Well


Special control chars right here: \177 \017 \022
Whitespace chars here: \013\012'

	printf "${mltext}" 
}

tst002_help() {
	echo 'Outputs multiline text: various types of chars.'
	echo 'Parameters ignored.'
}

tst002_examples() {
	echo 'shlibs tst002'
	echo 'Result:'
	echo 'This is multiline sample text'
	echo ''
	echo 'You can use this File to Test various shlibs libraries'
	echo ''
	echo 'It contains empty lines'
	echo ' '
	echo 'Lines with just a space char'
	echo 'Punctuation chars: .,;^'
	echo 'Numbers are present as well: 1967452186456'
	echo '			'
	echo 'Multiple tabs above'
	echo 'UPPERCASE TEXT MAY BE USEFUL WHEN TESTING'
	echo 'Titlecase Could Be Useful As Well'
	echo ''
	echo ''
	echo 'Special control chars right here:   '
	echo 'Whitespace chars here: '
	echo ' '
}
