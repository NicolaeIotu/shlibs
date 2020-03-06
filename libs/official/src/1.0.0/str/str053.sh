#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str053() {
	if [ ${#} -gt 1 ]; then
		isfileinput=1
		filepath=''
		str=''
		len=10
		
		while [ ${#} -gt 0 ]
		do
			case ${1} in
				[1-9]|[1-9][0-9]*)	
					len=${1}
					shift
				;;
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
			head -n ${len} <"${filepath}"
		else
			echo "${str}" | head -n ${len}
		fi
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

str053_help() {
	echo 'Return first n lines in string/file.'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
	echo ' - the number of lines (optional, defaults to 10)'
}

str053_examples() {
	echo 'teststring=$(printf "%b" "This is the first line.\\nSecond line here.\\nThird one here.")'
	echo 'shlibs str053 "${teststring}" 2'
	echo 'Result:'
	printf "%b" 'This is the first line.\nSecond line here.\n'
}

str053_tests() {
	tests__='
shlibs str053 -f "$(shlibs -p tst005)" 2
=======
This is multiline sample text
It contains moderate amounts of text and can be used to test
'
	echo "${tests__}"
}
