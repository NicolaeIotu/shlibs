#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str018() {
	if [ ${#} -gt 1 ]; then
		isfileinput=1
		filepath=''
		str=''
		start=0
		len=0
		
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
								printf "${S_ERR_1}" "${rl_dev_code}"
								return 1
							fi
							str="${1}"
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
					if [ ${isfileinput} -eq 0 ]; then
						echo "${S_ERR_2}"
						return 1
					fi
					if [ -n "${str}" ]; then
						printf "${S_ERR_1}" "${rl_dev_code}"
						return 1
					fi
					str="${1}"
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
		
		
		# same script as str016
		awk_script__='
			BEGIN { got_start=0; r_start_index=1 }
			{
				r_end_index=r_start_index+length
				if (got_start==0 && r_end_index>start) {
					print substr($0,start-r_start_index+1,end-start+1)
					if (end<r_end_index) exit
					got_start=1
				} else if(end <= r_end_index) {
					print substr($0,1,end-r_start_index+1)
					exit
				} else if(got_start==1) print
				r_start_index+=length+1
			}'
		
		if [ ${isfileinput} -eq 0 ]; then
			${SHLIBS_AWK} -v start="${start}" -v end="${end}" \
				"${awk_script__}" <"${filepath}"
		else
			echo "${str}" | ${SHLIBS_AWK} -v start="${start}" -v end="${end}" \
				"${awk_script__}"
		fi	
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

str018_help() {
	echo 'Returns portion of string/file defined by start and length (end).'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
	echo ' - start index (1 based, included, can be negative)'
	echo ' - length (optional, integer, 1 based, included, positive)'
}

str018_examples() {
	echo 'teststring="A test string used to test shlibs str018"'
	echo 'shlibs str018 "${teststring}" 28 6'
	echo 'Result: shlibs'
}

str018_tests() {
	tests__='
shlibs str018 "A test string used to test str018" 28 6
=======
str018


shlibs str018 "A test string used to test str018" -6
=======
str018


shlibs str018 -f "$(shlibs -p tst005)" -19
=======
for now.
Thank you!


shlibs str018 2 6 1234567891234
=======
234567
'
	echo "${tests__}"
}
