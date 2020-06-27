#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

mth005() {
	if [ ${#} -eq 0 ] || \
		( [ ${#} -eq 1 ] && [ ${1} -gt 0 2>/dev/null ] ); then
		prec=${1:-6}
		rnd=$("${shlibs_dirpath}"/shlibs str005 -xp -xa -xA ${prec})
		echo "0.${rnd}"
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

mth005_help() {
	echo 'Get a random number in interval 0-1 (adjustable precision)'
	echo 'Parameters: '
	echo ' - precision given as integer greater than 0'
}


mth005_examples() {
	echo 'shlibs mth005 8'
	echo 'shlibs mth005 17'
	echo 'Results:'
	echo '0.34586426'
	echo '0.08723816872631456'
}

mth005_tests() {
	tests__='
t="$(shlibs mth005)"; t=${t#0.}; test ${t} -lt 1000000; echo ${?}
=======
0
'
	echo "${tests__}"
}
