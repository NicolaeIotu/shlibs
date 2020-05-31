#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str068() {
	if [ ${#} -gt 0 ]; then
		isfileinput=1
		filepath=''
		str=''
		skipempty=1
		
		while [ ${#} -gt 0 ]
		do
			case ${1} in
				-skipempty)
					skipempty=0
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
		
		
		awk_script__ml='
		{ 
			if(skipempty==0) {
				if(length==0) next
			} else {
				if(length==0) {
					minlen=0
					exit
				}
			}
			if (NR==1 || length<minlen) minlen=length
		} 
		END { print minlen }'

		if [ ${isfileinput} -eq 0 ]; then				
			${SHLIBS_AWK} -v skipempty="${skipempty}" "${awk_script__ml}" \
				<"${filepath}"
		else
			echo "${str}" | ${SHLIBS_AWK} -v skipempty="${skipempty}" \
				"${awk_script__ml}"
		fi
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

str068_help() {
	echo 'Returns minimum number of chars per line of string/file.'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
	echo ' - use -skipempty to leave empty lines out of calculation (optional)'
}

str068_examples() {
	echo 'shlibs str068 "$(shlibs tst002)"'
	echo 'Result:'
	echo '21.2353'
}

str068_tests() {
	tests__='
shlibs str068 "$(shlibs tst002)"
=======
0


shlibs str068 -f "$(shlibs -p tst005)" -skipempty
=======
3
'
	echo "${tests__}"
}
