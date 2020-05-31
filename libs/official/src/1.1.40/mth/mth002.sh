#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

mth002() {
	if [ ${#} -lt 2 ]; then
		echo 'Expecting at least 2 integers.'
		return 1
	fi
	res=${1}
	shift
	while [ ${#} -gt 0 ]
	do
		if [ ${res} -gt ${1} ]; then
			res=${1}
		fi
		shift
	done
	echo ${res}
}

mth002_help() {
	echo 'Returns the integer with the minimum value.'
	echo 'Requires at least 2 integers.'
}


mth002_examples() {
	echo 'min=$(shlibs mth002 23 3 5 23 65 2)'
	echo 'echo "minimum: $min"'
	echo 'Result:'
	echo 'minimum: 2'
}

mth002_tests() {
	tests__='
shlibs mth002 23 3 5 23 65 2
=======
2


shlibs mth002 0 -7 -159 33
=======
-159
'
	echo "${tests__}"
}
