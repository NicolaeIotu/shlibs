#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

mth003() {
	if [ ${#} -lt 2 ]; then
		echo 'Expecting at least 2 integers.'
		return 1
	fi
	res=${1}
	shift
	while [ ${#} -gt 0 ]
	do
		if [ ${res} -lt ${1} ]; then
			res=${1}
		fi
		shift
	done
	echo ${res}
}

mth003_help() {
	echo 'Returns the integer with the maximum value.'
	echo 'Requires at least 2 integers.'
}


mth003_examples() {
	echo 'max=$(shlibs mth003 23 3 5 23 65 2)'
	echo 'echo "maximum: $max"'
	echo 'Result:'
	echo 'maximum: 65'
}

mth003_tests() {
	tests__='
shlibs mth003 23 3 5 23 65 2
=======
65


shlibs mth003 0 -7 -159 33
=======
33
'
	echo "${tests__}"
}
