#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str002() {
	echo ${@}
}

str002_help() {
	echo 'Trim extra whitespace from string.'
	echo 'Parameters:'
	echo '$@ - String(s)'
}

str002_examples() {
	echo 'string="    27262976   kB     "'
	echo 'string_trimmed=$(shlibs str002 "${string}")'
	echo 'echo "${string_trimmed}"'
	echo 'Result:'
	echo '27262976 kB'
}

str002_tests() {
	tests__='
shlibs str002 "    27262976   kB     "
=======
27262976 kB'
	echo "${tests__}"
}
