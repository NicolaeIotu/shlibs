#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str041() {
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
			cnl=$(wc -l "${filepath}" | xargs echo)
		else
			if [ -z "${str}" ]; then
				printf "${S_ERR_1}" "${rl_dev_code}"
				return 1
			fi
			cnl=$(printf "${str}" | wc -l | xargs echo)
		fi
		cnl="$(expr "${cnl}" : " *\(.*\)$")"
		echo ${cnl%% *}
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

str041_help() {
	echo 'Count newlines in string/file.'
	echo 'Parameters:'
	echo 'Subject string, or "-f /path/to/text/file" to process file content'
}


str041_examples() {
	echo 'string=$(printf "%b" "This is the first line.\\nSecond line here.\\nThird one here.")'
	echo 'shlibs str041 "${string}"'
	echo 'Result: 3'
}

str041_tests() {
	tests__='
shlibs str041 -f "$(shlibs -p tst005)"
=======
22

shlibs str041 "A test string"
=======
0
'
	echo "${tests__}"
}
