#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str009() {
	if [ ${#} -gt 1 ]; then
		if [ "${1}" = "${2}" ]; then
			return
		fi
		
		isfileinput=1
		filepath=''
		str=''
		ndl=''
		iflag=''
		
		while [ ${#} -gt 0 ]
		do			
			case ${1} in
				-i)
					iflag='-i'
					shift
					;;
				-f)
					if [ ${isfileinput} -eq 0 ]; then
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
					if [ -n "${str}" ]; then
						ndl="${1}"
					else
						str="${1}"
					fi
					shift
			esac
		done
		
		
		if [ ${isfileinput} -eq 0 ]; then
			if [ -n "${str}" ]; then
				if [ -n "${ndl}" ]; then
					printf "${S_ERR_1}" "${rl_dev_code}"
					return 1
				else
					ndl="${str}"
					str=''
				fi				
			fi
		else
			if [ -z "${str}" ]; then
				printf "${S_ERR_1}" "${rl_dev_code}"
				return 1
			fi
		fi
		if [ -z "${ndl}" ]; then
			printf "${S_ERR_1}" "${rl_dev_code}"
			return 1
		fi
		
		
		if [ ${isfileinput} -eq 0 ]; then
			strlen=$(wc -m "${filepath}")
			strlen="$(expr "${strlen}" : " *\(.*\)$")"
			strlen=${strlen%% *}
			strlen=$((strlen-1))
		else
			strlen=${#str}
		fi
		ndllen=${#ndl}
		if [ ${strlen} -lt ${ndllen} ]; then
			return 1
		fi
		
		
		if [ ${isfileinput} -eq 0 ]; then			
			skip_size=$((strlen-ndllen))
			dd bs=1 skip=${skip_size} if="${filepath}" 2>/dev/null | \
				${SHLIBS_GREP} ${iflag} -E "^${ndl}$" >/dev/null 2>&1
		else
			expr "${str}" : ".*\(.\{${ndllen}\}\)$" | \
				${SHLIBS_GREP} ${iflag} -E "^${ndl}$" >/dev/null 2>&1
		fi
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

str009_help() {
	echo 'Checks if string ends with the characters of another string.'
	echo 'Parameters:'
	echo ' - reference string/file'
	echo ' - test characters (end string, needle, ERE less s/c ^ and $)'
	echo ' - case insensitive search flag "-i" (optional)'
}

str009_examples() {
	echo 'txt="A nice text with needle and other stuff."'
	echo 'shlibs str009 "${txt}" "stuff."'
	echo 'echo ${?}'
	echo 'Result: 0'
}

str009_tests() {
	tests__='
shlibs str009 "$(shlibs tst003)" "needles all over." ; echo ${?}
=======
1


shlibs str009 "$(shlibs tst003)" "needles all over." -i ; echo ${?}
=======
0


shlibs str009 -f "$(shlibs -p tst005)" "you!" ; echo ${?}
=======
0
'
	echo "${tests__}"
}
