#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str019() {
	if [ ${#} -gt 1 ]; then
		isfileinput=1
		filepath=''
		str=''
		start=0
		len=0
		repl_seq=''
		
		while [ ${#} -gt 0 ]
		do
			case ${1} in
				[1-9]|[1-9][0-9]*|-[1-9]|-[1-9][0-9]*)					
					if [ ${start} -eq 0 ]; then
						start=${1}
					else
						if [ ${1} -lt 0 ]; then
							echo "Invalid negative length."
							return 1
						fi
						if [ ${len} -ne 0 ]; then
							if [ -n "${str}" ]; then
								if [ -n "${repl_seq}" ]; then
									printf "${S_ERR_1}" "${rl_dev_code}"
									return 1
								else
									repl_seq="${1}"
								fi
							else
								str="${1}"
							fi
							
						else
							len=${1}
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
						repl_seq="${1}"
					else
						if [ -n "${str}" ]; then
							repl_seq="${1}"
						else
							str="${1}"
						fi
					fi
					shift
				;;
			esac
		done
				
		
		if [ ${isfileinput} -eq 0 ]; then
			strlen=$(wc -m "${filepath}")
			strlen="$(expr "${strlen}" : " *\(.*\)$")"
			strlen=${strlen%% *}
			strlen=$((strlen-1))
		else
			if [ -z "${str}" ]; then
				echo 'Missing string.'
				return 1
			fi
			strlen=${#str}
		fi
		
		
		if [ ${start} -lt 0 ]; then
			start=$((${strlen}+${start}+1))
		fi
		if [ ${start} -lt 1 ]; then
			echo "Invalid index: ${start}"
			return 1
		fi
		
		end=$((start+len-1))
		if [ ${len} -eq 0 ] || [ ${end} -gt ${strlen} ]; then
			end=${strlen}
		fi
		
		awk_script__='
		{
			print substr($0,1,start-1) ENVIRON["repl_seq"] substr($0,end+1)
			exit
		}'
		
		export repl_seq
		if [ ${isfileinput} -eq 0 ]; then
			${SHLIBS_AWK} -v RS='\003' -v start="${start}" -v end="${end}" \
				"${awk_script__}" <"${filepath}"
		else
			echo "${str}" | ${SHLIBS_AWK} -v RS='\003' -v start="${start}" \
				-v end="${end}" "${awk_script__}"
		fi	
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

str019_help() {
	echo 'Replaces portion of string/file defined by start and length(end).'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
	echo ' - start index (1 based, included, can be negative)'
	echo ' - length (optional, integer, 1 based, included, pozitive)'
	echo ' - replacement string'
}

str019_examples() {
	echo 'teststring="A test string used to test shlibs str019"'
	echo 'shlibs str019 "${teststring}" -18 4 "prove replacement using"'
	echo 'Result: '
	echo 'A test string used to prove replacement using shlibs str019'
}

str019_tests() {
	tests__='
shlibs str019 "A test string used to test str019" -11 4 "prove replacement using"
=======
A test string used to prove replacement using str019


shlibs str019 4 4 1231111321 shlibs
=======
123shlibs321


shlibs str019 -f "$(shlibs -p tst005)" 9 89 "" | head -n 2
=======
This is shlibs libraries.
You can test this file using needles spanning over multiple lines of text.
'
	echo "${tests__}"
}
