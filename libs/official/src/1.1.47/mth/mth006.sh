#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

mth006() {
	if [ ${#} -eq 2 ] && [ ${1} -gt 0 2>/dev/null ] && [ ${2} -gt 1 2>/dev/null ] && \
		[ ${2} -gt ${1} ]; then
		prec=${#2}
		rnd=$("${shlibs_dirpath}"/shlibs str005 -xp -xa -xA ${prec})
		rnd="0.${rnd}"
		delta=$((${2}-${1}))
		echo $( "${shlibs_dirpath}"/shlibs mth004 -fmt "%.0f" \
			"(${rnd}*${delta})+${1}" )
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

mth006_help() {
	echo 'Get a random integer in specified interval'
	echo 'Parameters: '
	echo ' - start of interval (integer)'
	echo ' - end of interval (integer)'
}


mth006_examples() {
	echo 'shlibs mth006 1 22'
	echo 'shlibs mth006 4455 6345467'
	echo 'Results:'
	echo '17'
	echo '85434'
}

mth006_tests() {
	tests__='
t="$(shlibs mth006 5 10)"; test ${t} -gt 4 && test ${t} -lt 11; echo ${?}
=======
0
'
	echo "${tests__}"
}
