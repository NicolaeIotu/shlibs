#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

mth001() {
	if [ ${#} -ne 3 ]; then
		echo 'Expecting 3 arguments (integers).'
		return 1
	fi
	
	if [ ${2} -eq ${3} ]; then
		echo ${2}
		return
	elif [ ${2} -gt ${3} ]; then
		l_lim=${3}
		u_lim=${2}
	else
		l_lim=${2}
		u_lim=${3}
	fi
	
	if [ ${1} -lt ${l_lim} ]; then
		echo ${l_lim}
	elif [ ${1} -gt ${u_lim} ]; then
		echo ${u_lim}
	else
		echo ${1}
	fi
}

mth001_help() {
	echo 'Checks and returns given integer in given interval'
	echo '$1 - Subject integer'
	echo '$2 - Lower limit (integer)'
	echo '$3 - Upper limit (integer)'
}


mth001_examples() {
	echo 'int1=$(shlibs mth001 10 27 100)'
	echo 'int2=$(shlibs mth001 78 3 22)'
	echo 'echo "$int1, $int2"'
	echo 'Result:'
	echo '27, 22'
}

mth001_tests() {
	tests__='
shlibs mth001 10 27 100
=======
27


shlibs mth001 78 3 22
=======
22
'
	echo "${tests__}"
}
