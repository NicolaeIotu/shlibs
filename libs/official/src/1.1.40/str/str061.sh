#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str061() {
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
					if [ ${isfileinput} -eq 0 ]; then
						echo "${S_ERR_2}"
						return 1
					fi
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
			# Minix workaround
			if ${SHLIBS_TAIL} -n ${len} "${filepath}" 2>/dev/null ; then :
			else
				cat "${filepath}" | ${SHLIBS_TAIL} -n ${len}
			fi
		else
			echo "${str}" | ${SHLIBS_TAIL} -n ${len}
		fi
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

str061_help() {
	echo 'Return last n lines in string/file.'
	echo 'Parameters:'
	echo ' - subject string, or ...'
	echo ' - text file: "-f /path/to/text/file"'
	echo ' - the number of lines (optional, defaults to 10)'
}

str061_examples() {
	echo 'teststring=$(printf "%b" "This is the first line.\\nSecond line here.\\nThird one here.")'
	echo 'shlibs str061 "${teststring}" 2'
	echo 'Result:'
	printf "%b" 'Second line here.\nThird one here.\n'
}

str061_tests() {
	tests__='
shlibs str061 -f "$(shlibs -p tst005)" 1
=======
Thank you!
'
	echo "${tests__}"
}
