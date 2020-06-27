#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str008() {
	if [ "${1}" = '-s' ]; then
		glue="${2}"
		shift 2
	else
		glue=''
	fi
	
	if [ ${#} -gt 1 ]; then
		result=''
		for part in "${@}"
		do
			if [ -n "${result}" ]; then
				result="${result}${glue}"
			fi
			result="${result}${part}"
		done
		echo "${result}"
	else
		echo 'Expecting 2 strings at least.'
		return 1
	fi
}

str008_help() {
	echo 'Concatenate/glue two or more strings (optional use characters to glue).'
	echo 'Parameters:'
	echo ' - minimum 2 strings to glue'
	echo ' - optional, use "-s glue_chars" to glue the strings using "glue_chars"'
	echo '   (use "-s glue_chars" before any other strings)'
	
}

str008_examples() {
	echo 'shlibs str008 "The first part" ", the second part" "..." ", n-th part."'
	echo 'Result: '
	echo 'The first part, the second part..., n-th part.'
}

str008_tests() {
	tests__='
shlibs str008 -s " times " One two three...
=======
One times two times three...
'
	echo "${tests__}"
}
