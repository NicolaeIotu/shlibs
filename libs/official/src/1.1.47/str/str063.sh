#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str063() {
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
					fi
					str="${1}"
					shift
				;;
			esac
		done
		
		if [ ${isfileinput} -eq 1 ] && [ -z "${str}" ]; then
			echo "Invalid string."
			return 1
		fi	
		
		awk_script__='{
			tcfline=""
			for(i=1;i<=NF;i++){
				tcfline=tcfline toupper(substr($i,1,1)) substr($i,2)
				if (i!=NF) {
					tcfline=tcfline " "
				}
			}
			if (tcfline!=$0) exit 1
		}'
		
		if [ ${isfileinput} -eq 0 ]; then
			${SHLIBS_AWK} "${awk_script__}" <"${filepath}"
		else
			echo "${str}" | ${SHLIBS_AWK} "${awk_script__}"
		fi
		return ${?}
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

str063_help() {
	echo 'Titlecase check - words first letter is Uppercase in string/file.'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
}

str063_examples() {
	echo 'shlibs str063 "A String Used To Test Shlibs Str063."'
	echo 'echo ${?}'
	echo 'Result: 0'
}

str063_tests() {
	tests__='
shlibs str063 "A String Used To Test Shlibs Str063." ; echo ${?}
=======
0


shlibs str063 -f "$(shlibs -p str007)" ; echo ${?}
=======
1
'
	echo "${tests__}"
}
