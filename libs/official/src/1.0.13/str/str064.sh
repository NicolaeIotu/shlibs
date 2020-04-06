#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str064() {
	if [ ${#} -gt 2 ]; then
		isfileinput=1
		filepath=''
		str=''
		start=0
		len=0
		end=0
		
		while [ ${#} -gt 0 ]
		do
			case ${1} in
				[1-9]|[1-9][0-9]*)
					if [ ${start} -eq 0 ]; then
						start=${1}
					else
						if [ ${len} -eq 0 ]; then
							len=${1}
						else
							if [ -z "${str}" ]; then
								str="${1}"
							else
								printf "${S_ERR_1}" "${rl_dev_code}"
								return 1
							fi
						fi
					fi
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
		
		
		if [ ${start} -eq 0 ] || [ ${len} -eq 0 ]; then
			printf "${S_ERR_1}" "${rl_dev_code}"
			return 1	
		fi
		if [ ${isfileinput} -eq 0 ]; then :
		else
			if [ -z "${str}" ]; then
				printf "${S_ERR_1}" "${rl_dev_code}"
				return 1
			fi
		fi
		
		end=$((start+len-1))
		
		if [ ${isfileinput} -eq 0 ]; then
			sed "${start},${end} d" "${filepath}"
		else
			echo "${str}" | sed "${start},${end} d"
		fi
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

str064_help() {
	echo 'Delete from output lines in interval start-length of string/file.'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
	echo ' - start, line number of the start of deletion (deleted as well)'
	echo ' - length, the total number of lines to be deleted'
	echo '   (must be specified after start line number)'
}

str064_examples() {
	echo 'string=$(printf "%b" "This is the first line.\\n\\nSecond line here.\\nExemplary line coming up.\\n\\nAnother one here.")'
	echo 'shlibs str064 "${string}" 2 3'
	echo 'Result: '
	printf "%b" 'This is the first line.\n\nAnother one here.\n'	
}

str064_tests() {
	tests__='
shlibs str064 -f "$(shlibs -p tst005)" 2 2 | head -n 2
=======
This is multiline sample text
You can test this file using needles spanning over multiple lines of text.
'
	echo "${tests__}"
}
