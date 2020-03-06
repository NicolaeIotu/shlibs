#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str014() {
	if [ ${#} -eq 3 ]; then
		str=''
		seq=''
		size=0
		
		while [ ${#} -gt 0 ]
		do
			case ${1} in
				[1-9]|[1-9][0-9]*)
					if [ ${size} -ne 0 ]; then
						printf "${S_ERR_1}" "${rl_dev_code}"
						return 1
					fi
					size=${1}
					shift
				;;
				*)
					if [ -n "${str}" ]; then
						seq="${1}"
					else
						str="${1}"
					fi
					shift
				;;
			esac
		done
		
		if [ ${size} -eq 0 ] || [ -z "ndl" ]; then
			printf "${S_ERR_1}" "${rl_dev_code}"
			return 1
		fi
		
		if [ ${size} -le ${#str} ]; then
			echo "${str}"
			return
		fi
		
		
		padsize=$((${size}-${#str}))
		mf=$((${padsize}/${#seq}+1))
		pad=$(dd if=/dev/zero bs=1 count=${mf} 2>/dev/null | sed "s/./${seq}/g")
		
		if [ ${#pad} -lt ${padsize} ]; then
			# Solaris
			i=0
			pad=''
			while [ ${i} -lt ${mf} ]
			do
				pad="${pad}${seq}"
				i=$((i+1))
			done
		fi
		pad=$(echo "${pad}" | cut -b -${padsize})
		
		echo "${pad}${str}"
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

str014_help() {
	echo 'Pads front of string/file with sequence until length is reached.'
	echo 'Parameters:'
	echo ' - base string'
	echo ' - padding string (must be specified after the base string)'
	echo ' - target length'
}


str014_examples() {
	echo 'teststring=$(shlibs str014 "base string" "." 24)'
	echo 'echo "${teststring}"'
	echo 'echo "length: ${#teststring}"'
	echo 'Results: '
	echo '.............base string'
	echo 'length: 24'
}

str014_tests() {
	tests__='
res=$(shlibs str014 "base string" "." 24) ; echo "${#res}${res%base string}"
=======
24.............
'
	echo "${tests__}"
}
