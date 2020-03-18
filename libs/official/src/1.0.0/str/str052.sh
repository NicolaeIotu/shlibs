#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str052() {
	if [ ${#} -gt 0 ]; then
		isfileinput=1
		filepath=''
		str=''
		size=4
		gotsize=1
		
		while [ ${#} -gt 0 ]
		do
			case ${1} in
				[0-9]|[1-9][0-9]*)
					if [ ${gotsize} -eq 1 ]; then
						size=${1}
						gotsize=0
					else
						if [ -n "${str}" ]; then
							printf "${S_ERR_1}" "${rl_dev_code}"
							return 1
						else
							str="${1}"
						fi
					fi
					shift
				;;
				-f)
					if [ -n "${str}" ] || [ ${isfileinput} -eq 0 ]; then
						echo "${S_ERR_2}"
						return 1
					fi
					if [ -n "${2}" ] && [ -r "${2}" ]; then
						isfileinput=0
						filepath="${2}"
						shift 2
					else
						echo "Invalid file '${2}'"
						return 1
					fi
				;;
				*)
					if [ ${isfileinput} -eq 0 ]; then
						echo "${S_ERR_2}"
						return 1
					fi
					if [ -n "${str}" ]; then
						printf "${S_ERR_1}" "${rl_dev_code}"
						return 1
					else
						str="${1}"
					fi
					shift
				;;
			esac
		done
		
		
		if [ ${isfileinput} -eq 0 ]; then :
		else
			if [ -z "${str}" ]; then
				printf "${S_ERR_1}" "${rl_dev_code}"
				return 1
			fi
		fi
		
		i=0
		seq=''
		while [ ${i} -lt ${size} ]
		do
			seq="${seq} "
			i=$((i+1))
		done
		
		stab="$(printf '%b' '\t')"
		#echo ">>$stab<<"
		#return
		
		if [ ${isfileinput} -eq 0 ]; then
			sed "s/${stab}/${seq}/g" "${filepath}"
		else
			echo "${str}" | sed "s/${stab}/${seq}/g"
		fi
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

str052_help() {
	echo 'Expands tabs to spaces (default 4 spaces per tab).'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
	echo ' - integer to indicate the number of spaces per tab'
	echo '   (optional, just the first integer supplied is taken into account)'
}

str052_examples() {
	echo 'shlibs str052 "$(printf "%b\n" "Text \\twith \\t\\ttabs\\t.")" 8'
	echo 'Result: '
	echo 'Text         with                 tabs        .'
}

str052_tests() {
	printf '
shlibs str052 "%s" 8
=======
Text         with                 tabs        .


shlibs str052 -f "$(shlibs -p tst008)" | head -n 1
=======
            A multiline test file
\n' "$(printf '%b\n' 'Text \twith \t\ttabs\t.')"


}
