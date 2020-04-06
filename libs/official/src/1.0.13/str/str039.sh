#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str039() {
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
		
		
		if [ ${isfileinput} -eq 0 ]; then :
		else
			if [ -z "${str}" ]; then
				printf "${S_ERR_1}" "${rl_dev_code}"
				return 1
			fi
		fi
		
		
		awk_script__='
		{
			lcfline=""
			for(i=1;i<=NF;i++){
				lcfline=lcfline tolower(substr($i,1,1)) substr($i,2)
				if (i!=NF) {
					lcfline=lcfline " "
				}
			}
			print lcfline
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

str039_help() {
	echo 'Lowercase first letter of each word in string/file.'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
}


str039_examples() {
	echo 'shlibs str039 "A TesT StrinG UseD To TesT ShlibS Str039."'
	echo 'Result: '
	echo 'a tesT strinG useD to tesT shlibS str039.'
}

str039_tests() {
	tests__='
shlibs str039 "A TesT StrinG UseD To TesT ShlibS Str039."
=======
a tesT strinG useD to tesT shlibS str039.


shlibs str039 -f "$(shlibs -p tst005)" | head -n 2
=======
this is multiline sample text
it contains moderate amounts of text and can be used to test
'
	echo "${tests__}"
}
