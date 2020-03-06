#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com


str035() {
	if [ ${#} -gt 2 ]; then
		isfileinput=1
		filepath=''
		iflag=''
		seq_no=0
		str=''
		ndl=''
		
		
		while [ ${#} -gt 0 ]
		do			
			case ${1} in
				-i)
					iflag='0'
					shift
				;;
				[1-9]|[1-9][0-9]*)
					if [ ${seq_no} -ne 0 ]; then
						if [ -n "${str}" ]; then
							if [ -n "${ndl}" ]; then
								printf "${S_ERR_1}" "${rl_dev_code}"
								return 1
							else
								ndl="${1}"
							fi
						else
							str="${1}"
						fi
					else
						seq_no=${1}
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
						ndl="${1}"
					else
						str="${1}"
					fi
					shift
				;;
			esac
		done
		
		
		
		if [ ${isfileinput} -eq 0 ]; then
			if [ -n "${str}" ]; then
				if [ -n "${ndl}" ]; then
					printf "${S_ERR_1}" "${rl_dev_code}"
					return 1
				else
					ndl="${str}"
					str=''
				fi				
			fi
		else
			if [ -z "${str}" ]; then
				printf "${S_ERR_1}" "${rl_dev_code}"
				return 1
			fi
		fi
		if [ -z "${ndl}" ]; then
			printf "${S_ERR_1}" "${rl_dev_code}"
			return 1
		fi
		
		
		if [ ${seq_no} -eq 0 ]; then
			printf "${S_ERR_1}" "${rl_dev_code}"
			return 1
		fi		
		
		
		awk_script__='
			BEGIN { idx=1; pos=1; lndl=length(ENVIRON["ndl"]); got_pos=1 }
			{
				if(iflag==0) {
					n=split(tolower($0),larr,tolower(ENVIRON["ndl"]))
				} else {
					n=split($0,larr,ENVIRON["ndl"])
				}
				
				if(n>1) {
					if(seq_no<=(pos+n)) {
						for (i=1; i<n; i++) {
							idx+=length(larr[i])
							if(pos==seq_no) {
								print idx
								got_pos=0
								exit
							}
							pos+=1
							idx+=lndl
						}
						idx+=1
					} else {
						idx+=length+1
					}
				} else {
					idx+=length+1
				}
			}
			END { if(got_pos==1) print 0 }'
		
		awk_script__nl='
			BEGIN { idx=1; lndl=length(ENVIRON["ndl"]) }
			{
				if(iflag==0) {
					n=split(tolower($0),larr,tolower(ENVIRON["ndl"]))
				} else {
					n=split($0,larr,ENVIRON["ndl"])
				}
				
				if(n>1) {
					if(seq_no>=n) {
						print 0
						exit
					} else {
						for (i=1; i<n; i++) {
							idx+=length(larr[i])
							if(i==seq_no) {
								print idx
								exit
							}
							idx+=lndl
						}
					}
					print 0
				} else print 0
				exit
			}'		
		
		cnl=$(echo "${ndl}" | wc -l | xargs echo)
		cnl=${cnl% *}
		export ndl
		if [ ${isfileinput} -eq 0 ]; then
			if [ ${cnl} -gt 1 ]; then
				${SHLIBS_AWK} -v RS='\003' -v iflag="${iflag}" \
					-v seq_no="${seq_no}" "${awk_script__nl}" <"${filepath}"
			else
				${SHLIBS_AWK} -v iflag="${iflag}" -v seq_no="${seq_no}" \
					"${awk_script__}" <"${filepath}"
			fi
		else
			if [ ${cnl} -gt 1 ]; then
				echo "${str}" | ${SHLIBS_AWK} -v RS='\003' -v seq_no="${seq_no}" \
					-v iflag="${iflag}" "${awk_script__nl}"
			else
				echo "${str}" | ${SHLIBS_AWK} -v iflag="${iflag}" \
					-v seq_no="${seq_no}" "${awk_script__}"
			fi
		fi
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

str035_help() {
	echo 'Returns index of the n-th occurrence of needle in string.'
	echo '(returns 0 if not found, or if n exceeds the number of occurences)'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
	echo ' - needle, search substring'
	echo ' - sequencial number of the occurence (1 based, pozitive)'
	echo ' - case insensitive search flag "-i" (optional)'
}

str035_examples() {
	echo 'shlibs str035 "A text with needle, needle, needle, stuff, and extra needles." "needle" 3'
	echo 'Result: 29'
}

str035_tests() {
	tests__='
shlibs str035 "A text with needle, needle, needle, stuff, and extra needles." "needle" 3
=======
29


ndlf="$(shlibs -p tst006)"; shlibs str035 -f "$(shlibs -p tst005)" "$(cat ${ndlf})" -i 3
=======
335
'
	echo "${tests__}"
}
