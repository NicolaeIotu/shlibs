#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

trm001_cursor_x=0
export trm001_cursor_x
trm001_cursor_y=0
export trm001_cursor_y

# terminal characteristics
if [ -z "${SHLIBS_TERM_DEF}" ]; then
	SHLIBS_TERM_DEF=$(stty -g) || {
		echo "Cannot get terminal characteristics (${rl_dev_code})."
		return 1
	}
	export SHLIBS_TERM_DEF
fi

trm001_instructions='No redirection or subshell ops allowed! 
1. Get the script path using: trm001_path=$(shlibs -p trm001)
2. Source the script using: . "${trm001_path}"
3. Update cursor position: trm001
4. Use vars "trm001_cursor_x" and "trm001_cursor_y".
(steps 3 and 4 must be repeated in order to update cursor position)'

trm001() {
	if [ ${#} -eq 0 ]; then
		if [ -t 0 ] || [ -t 1 ]; then :
		else
			echo "${rl_dev_code} requires a terminal."
			return 1
		fi
		
		if [ -p "/dev/fd/1" ]; then
			echo "${trm001_instructions}"
			return 1
		fi

		stty -icanon -echo min 0 time 1 || {
			echo "Cannot tune terminal characteristics (${rl_dev_code})."
			return 1
		}
		
		printf "\033[6n" 
		coord=$(dd count=1 2>/dev/null)
		coord=${coord%R*}
		coord=${coord##*\[}
		trm001_cursor_x=${coord##*;}
		trm001_cursor_y=${coord%%;*}
		stty ${SHLIBS_TERM_DEF}
		
		if ( [ ${trm001_cursor_x} -ge 0 ] && \
			[ ${trm001_cursor_y} -ge 0 ] ) 2>/dev/null ; then :
		else
			echo "Unable to get cursor position! System not responding."
			return 1
		fi
	else
		echo "${trm001_instructions}"
		return 1
	fi
}

trm001_help() {
	echo 'Get cursor position in terminal (u.o.m. characters)'
	echo '(sets trm001_cursor_x and trm001_cursor_y)'
	echo 'Usage:'
	echo ' - get trm001 path using -p flag'
	echo ' - source trm001 using the path obtained above'
	echo ' - update cursor position by calling function "trm001"'
	echo ' - important! "trm001" call result should be success (0)'
	echo ' - use $trm001_cursor_x and $trm001_cursor_y in your script'
	echo ' - see the examples "shlibs -x trm001"'
}

trm001_examples() {
	echo '# make sure you are not running on a C shell (BSDs -> exec /bin/sh)'
	echo 'trm001_path="$(shlibs -p trm001)"'
	echo '. "${trm001_path}"'
	echo '# below checks for the success of update operation'
	echo 'if trm001 ; then'
	echo '   echo "${trm001_cursor_x}"'
	echo '   echo "${trm001_cursor_y}"'
	echo 'fi'
	echo 'Result: '
	echo '1'
	echo '4'
}

trm001_skip_tests=0
