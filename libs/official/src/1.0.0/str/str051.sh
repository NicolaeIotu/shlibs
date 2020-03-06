#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str051() {
	if [ ${#} -gt 0 ]; then
		isfileinput=1
		filepath=''
		str=''
		bw='-s'
		size=0
		
		while [ ${#} -gt 0 ]
		do
			case ${1} in
				-b)
					bw=''
					shift
				;;
				[1-9]|[1-9][0-9]*)
					if [ ${size} -ne 0 ]; then
						if [ -n "${str}" ]; then
							printf "${S_ERR_1}" "${rl_dev_code}"
							return 1
						else
							str="${1}"
						fi
					else
						size=${1}
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
						echo "Invalid file."
						return 1
					fi
				;;
				*)
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
			if [ -n "${str}" ]; then
				printf "${S_ERR_1}" "${rl_dev_code}"
				return 1
			fi
		else
			if [ -z "${str}" ]; then
				printf "${S_ERR_1}" "${rl_dev_code}"
				return 1
			fi
		fi
		
		awk_script__ml='BEGIN { maxlen=0 } { if (length>maxlen) maxlen=length } END { print maxlen }'
		awk_script__='
		BEGIN { cspace="['"${SHLIBS_CCLASS_SPACE}"']*$" }
		{
			apnd=""
			sub(""cspace,"")
			dl=size-length
			while(dl>0) {
				apnd=apnd " "
				dl-=1
			}
			print apnd $0
		}'
		
		if [ ${isfileinput} -eq 0 ]; then
			if [ ${size} -gt 0 ]; then
				fold ${bw} -w ${size} "${filepath}" | ${SHLIBS_AWK} -v size="${size}" "${awk_script__}"
			else
				size=$(${SHLIBS_AWK} "${awk_script__ml}" <"${filepath}")
				${SHLIBS_AWK} -v size="${size}" "${awk_script__}" <"${filepath}"
			fi
		else
			if [ ${size} -gt 0 ]; then
				echo "${str}" | fold ${bw} -w ${size} | ${SHLIBS_AWK} -v size="${size}" "${awk_script__}"
			else
				size=$(echo "${str}" | ${SHLIBS_AWK} "${awk_script__ml}")
				echo "${str}" | ${SHLIBS_AWK} -v size="${size}" "${awk_script__}"
			fi
		fi
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

str051_help() {
	echo 'Align right string/file (+-wrap to size and break words).'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
	echo ' - wrap size (optional)'
	echo ' - use -b to break words (optional, works when wrap size specified)'
}


str051_examples() {
	echo 'shlibs str051 "A string used to test wrap and align right text using str051" 24'
	echo 'Result: '
	echo '   A string used to test'
	echo '    wrap and align right'
	echo '       text using str051'
}

str051_tests() {
	tests__='
shlibs str051 "A string used to test wrap and align right text using str051" 24
=======
   A string used to test
    wrap and align right
       text using str051


shlibs str051 -f "$(shlibs -p tst004)" 30 | head -n 3
=======
   Lorem ipsum dolor sit amet,
 consectetuer adipiscing elit.
  Nunc congue ipsum vestibulum
'
	echo "${tests__}"
}
