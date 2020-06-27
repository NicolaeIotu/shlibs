#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

tst003() {
	echo 'A Test needle line with needles, stuff, needle and once more Needle. Needles all over.' 
}

tst003_help() {
	echo 'Outputs a single line of text used for tests.'
	echo 'Parameters ignored.'
}

tst003_examples() {
	echo 'shlibs tst003'
	echo 'Result:'
	echo 'A Test needle line with needles, stuff, needle and once more Needle. Needles all over.'
}
