#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str022() {
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
		BEGIN { cspace="^['"${SHLIBS_CCLASS_SPACE}"']*" }
		{
			if(NR==1) sub(""cspace,"")
			print
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

str022_help() {
	echo 'Trim whitespace from the beginning of string/file.'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
}


str022_examples() {
	echo 'result=$(shlibs str022 "   trim left   whitespace subject  string  ")'
	echo 'echo ">>${result}<<"'
	echo 'Result:'
	echo '>>trim left   whitespace subject  string  <<'
}

str022_tests() {
	tests__='
echo ">>$(shlibs str022 "   trim left   whitespace subject  string  ")<<"
=======
>>trim left   whitespace subject  string  <<


shlibs str022 -f "$(shlibs -p tst008)" | head -n 2
=======
A multiline test file
containing spaces and tabs
'
	echo "${tests__}"
}
