#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

file001() {
	if [ ${#} -eq 2 ] || [ ${#} -eq 3 ]; then
		filepath_1=''
		filepath_2=''
		iflag=1
		
		while [ ${#} -gt 0 ]
		do		
			case ${1} in
				-i)
					iflag=0
					shift
				;;
				*)
					if [ -r "${1}" ]; then
						if [ -z "${filepath_1}" ]; then
							filepath_1="${1}"
						else
							filepath_2="${1}"
						fi
					else
						echo "Invalid file '${1}'"
						return 2
					fi
					shift
				;;
			esac
		done
		
		if [ -z "${filepath_1}" ] || [ -z "${filepath_2}" ] ; then
			printf "${S_ERR_1}" "${rl_dev_code}"
			return 2
		fi
		
		export filepath_2
		${SHLIBS_AWK} -v iflag="${iflag}" \
		'{
			getline rec2 <ENVIRON["filepath_2"]
			if(iflag==0) {
				if(tolower($0) != tolower(rec2)) exit 1
			} else {
				if($0 != rec2) exit 1
			}
		}
		END { close(ENVIRON["filepath_2"]) }
		' <"${filepath_1}" 2>/dev/null
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 2
	fi
}

file001_help() {
	echo 'Checks if two files have the same content (+-case insensitive)'
	echo 'Parameters:'
	echo ' - path of the first file'
	echo ' - path of the second file'
	echo ' - case insensitive comparison "-i" (optional)'
	echo 'Returns 0 (test passed), 1 (test failed), or 2 (errors)'
}

file001_examples() {
	echo 'shlibs file001 "$(shlibs -p tst006)" "$(shlibs -p tst007)" -i'
	echo 'echo "${?}"'
	echo 'Result: 0'
}

file001_tests() {
	tests__='
shlibs file001 "$(shlibs -p tst006)" "$(shlibs -p tst007)" -i ; echo ${?}
=======
0
'
	echo "${tests__}"
}
