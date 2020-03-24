#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str045() {
	if [ ${#} -gt 0 ]; then
		if [ ${#} -eq 1 ]; then
			test ${#1} -eq 0 || return 1
			return
		fi
		
		isfileinput=1
		filepath=''
		str=''
		
		while [ ${#} -gt 0 ]
		do
			case ${1} in
				-f)
					if [ -n "${str}" ] || [ ${isfileinput} -eq 0 ]; then
						echo "${S_ERR_2}"
						return 1
					fi
					if [ -n "${2}" ] && [ -r "${2}" ]; then
						isfileinput=0
						filepath="${2}"
						shift 2
					else
						echo "Invalid file '${2}'"
						return 1
					fi
				;;
				*)
					if [ ${isfileinput} -eq 0 ]; then
						echo "${S_ERR_2}"
						return 1
					fi
					if [ -n "${str}" ]; then
						printf "${S_ERR_1}" "${rl_dev_code}"
						return 1
					else
						str="${1}"
					fi
					shift
				;;
			esac
		done
		
		
		if [ ${isfileinput} -eq 0 ]; then
			strlen=$(wc -m "${filepath}")
			strlen="$(expr "${strlen}" : " *\(.*\)$")"
			strlen=${strlen%% *}
			strlen=$((strlen-1))
		else
			if [ -z "${str}" ]; then
				printf "${S_ERR_1}" "${rl_dev_code}"
				return 1
			fi
			strlen=${#str}
		fi
		
		test ${strlen} -eq 0 || return 1
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

str045_help() {
	echo 'Checks if string/file is empty.'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
}

str045_examples() {
	echo 'shlibs str045 ""'
	echo 'echo ${?}'
	echo 'Result: 0'
}

str045_tests() {
	tests__='
shlibs str045 "" ; echo ${?}
=======
0

shlibs str045 -f "$(shlibs -p tst007)" ; echo ${?}
=======
1
'
	echo "${tests__}"
}
