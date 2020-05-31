#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str044() {
	if [ ${#} -gt 1 ]; then
		iflag=''
		str1=''
		str2=''
		has_str1=1
		
		i=0
		mpc=3
		
		for prm in "${@}"
		do
			i=$((i+1))
			
			case ${prm} in
				-i)
					iflag='-i'
				;;
				*)
					if [ ${has_str1} -eq 0 ]; then
						str2="${prm}"
					else
						str1="${prm}"
						has_str1=0
					fi
				;;
			esac
			
			if [ ${i} -gt ${mpc} ]; then
				printf "${S_ERR_1}" "${rl_dev_code}"
				return 2
			fi
		done
		
		if [ "${iflag}" = '-i' ]; then
			str1="$(echo "${str1}" | dd conv=lcase 2>/dev/null)"
			str2="$(echo "${str2}" | dd conv=lcase 2>/dev/null)"
		fi
		
		test "${str1}" = "${str2}" || return 1
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 2
	fi
}

str044_help() {
	echo 'Checks if two strings are equal (+case insensitive option).'
	echo 'Parameters:'
	echo ' - first string'
	echo ' - second string'
	echo ' - case insensitive search flag "-i" (optional)'
	echo 'Returns 0 (test passed), 1 (test failed), or 2 (errors)'
}

str044_examples() {
	echo 'shlibs str044 "Base String" "base string" -i'
	echo 'echo ${?}'
	echo 'Result: 0'
}

str044_tests() {
	tests__='
shlibs str044 "Base String" "base string" -i ; echo ${?}
=======
0
'
	echo "${tests__}"
}
