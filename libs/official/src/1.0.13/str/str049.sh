#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str049() {
	if [ ${#} -gt 1 ]; then
		base=''
		str=''
		
		if [ -n "${1}" ] && [ -n "${2}" ]; then
			base="${1}"
			shift
			
			echo "${@}${base}"
		else
			printf "${S_ERR_1}" "${rl_dev_code}"
			return 1
		fi
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

str049_help() {
	echo 'Append string forward of the first specified string (prepend).'
	echo 'Parameters:'
	echo ' - base string'
	echo ' - string to prepend'
}

str049_examples() {
	echo 'shlibs str049 "rocks" "^^" "shlibs "'
	echo 'Result:'
	echo '^^ shlibs rocks'
}

str049_tests() {
	tests__='
shlibs str049 "rocks" "^^" "str049 "
=======
^^ str049 rocks
'
	echo "${tests__}"
}
