#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str066() {	
	if [ ${#} -gt 1 ]; then
		isfileinput_1=1
		isfileinput_2=1
		filepath_1=''
		filepath_2=''
		str_1=''
		str_2=''
		start=0
		size=0
		
		while [ ${#} -gt 0 ]
		do
			case ${1} in
				-[1-9]|-[1-9][0-9]*)					
					if [ ${start} -eq 0 ]; then
						start=${1}
					else
						if [ -n "${str_1}" ]; then
							if [ -n "${str_2}" ]; then
								printf "${S_ERR_1}" "${rl_dev_code}"
								return 1
							else
								str_2="${1}"
							fi
						else
							str_1="${1}"
						fi
					fi
					shift
				;;
				[1-9]|[1-9][0-9]*)					
					if [ ${start} -eq 0 ]; then
						start=${1}
					else
						if [ ${size} -eq 0 ]; then
							size=${1}
						else
							if [ -n "${str_1}" ]; then
								if [ -n "${str_2}" ]; then
									printf "${S_ERR_1}" "${rl_dev_code}"
									return 1
								else
									str_2="${1}"
								fi
							else
								str_1="${1}"
							fi
						fi
					fi
					shift
				;;
				-f)
					if [ ${isfileinput_1} -eq 0 ] && [ ${isfileinput_2} -eq 0 ]; then
						echo "${S_ERR_2}"
						return 1
					fi
					if [ -n "${2}" ] && [ -r "${2}" ]; then
						if [ ${isfileinput_1} -eq 0 ]; then
							isfileinput_2=0
							filepath_2="${2}"
						else
							isfileinput_1=0
							filepath_1="${2}"
						fi
						shift 2
					else
						echo "Invalid file '${2}'"
						return 1
					fi
				;;
				*)
					if ( [ ${isfileinput_1} -eq 0 ] && [ ${isfileinput_2} -eq 0 ] ) || \
						( [ -n "${str_1}" ] && [ -n "${str_2}" ] ) ; then
						echo "${S_ERR_2}"
						return 1
					fi
					if [ -n "${str_1}" ]; then
						str_2="${1}"
					else
						str_1="${1}"
					fi
					shift
				;;
			esac
		done
		
		
		if [ ${start} -eq 0 ] || [ ${size} -lt 1 ]; then
			echo "${S_ERR_2}"
			return 1
		fi
		if [ ${isfileinput_1} -eq 0 ]; then
			strlen_1=$(wc -m "${filepath_1}")
			strlen_1="$(expr "${strlen_1}" : " *\(.*\)$")"
			strlen_1=${strlen_1%% *}
			strlen_1=$((strlen_1-1))
		else
			if [ -z "${str_1}" ]; then
				echo 'Missing string.'
				return 1
			fi
			strlen_1=${#str_1}
		fi
		if [ ${isfileinput_2} -eq 0 ]; then
			strlen_2=$(wc -m "${filepath_2}")
			strlen_2="$(expr "${strlen_2}" : " *\(.*\)$")"
			strlen_2=${strlen_2%% *}
			strlen_2=$((strlen_2-1))
		else
			if [ -z "${str_2}" ]; then
				if [ -z "${str_1}" ]; then
					echo 'Missing string.'
					return 1
				else
					str_2="${str_1}"
				fi
			fi
			strlen_2=${#str_2}
		fi
		
		start_1=${start}
		start_2=${start}
		if [ ${start} -lt 0 ]; then
			start_1=$((strlen_1+start_1+1))
			start_2=$((strlen_2+start_2+1))
		fi
		if [ ${start_1} -lt 1 ] || [ ${start_2} -lt 1 ]; then
			echo "Invalid index: ${start}"
			return 1
		fi
		end_1=$((start_1+size-1))
		end_2=$((start_2+size-1))
		if [ ${end_1} -gt ${strlen_1} ] || [ ${end_2} -gt ${strlen_2} ]; then
			echo 'Invalid index and/or length.'
			return 1
		fi
		
		skip_1=$((start_1-1))
		skip_2=$((start_2-1))
		if [ ${isfileinput_1} -eq 0 ]; then
			slice_1="$( dd bs=1 if="${filepath_1}" skip=${skip_1} \
				count=${size} 2>/dev/null )"
		else
			slice_1="$( echo "${str_1}" | dd bs=1 skip=${skip_1} \
				count=${size} 2>/dev/null )"
		fi
		if [ ${isfileinput_2} -eq 0 ]; then
			slice_2="$( dd bs=1 if="${filepath_2}" skip=${skip_2} \
				count=${size} 2>/dev/null )"
		else
			slice_2="$( echo "${str_2}" | dd bs=1 skip=${skip_2} \
				count=${size} 2>/dev/null )"
		fi
		
		test "${slice_1}" = "${slice_2}"
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

str066_help() {
	echo 'Checks if region matches. Works on strings and/or files.'
	echo 'Parameters:'
	echo ' - first string, or "-f /path/to/text/file" to process file content'
	echo ' - second string, or "-f /path/to/text/file" to process file content'
	echo ' - region start index (1 based, included, can be negative)'
	echo ' - region length (positive integer)'
	echo '   (start/length should be specified in order above unless logical cases)'
}

str066_examples() {
	echo 'teststring1="A test string"'
	echo 'teststring2="A test string used to test shlibs str066"'
	echo 'shlibs str066 "${teststring1}" "${teststring2}" 1 13'
	echo 'echo ${?}'
	echo 'Result: 0 (Successful match)'
}

str066_tests() {
	tests__='
shlibs str066 "A test string" "A test string somehow different" 1 13 ; echo ${?}
=======
0


pt="$(shlibs -p tst006)"; shlibs str066 -f "${pt}" -f "${pt}" 2 7 ; echo ${?}
=======
0
'
	echo "${tests__}"
}
