#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str012() {
	if [ ${#} -eq 2 ]; then
		n=0
		seq=''
		
		for prm in "${@}"
		do
			case ${prm} in
				[1-9]|[1-9][0-9]*)
					if [ ${n} -ne 0 ]; then
						printf "${S_ERR_1}" "${rl_dev_code}"
						return 1
					fi
					n=${prm}
				;;
				*)
					if [ ${#prm} -gt 0 ]; then
						seq="${prm}"
					else
						echo "Invalid string."
						return 1
					fi
				;;
			esac
		done
		
		if [ ${n} -eq 0 ] || [ -z "${prm}" ]; then
			printf "${S_ERR_1}" "${rl_dev_code}"
			return 1
		fi
		
		result=$(dd if=/dev/zero bs=1 count=${n} 2>/dev/null | sed "s/./${seq}/g")		
		if [ ${#result} -eq $((${2} * ${#1})) ]; then
			echo "${result}"
		else
			# Solaris
			i=0
			result=''
			while [ ${i} -lt ${2} ]
			do
				result="${result}${1}"
				i=$((i+1))
			done
			echo "${result}"
		fi
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

str012_help() {
	echo 'Repeat character or sequence n times.'
	echo 'Parameters:'
	echo ' - string used for multiplication'
	echo ' - multiplication factor (integer greater than 1)'
}

str012_examples() {
	echo 'shlibs str012 "*" 12'
	echo 'Result:'
	echo '************'
}

str012_tests() {
	tests__='
res="$(shlibs str012 "*" 12)"; shlibs str065 "${res}" --*; echo "${?}${#res}"
=======
012
'
	echo "${tests__}"
}
