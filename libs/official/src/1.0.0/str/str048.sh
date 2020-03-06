#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str048() {
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
						echo "Invalid file."
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
		
				
		if [ ${isfileinput} -eq 0 ]; then :
		else
			if [ -z "${str}" ]; then
				printf "${S_ERR_1}" "${rl_dev_code}"
				return 1
			fi
		fi
		
		
		awk_script__ml='BEGIN { maxlen=0 } { if (length>maxlen) maxlen=length } END { print maxlen }'

		if [ ${isfileinput} -eq 0 ]; then				
			${SHLIBS_AWK} "${awk_script__ml}" <"${filepath}"
		else
			echo "${str}" | ${SHLIBS_AWK} "${awk_script__ml}"
		fi
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

str048_help() {
	echo 'Returns maximum line length in string/file.'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
}

str048_examples() {
	echo 'shlibs str048 "$(shlibs tst002)"'
	echo 'Result: 54'
}

str048_tests() {
	tests__='
shlibs str048 "$(shlibs tst002)"
=======
54


shlibs str048 -f "$(shlibs -p tst005)"
=======
74
'
	echo "${tests__}"
}
