#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

file003() {
	if [ ${#} -gt 0 ] && [ ${#} -lt 3 ]; then
		filepath=''
		append_nl=1
	
		while [ ${#} -gt 0 ]
		do			
			case ${1} in
				-y)
					append_nl=0
					shift
				;;
				*)
					filepath="${1}"
					shift
				;;
			esac
		done
		
		if [ -f "${filepath}" ]; then
			lastline=$(${SHLIBS_TAIL} -n 1 "${filepath}")
			if [ "${lastline}" = '' ]; then
				return 0
			else
				if [ ${append_nl} -eq 0 ]; then
					if echo '' >> "${filepath}" ; then :
					else
						return 2
					fi
				else
					return 1
				fi
			fi
		else
			printf "${S_ERR_1}" "${rl_dev_code}"
			return 2
		fi
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 2
	fi
}

file003_help() {
	echo 'Checks if a file ends with new line (option to append new line)'
	echo 'Parameters:'
	echo ' - path of the file to be tested'
	echo ' - use "-y" to append a new line if missing from the end of the file'
	echo 'Returns 0 (test passed), 1 (test failed), or 2 (errors)'
}

file003_examples() {
	echo 'shlibs file003 "${testfile}"'
	echo 'echo ${?}'
	echo '# 0 if the file is missing a new line at the end'
	echo '# 1 if the file ends with a new line'
}

file003_tests() {
	tests__='
tmpfile="$(shlibs file002)"; printf teststring > "${tmpfile}"; shlibs file003 "${tmpfile}"; echo ${?}; rm -f "${tmpfile}"
=======
1
'
	echo "${tests__}"
}
