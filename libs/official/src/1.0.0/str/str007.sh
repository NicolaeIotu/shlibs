#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str007() {
	if [ ${#} -gt 1 ]; then
		isfileinput=1
		filepath=''
		str=''	
		pos=0
		
		while [ ${#} -gt 0 ]
		do
			case ${1} in
				[1-9]|[1-9][0-9]*|-[1-9]|-[1-9][0-9]*)
					if [ ${pos} -eq 0 ]; then
						pos=${1}
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
		if [ ${pos} -eq 0 ]; then
			printf "${S_ERR_1}" "${rl_dev_code}"
			return 1
		fi		
		
		
		if [ ${isfileinput} -eq 0 ]; then
			strlen=$(wc -m "${filepath}")
			strlen="$(expr "${strlen}" : " *\(.*\)$")"
			strlen=${strlen%% *}
			strlen=$((strlen-1))
			
			cnl=$(wc -l "${filepath}" | xargs echo)
		else
			strlen=${#str}
			
			cnl=$(printf "${str}" | wc -l | xargs echo)
		fi
		cnl="$(expr "${cnl}" : " *\(.*\)$")"
		cnl=${cnl%% *}
	
		
		if [ ${pos} -lt 0 ]; then
			pos=$((strlen+pos))			
		else
			pos=$((pos-1))
		fi
		
		if [ ${cnl} -gt 0 ]; then
			pos=$((pos+1))
		fi
		
		
		if [ ${pos} -lt 0 ] || [ ${pos} -gt ${strlen} ]; then
			printf "${S_ERR_1}" "${rl_dev_code}"
			return 1
		fi
		
		if [ ${isfileinput} -eq 0 ]; then
			dd bs=1 count=1 skip=${pos} if="${filepath}" 2>/dev/null
		else
			expr "${str}" : ".\{${pos}\}\(.\)"
		fi
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

str007_help() {
	echo 'Returns the character at specified index in string/file.'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
	echo ' - slice index, 1 based (can be negative e.g. -1 i.e. last slice)'
}

str007_examples() {
	echo 'teststring="CharAt eXample!"'
	echo 'shlibs str007 "${teststring}" 9'
	echo 'Result: X'
	echo 'shlibs str007 "${teststring}" -7'
	echo 'Result: X'
}

str007_tests() {
	tests__='
shlibs str007 "CharAt eXample!" 9
=======
X


shlibs str007 "CharAt eXample!" -7
=======
X


shlibs str007 -f "$(shlibs -p tst006)" -2
=======
h
'
	echo "${tests__}"
}
