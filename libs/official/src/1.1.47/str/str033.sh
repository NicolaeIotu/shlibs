#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str033() {
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
		
		
		if [ ${isfileinput} -eq 0 ]; then :
		else
			if [ -z "${str}" ]; then
				printf "${S_ERR_1}" "${rl_dev_code}"
				return 1
			fi
		fi
		
		
		awk_script__='
		{
			n=split($0, larr, sprintf("%s", "\012"))
			if(isfile==0) n+=1
			for(i=n-1; i>0; i--){
				print larr[i]
			}
			exit
		}'
		
		if [ ${#str} -gt 1 ] || [ ${isfileinput} -eq 0 ]; then
			if [ ${isfileinput} -eq 0 ]; then
				${SHLIBS_AWK} -v RS='\003' -v isfile="${isfileinput}" \
					"${awk_script__}" <"${filepath}"
			else
				echo "${str}" | ${SHLIBS_AWK} -v RS='\003' \
					-v isfile="${isfileinput}" "${awk_script__}"
			fi	
		else
			printf "${S_ERR_1}" "${rl_dev_code}"
			return 1
		fi
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

str033_help() {
	echo 'Reverse order of lines in string/file.'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
}


str033_examples() {
	echo 'string=$(printf "%b" "This is the first line.\\nSecond line here.\\nThird one here.")'
	echo 'shlibs str033 "${string}"'
	echo 'Result: '
	printf "%b" 'Third one here.\nSecond line here.\nThis is the first line.\n'
}

str033_tests() {
	tests__='
shlibs str033 -f "$(shlibs -p tst006)" | ${SHLIBS_TAIL} -n 2
=======
right
needle
'
	echo "${tests__}"
}
