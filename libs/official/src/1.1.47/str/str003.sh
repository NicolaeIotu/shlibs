#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str003() {
	if [ ${#} -gt 1 ]; then
		isfileinput=1
		filepath=''
		str=''
		size=0
		
		while [ ${#} -gt 0 ]
		do			
			case ${1} in
				[1-9]|[1-9][0-9]*)
					if [ ${size} -eq 0 ]; then
						size=${1}
					else
						if [ -n "${str}" ]; then
							printf "${S_ERR_1}" "${rl_dev_code}"
							return 1
						else
							str="${1}"
						fi
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
						echo "Invalid file '${2}'"
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
		

		if [ ${isfileinput} -eq 0 ]; then :
		else
			if [ -z "${str}" ]; then
				printf "${S_ERR_1}" "${rl_dev_code}"
				return 1
			fi
		fi
		if [ ${size} -lt 1 ]; then
			printf "${S_ERR_1}" "${rl_dev_code}"
			return 1
		fi
		
		
		if [ ${isfileinput} -eq 0 ]; then
			strlen=$(wc -m "${filepath}")
			strlen="$(expr "${strlen}" : " *\(.*\)$")"
			strlen=${strlen%% *}
			strlen=$((strlen-1))
			
			if [ ${size} -ge ${strlen} ]; then
				cat "${filepath}"
			else
				dd bs=1 count=${size} 2>/dev/null <"${filepath}"
			fi
		else
			if [ ${size} -ge ${#str} ]; then
				echo "${str}"
			else
				echo "${str}" | dd bs=1 count=${size} 2>/dev/null
				#expr "${str}" : "\(.\{${size}\}\)"
			fi
		fi
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

str003_help() {
	echo 'Returns the first n characters in string/file.'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
	echo ' - the number of chars to return'
	echo '   (if more then one integer, the last one is taken into account as size)'
}

str003_examples() {
	echo 'string=$(printf "%b" "This is the first line.\\nSecond line here.\\nThird one here.")'
	echo 'string_left_28=$(shlibs str003 "${string}" 28)'
	echo 'echo "${string_left_28}"'
	echo 'Result:'
	printf "%b" '"This is the first line.\nSeco"\n'
}

str003_tests() {
	tests__='
shlibs str003 "A simple test string for shlibs str003" 13
=======
A simple test

shlibs str003 -f "$(shlibs -p tst005)" 17
=======
This is multiline
'
	echo "${tests__}"
}
