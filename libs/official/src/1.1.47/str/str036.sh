#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str036() {
	if [ ${#} -gt 2 ]; then
		isfileinput=1
		filepath=''
		str=''
		target=''
		transl=''
		
		while [ ${#} -gt 0 ]
		do
			case ${1} in
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
					if [ ${isfileinput} -eq 1 ] && [ -z "${str}" ]; then
						str="${1}"
					else
						if [ -n "${target}" ]; then
							transl="${1}"
						else
							target="${1}"
						fi
					fi
					shift
				;;
			esac
		done
		
		
		if [ -z "${target}" ] || [ -z "${transl}" ]; then
			echo 'Invalid translation.'
			return 1
		fi
		
		if [ "${target}" = "${transl}" ]; then
			if [ ${isfileinput} -eq 0 ]; then
				cat "${filepath}"
			else
				echo "${str}"
			fi
			return
		fi
				
		
		if [ ${isfileinput} -eq 0 ]; then
			tr "${target}" "${transl}" <"${filepath}"
		else
			echo "${str}" | tr "${target}" "${transl}"
		fi
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

str036_help() {
	echo 'Translate characters in string/file.'
	echo 'Parameters ordered as follows:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
	echo ' - targeted characters'
	echo ' - translation characters'
	echo '("abc" "xyz", will translate "a" to "x", "b" to "y" and "c" to "z")'
}

str036_examples() {
	echo 'teststring="A test string used to test str036"'
	echo 'shlibs str036 "${teststring}" "gue" "GU "'
	echo 'Result: '
	echo 'A t st strinG Us d to t st str036'
}

str036_tests() {
	tests__='
shlibs str036 "A test string used to test str036" "gue" "GU "
=======
A t st strinG Us d to t st str036


shlibs str036 -f "$(shlibs -p tst006)" "ne" "No"
=======
Noodlo
right
'
	echo "${tests__}"
}
