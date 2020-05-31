#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str031() {
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
		
		
		
		
		if [ ${isfileinput} -eq 0 ]; then :
		else
			if [ -z "${str}" ]; then
				printf "${S_ERR_1}" "${rl_dev_code}"
				return 1
			fi
		fi
		
		
		awk_script__='
		{
			if(length>2) {
				n=length
				str=substr($0,1,length)
				res=""
				
				srand()
				for(i=1; i<=n; i++) {
					x=int(rand()*length(str))+1
					res=res substr(str,x,1)
					str=substr(str,1,x-1) substr(str,x+1)
				}
				print res
			} else print substr($0,1,length)
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

str031_help() {
	echo 'Output shuffled characters of string/file.'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
}

str031_examples() {
	echo 'shuffled=$(shlibs str031 "string to shuffle")'
	echo 'echo ">>${shuffled}<<"'
	echo 'Result:'
	echo '>>uoheifssnrftg l t<<'
}

str031_tests() {
	tests__='
res="$(shlibs str031 "string to shuffle")" ; shlibs str065 "${res}" "--string to shuffle" ; echo ${?}
=======
0


res="$(shlibs str031 "string to shuffle")" ; shlibs str027 "${res}"
=======
17


fp="$(shlibs -p tst006)"; res="$(shlibs str031 -f "${fp}")" ; shlibs str027 "${res}"
=======
12
'
	echo "${tests__}"
}
