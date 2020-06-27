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
		
		awk_script_lastvalidline='BEGIN { lvl=1 }
		{ match($0,"^["ENVIRON["SHLIBS_CCLASS_SPACE"]"]*$"); if(RSTART==0) lvl=NR }
		END { print lvl }'
		
		awk_script__='
		{ 	
			if(NR<lvl) print;
			else if(NR==lvl) { sub("["ENVIRON["SHLIBS_CCLASS_SPACE"]"]*$",""); print }
			else exit 
		}'		
		
		if [ ${isfileinput} -eq 0 ]; then
			lvl=$(${SHLIBS_AWK} "${awk_script_lastvalidline}" <"${filepath}")
			${SHLIBS_AWK} -v lvl="${lvl}" "${awk_script__}" <"${filepath}"
		else
			lvl=$(echo "${str}" | ${SHLIBS_AWK} "${awk_script_lastvalidline}")
			echo "${str}" | ${SHLIBS_AWK} -v lvl="${lvl}" "${awk_script__}"
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


${SHLIBS_TAIL} -n 2 "$(shlibs -p tst008)" | shlibs str023
=======
at the beginning and 
at the end of it
'
	echo "${tests__}"
}
