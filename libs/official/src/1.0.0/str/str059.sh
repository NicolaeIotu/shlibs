#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str059() {
	if [ ${#} -gt 0 ]; then
		if [ ${#} -eq 1 ]; then
			echo "${1}" | tr '[:upper:][:lower:]' '[:lower:][:upper:]'
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
		
		
		if [ ${isfileinput} -eq 0 ]; then :
		else
			if [ -z "${str}" ]; then
				printf "${S_ERR_1}" "${rl_dev_code}"
				return 1
			fi
		fi
		
		
		if [ ${isfileinput} -eq 0 ]; then
			tr '[:upper:][:lower:]' '[:lower:][:upper:]' <"${filepath}"
		else
			echo "${str}" | tr '[:upper:][:lower:]' '[:lower:][:upper:]'
		fi
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

str059_help() {
	echo 'Returns swapcase version of string/file (lowercase<->UPPERCASE)'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
}


str059_examples() {
	echo 'shlibs str059 "TEXT to MORPH using shlibs str059 SWAPCASE."'
	echo 'Result:'
	echo 'text TO morph USING SHLIBS swapcase.'
}

str059_tests() {
	tests__='
shlibs str059 "TEXT to MORPH using str059 SWAPCASE."
=======
text TO morph USING STR059 swapcase.


shlibs str059 -f "$(shlibs -p tst007)"
=======
NeeDLE
RiGhT
'
	echo "${tests__}"
}
