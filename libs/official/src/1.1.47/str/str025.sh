#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str025() {
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
					if [ -r "${2}" ]; then
						isfileinput=0
						filepath="${2}"
						shift 2
					else
						echo "Invalid file."
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
		
		
		if [ ${isfileinput} -eq 0 ]; then :
		else
			if [ -z "${str}" ]; then
				printf "${S_ERR_1}" "${rl_dev_code}"
				return 1
			fi
		fi
		
		
		awk_script__='
		{
			if (NR==1) {
				print toupper(substr($0,1,1)) substr($0,2)
			} else print
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

str025_help() {
	echo 'UpperCase the first single character of a whole string/file.'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
}

str025_examples() {
	echo 'shlibs str025 "make the first char in this string upper case (M)."'
	echo 'Result:'
	echo 'Make the first char in this string upper case (M).'
}

str025_tests() {
	tests__='
shlibs str025 "make the first char in this string upper case (M)."
=======
Make the first char in this string upper case (M).


shlibs str025 -f "$(shlibs -p tst006)"
=======
Needle
right
'
	echo "${tests__}"
}
