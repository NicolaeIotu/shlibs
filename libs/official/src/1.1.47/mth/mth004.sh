#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

mth004() {
	if [ ${#} -gt 3 ]; then
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
	
	calc=''
	fmt='%.6g'
	
	while [ ${#} -gt 0 ]
	do
		case ${1} in
			-fmt)
				fmt="${2}"
				shift 2
			;;
			*)
				if [ -n "${calc}" ]; then
					printf "${S_ERR_1}" "${rl_dev_code}"
					return 1
				else
					calc="${1}"
				fi
				shift
			;;
		esac
	done
	
	if [ -z "${fmt}" ] || [ ${#calc} -lt 3 ]; then
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
	
	echo a | ${SHLIBS_AWK} -v CONVFMT="${fmt}" -v OFMT="${fmt}" \
		'BEGIN { printf '"${calc}"' }'
}

mth004_help() {
	echo 'Performs arithmetic calculations. Outputs integer/float values.'
	echo 'Parameters: '
	echo ' - string describing the calculation to be performed'
	echo ' - use "-fmt format" to describe the output format (optional, default "%.6g")'
	echo '   (non-standard output formats can fail on some versions of awk/OSes; '
	echo '    i.e. "%.4d" will fail on nawk/Solaris, awk/Minix'
	echo '    while standard formats such as "%.4g" and "%.4f" will never fail)'
}


mth004_examples() {
	echo 'shlibs mth004 "400*2.434/873"'
	echo 'shlibs mth004 "400*2.434/873" -fmt "%.2f"'
	echo 'Results:'
	echo '1.11523'
	echo '1.12'
}

mth004_tests() {
	tests__='
shlibs mth004 "400*2.434/873"
=======
1.11523


shlibs mth004 "400*2.434/873" -fmt "%.2f"
=======
1.12
'
	echo "${tests__}"
}
