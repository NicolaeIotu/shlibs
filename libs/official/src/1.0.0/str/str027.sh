#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str027() {
	if [ ${#} -gt 0 ]; then
		if [ ${#} -eq 1 ]; then
			echo ${#1}
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
						echo "Invalid file."
						return 1
					fi
				;;
				*)
					if [ -n "${str}" ]; then
						printf "${S_ERR_1}" "${rl_dev_code}"
						return 1
					fi
					str="${1}"
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
			strlen=$(wc -m "${filepath}")
			strlen="$(expr "${strlen}" : " *\(.*\)$")"
			strlen=${strlen%% *}
			echo $((strlen-1))
		else
			echo ${#str}
		fi
	else
		echo 'Invalid argument.'
		return 1
	fi
}

str027_help() {
	echo 'Returns the total number of characters in string/file.'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
}


str027_examples() {
	echo 'shlibs str027 "test string"'
	echo 'Result: 11'
}

str027_tests() {
	tests__='
shlibs str027 "test string"
=======
11


shlibs str027 -f "$(shlibs -p tst005)"
=======
462
'
	echo "${tests__}"
}
