#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str026() {
	if [ ${#} -gt 1 ]; then
		isfileinput=1
		filepath=''
		str=''
		bw='-s'
		size=0
		
		while [ ${#} -gt 0 ]
		do
			case ${1} in
				-b)
					bw=''
					shift
				;;
				[1-9]|[1-9][0-9]*)
					if [ ${size} -ne 0 ]; then
						if [ -n "${str}" ]; then
							printf "${S_ERR_1}" "${rl_dev_code}"
							return 1
						else
							str="${1}"
						fi
					else
						size=${1}
					fi
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
					fi
					str="${1}"
					shift
				;;
			esac
		done
		
		
		if [ ${size} -lt 1 ]; then
			printf "${S_ERR_1}" "${rl_dev_code}"
			return 1
		fi
		if [ ${isfileinput} -eq 0 ]; then
			if [ -n "${str}" ]; then
				printf "${S_ERR_1}" "${rl_dev_code}"
				return 1
			fi
		else
			if [ -z "${str}" ]; then
				printf "${S_ERR_1}" "${rl_dev_code}"
				return 1
			fi
		fi
		
		# Minix requirement
		awk_script__='
		{
			match($0,"["ENVIRON["SHLIBS_CCLASS_SPACE"]"]*$")
			print (RSTART>0?substr($0,1,RSTART-1):$0)
		}'	
		
		if [ ${isfileinput} -eq 0 ]; then
			fold ${bw} -w ${size} "${filepath}" | ${SHLIBS_AWK} "${awk_script__}"
		else
			echo "${str}" | fold ${bw} -w ${size} | ${SHLIBS_AWK} "${awk_script__}"
		fi
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

str026_help() {
	echo 'Fold/wrap string/file to specified size (align left).'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
	echo ' - wrap size (first integer supplied is taken as wrap size)'
	echo ' - use -b to break words (optional)'
}


str026_examples() {
	echo 'shlibs str026 "A string used to test wrapping of text with shlibs str026" 24'
	echo 'Result: '
	echo 'A string used to test'
	echo 'wrapping of text with'
	echo 'shlibs str026'
}

str026_tests() {
	tests__='
shlibs str026 "A string used to test wrapping of text with str026" 24
=======
A string used to test
wrapping of text with
str026


shlibs str026 -f "$(shlibs -p tst005)" 16 | head -3
=======
This is
multiline
sample text
'
	echo "${tests__}"
}
