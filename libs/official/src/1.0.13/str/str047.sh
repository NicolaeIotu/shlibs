#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str047() {
	if [ ${#} -gt 1 ]; then
		isfileinput=1
		filepath=''
		str=''
		seq=''
		pos=0
		
		while [ ${#} -gt 0 ]
		do		
			case ${1} in
				[1-9]|[1-9][0-9]*|-[1-9]|-[1-9][0-9]*)					
					if [ ${pos} -ne 0 ]; then
						if [ -n "${str}" ]; then
							if [ -n "${seq}" ]; then
								printf "${S_ERR_1}" "${rl_dev_code}"
								return 1
							else
								seq="${1}"
							fi
						else
							str="${1}"
						fi
					else
						pos=${1}
					fi
					shift
				;;
				-f)
					if [ ${isfileinput} -eq 0 ]; then
						echo "${S_ERR_2}"
						return 1
					fi
					if [ -n "${2}" ] && [ -r "${2}" ]; then
						isfileinput=0
						filepath="${2}"
						shift 2
					else
						echo "Invalid file."
						return 1
					fi
				;;
				*)
					if [ -n "${str}" ]; then
						if [ -n "${seq}" ]; then
							shift
							continue
						fi
						seq="${1}"
					else
						str="${1}"
					fi
					shift
				;;
			esac
		done
		
		
		if [ ${pos} -eq 0 ]; then
			printf "${S_ERR_1}" "${rl_dev_code}"
			return 1
		fi
		if [ ${isfileinput} -eq 0 ]; then
			if [ -n "${str}" ]; then
				if [ -n "${seq}" ]; then
					printf "${S_ERR_1}" "${rl_dev_code}"
					return 1
				else
					seq="${str}"
					str=''
				fi				
			fi
		else
			if [ -z "${str}" ]; then
				printf "${S_ERR_1}" "${rl_dev_code}"
				return 1
			fi
		fi
		if [ -z "${seq}" ]; then
			if [ ${isfileinput} -eq 0 ]; then
				cat "${filepath}"
			else
				echo "${str}"
			fi
		fi
		

		if [ ${isfileinput} -eq 0 ]; then
			strlen=$(wc -m "${filepath}")
			strlen="$(expr "${strlen}" : " *\(.*\)$")"
			strlen=${strlen%% *}
			strlen=$((strlen-1))
		else
			strlen=${#str}
		fi
		
		if [ ${pos} -lt 0 ]; then			
			pos=$((strlen+pos+2))
		fi
		if [ ${pos} -le 0 ]; then
			pos=1
		fi
		
		
		awk_script__='
		BEGIN { got_pos=1; r_start_index=1 }
		{
			r_end_index=r_start_index+length			
			if (got_pos==1 && r_end_index>=pos) {
				if(pos==0) {
					print ENVIRON["seq"] $0
				} else {
					print substr($0,1,pos-r_start_index) ENVIRON["seq"] substr($0,pos-r_start_index+1)
				}
				
				got_pos=0
			} else print
			
			r_start_index+=length+1
		}'
		
		export seq
		if [ ${isfileinput} -eq 0 ]; then
			${SHLIBS_AWK} -v pos="${pos}" "${awk_script__}" <"${filepath}"
		else
			echo "${str}" | ${SHLIBS_AWK} -v pos="${pos}" "${awk_script__}"
		fi
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

str047_help() {
	echo 'Outputs string/file content after inserting sequence at index.'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
	echo ' - sequence, substring to be inserted'
	echo ' - index of insertion (1 based, can be negative)'
}

str047_examples() {
	echo 'shlibs str047 "$(shlibs tst003)" "www.shlibs.net " 3'
	echo 'Result: '
	echo 'A www.shlibs.net Test needle line with needles, stuff, needle and once more Needle. Needles all over.'
}

str047_tests() {
	tests__='
shlibs str047 "$(shlibs tst003)" "www.shlibs.net " 3
=======
A www.shlibs.net Test needle line with needles, stuff, needle and once more Needle. Needles all over.


shlibs str047 -f "$(shlibs -p tst005)" "www.shlibs.org " -11 | ${SHLIBS_TAIL} -n 1
=======
www.shlibs.org Thank you!
'
	echo "${tests__}"
}
