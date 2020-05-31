#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str032() {
	if [ ${#} -gt 0 ]; then
		isfileinput=1
		filepath=''
		str=''
		interpret=1
		
		while [ ${#} -gt 0 ]
		do
			case ${1} in
				-interpret)
					interpret=0
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
		
		
		if [ ${isfileinput} -eq 0 ]; then
			wlen=$(wc -w "${filepath}")
			wlen="$(expr "${wlen}" : " *\(.*\)$")"
			wlen=${wlen%% *}
		else
			if [ -z "${str}" ]; then
				printf "${S_ERR_1}" "${rl_dev_code}"
				return 1
			fi
			wlen=$(echo "${str}" | wc -w | xargs echo)
		fi
		
		if [ ${interpret} -eq 0 ]; then
			if [ ${isfileinput} -eq 0 ]; then
				res=$("${shlibs_dirpath}"/shlibs str024 -f "${filepath}" "[a-zA-Z]['\`][a-zA-Z]")
			else
				res=$(echo "${str}" | "${shlibs_dirpath}"/shlibs str024 "[a-zA-Z]['\`][a-zA-Z]")
			fi
			
			res=$((res+wlen))
			echo ${res}
		else
			echo ${wlen}
		fi
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

str032_help() {
	echo 'Count words in string/file.'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
	echo ' - use "-interpret" to detect and count contractions such as "that`s"'
}


str032_examples() {
	echo 'shlibs str032 "A test string used to test str032."'
	echo 'Result: 7'
}

str032_tests() {
	tests__='
shlibs str032 "A test string used to test str032."
=======
7


shlibs str032 -f "$(shlibs -p tst005)" -interpret
=======
79
'
	echo "${tests__}"
}
