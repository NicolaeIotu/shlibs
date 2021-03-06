#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str067() {
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
		BEGIN { ccount=0; lcount=0 } 
		{ 
			if(skipempty==0 && length==0) next
			ccount+=length
			lcount+=1
		} 
		END { print ccount/lcount }'

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

str067_help() {
	echo 'Returns the average number of chars per line of string/file.'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
	echo ' - use -skipempty to leave empty lines out of calculation (optional)'
}

str067_examples() {
	echo 'shlibs str067 "$(shlibs tst002)"'
	echo 'Result:'
	echo '21.2353'
}

str067_tests() {
	tests__='
shlibs str067 "$(shlibs tst002)"
=======
21.1176


shlibs str067 -f "$(shlibs -p tst005)" -skipempty
=======
24.5
'
	echo "${tests__}"
}
