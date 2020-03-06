#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str030() {
	if [ ${#} -gt 0 ]; then
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
					if [ -n "${str}" ]; then
						printf "${S_ERR_1}" "${rl_dev_code}"
						return 1
					fi
					str="${1}"
					shift
				;;
			esac
		done
		
		
		if [ ${isfileinput} -eq 0 ]; then
			sed '/^['"${SHLIBS_CCLASS_SPACE}"']*$/d' "${filepath}"
		else
			if [ -z "${str}" ]; then
				printf "${S_ERR_1}" "${rl_dev_code}"
				return 1
			fi
			echo "${str}" | sed '/^['"${SHLIBS_CCLASS_SPACE}"']*$/d'
		fi
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

str030_help() {
	echo 'Delete from output empty lines in string/file.'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
}

str030_examples() {
	echo 'teststring=$(printf "%b" "This is the >>first<< line.\\n\\nSecond .?=line..,, here.\\nThird% #%li,ne-from-aliens.k; here.")'
	echo 'shlibs str030 "${teststring}"'
	echo 'Result: '
	printf "%b" 'This is the >>first<< line.\nSecond .?=line..,, here.\nThird% #%li,ne-from-aliens.k; here.\n'	
}

str030_tests() {
	tests__='
shlibs str030 -f "$(shlibs -p tst005)" | head -n 6
=======
This is multiline sample text
It contains moderate amounts of text and can be used to test
other shlibs libraries.
You can test this file using needles spanning over multiple lines of text.
It contains empty lines
A repeating multiline needle
'
	echo "${tests__}"
}
