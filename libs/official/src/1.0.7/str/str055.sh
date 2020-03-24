#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str055() {
	if [ ${#} -gt 0 ]; then
		isfileinput=1
		filepath=''
		str=''
		ndl=''
		
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
						ndl="${1}"
					else
						str="${1}"
					fi
					shift
				;;
			esac
		done
		
		
		if [ ${isfileinput} -eq 0 ]; then
			if [ -n "${str}" ]; then
				if [ -n "${ndl}" ]; then
					printf "${S_ERR_1}" "${rl_dev_code}"
					return 1
				else
					ndl="${str}"
					str=''
				fi				
			fi
		else
			if [ -z "${str}" ]; then
				printf "${S_ERR_1}" "${rl_dev_code}"
				return 1
			fi
		fi
		if [ -z "${ndl}" ]; then
			printf "${S_ERR_1}" "${rl_dev_code}"
			return 1
		fi
		
		
		awk_script__='
		BEGIN { cndl="'"${ndl}"'" }
		{
			mpos=match($0,""cndl)
			if(mpos==0) print
		}'
		
		
		if [ ${isfileinput} -eq 0 ]; then
			${SHLIBS_AWK} "${awk_script__}" <"${filepath}"
		else
			echo "${str}" | ${SHLIBS_AWK} "${awk_script__}"
		fi
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

str055_help() {
	echo 'Delete from output lines containing needle in string/file.'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
	echo ' - needle (can be BRE i.e. "^\\(test\\|probe\\)\\(.\\)*$")'
}

str055_examples() {
	echo 'string=$(printf "%b" "This is the >>first<< line.\\n\\nSecond .?=line..,, here.\\nThird% #%li,ne-from-aliens.k; here.")'
	echo 'shlibs str055 "${string}" aliens'
	echo 'Result: '
	printf "%b" 'This is the >>first<< line.\n\nSecond .?=line..,, here.\n'	
}

str055_tests() {
	tests__='
shlibs str055 -f "$(shlibs -p tst005)" "text|needle|^$" | head -n 3
=======
other shlibs libraries.
It contains empty lines
right here.
'
	echo "${tests__}"
}
