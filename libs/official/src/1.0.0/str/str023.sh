#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str023() {
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
		BEGIN { cspace="['"${SHLIBS_CCLASS_SPACE}"']*$" }
		{
			if(NR==cnl) sub(""cspace,"")
			print
		}'		
		
		if [ ${isfileinput} -eq 0 ]; then
			cnl=$(wc -l "${filepath}" | xargs echo)
			cnl="$(expr "${cnl}" : " *\(.*\)$")"
			cnl=${cnl%% *}
			cnl=$((cnl+1))
			${SHLIBS_AWK} -v cnl="${cnl}" "${awk_script__}" <"${filepath}"
		else
			cnl=$(echo "${str}" | wc -l | xargs echo)
			cnl=${cnl% *}
			echo "${str}" | ${SHLIBS_AWK} -v cnl="${cnl}" "${awk_script__}"
		fi
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

str023_help() {
	echo 'Trim whitespace from the end of string/file.'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
}


str023_examples() {
	echo 'result=$(shlibs str023 "  trim right   whitespace subject  string   ")'
	echo 'echo ">>${result}<<"'
	echo 'Result:'
	echo '>>  trim right   whitespace subject  string<<'
}

str023_tests() {
	tests__='
shlibs str023 "  trim right   whitespace subject  string   "
=======
  trim right   whitespace subject  string


shlibs str023 -f "$(shlibs -p tst008)" | ${SHLIBS_TAIL} -n 2
=======
at the beginning and 
at the end of it
'
	echo "${tests__}"
}
