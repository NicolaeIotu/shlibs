#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str054() {
	if [ ${#} -gt 1 ]; then
		isfileinput=1
		filepath=''
		size=0
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
						echo "Invalid file '${2}'"
						return 1
					fi
				;;
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
		
		if [ ${size} -gt 0 ] && [ -n "${str}" ] || [ ${isfileinput} -eq 0 ]; then
			if [ ${isfileinput} -eq 0 ]; then
				str_size=$(wc -m "${filepath}")
				str_size="$(expr "${str_size}" : " *\(.*\)$")"
				str_size=${str_size%% *}
				str_size=$((str_size-1))
				if [ ${size} -lt ${str_size} ]; then
					${SHLIBS_AWK} -v r_start_length=0 \
						-v maxlen=$((str_size-size)) \
						'{
							cmp=r_start_length + length
							if (cmp >= maxlen) {
								print substr($0,1,maxlen-r_start_length+1)
								exit
							} else print
							r_start_length+=length+1
						}' <"${filepath}"
				else
					echo "Invalid size."
					return 1
				fi
			else
				if [ ${size} -lt ${#str} ]; then
					echo "${str}" | dd bs=1 count=$((${#str}-size)) 2>/dev/null
				else
					echo "Invalid size."
					return 1
				fi
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

str054_help() {
	echo 'Removes n characters from the end of the string/file.'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
	echo ' - the amount of chars to remove from end of string/file'
}

str054_examples() {
	echo 'shlibs str054 "A pretty short test string." 19'
	echo 'Result: '
	echo 'A pretty'
}

str054_tests() {
	tests__='
shlibs str054 "A pretty short test string." 19
=======
A pretty

shlibs str054 -f "$(shlibs -p tst006)" 4
=======
needle
r
'
	echo "${tests__}"
}
