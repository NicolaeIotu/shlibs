#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str043() {
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
							printf "${S_ERR_1}" "${rl_dev_code}"
							return 1
						fi
					fi
					shift
				;;
				-f)
					if [ -n "${str}" ] || [ ${isfileinput} -eq 0 ]; then
						echo "${S_ERR_2}"
						return 1
					fi
					if [ -r "${2}" ]; then
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
			sed -n "${start},${end} p" "${filepath}"
		else
			echo "${str}" | sed -n "${start},${end} p"
		fi
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

str043_help() {
	echo 'Return lines in interval start-length of string/file.'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
	echo ' - start, line number of the start of deletion (deleted as well)'
	echo ' - length, the total number of lines to be deleted'
	echo '   (must be specified after start line number)'
}

str043_examples() {
	echo 'string=$(printf "%b" "This is the first line.\\n\\nSecond line here.\\nExemplary line coming up.\\n\\nAnother one here.")'
	echo 'shlibs str043 "${string}" 3 2'
	echo 'Result: '
	printf "%b" 'Second line here.\nExemplary line coming up.\n'	
}

str043_tests() {
	tests__='
shlibs str043 -f "$(shlibs -p tst005)" 2 2
=======
It contains moderate amounts of text and can be used to test
other shlibs libraries.
'
	echo "${tests__}"
}
