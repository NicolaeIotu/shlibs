#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str016() {	
	if [ ${#} -gt 1 ]; then
		isfileinput=1
		filepath=''
		str=''
		start=0
		end=0
		
		while [ ${#} -gt 0 ]
		do
			case ${1} in
				[1-9]|[1-9][0-9]*|-[1-9]|-[1-9][0-9]*)					
					if [ ${start} -eq 0 ]; then
						start=${1}
					else
						if [ ${end} -ne 0 ]; then
							if [ -n "${str}" ]; then
								printf "${S_ERR_1}" "${rl_dev_code}"
								return 1
							fi
							str="${1}"
						else
							end=${1}
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
		
		if [ ${end} -lt 0 ]; then
			end=$((${strlen}+${end}+1))
		fi
		if [ ${end} -lt 0 ]; then
			echo "Invalid index: ${end}"
			return 1
		fi
		if [ ${end} -eq 0 ]; then
			end=${strlen}
		fi		
		
		if [ ${start} -gt ${end} ]; then
			tmp=${start}
			start=${end}
			end=${tmp}
		fi
		
		if [ ${end} -gt ${strlen} ]; then
			echo "Invalid index: ${end}"
			return 1
		fi
		
		# same script as str018
		awk_script__='BEGIN { got_start=1; r_start_index=1 }
			{
				r_end_index=r_start_index+length
				if (got_start==1 && r_end_index>=start) {
					if (r_end_index>start) {
						print substr($0,start-r_start_index+1,end-start+1)
					} else print ""
					if (end<r_end_index) exit
					got_start=0
				} else if(end <= r_end_index) {
					print substr($0,1,end-r_start_index+1)
					if (end<r_end_index) exit
				} else if(got_start==0) print
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

str016_help() {
	echo 'Returns portion of string/file between index1 and index2 (end).'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
	echo ' - start index (1 based, included, can be negative)'
	echo ' - end index (optional, 1 based, included, can be negative)'
	echo '   (indexes can swap position)'
}

str016_examples() {
	echo 'teststring="A test string used to test shlibs str016"'
	echo 'shlibs str016 "${teststring}" -7 8'
	echo 'Result:'
	echo 'string used to test shlibs '
}

str016_tests() {
	tests__='
shlibs str016 "A test string used to test str016" -7 8
=======
string used to test 


shlibs str016 -f "$(shlibs -p tst005)" 19 103
=======
sample text
It contains moderate amounts of text and can be used to test
other shlibs
'
	echo "${tests__}"
}
