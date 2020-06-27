#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str010() {
	if [ ${#} -gt 1 ]; then
		isfileinput=1
		filepath=''
		str=''
		ndl=''
		iflag=1
		start=1
		got_start=1
		
		
		while [ ${#} -gt 0 ]
		do		
			case ${1} in
				-i)
					iflag=0
					shift
				;;
				[1-9]|[1-9][0-9]*|-[1-9]|-[1-9][0-9]*)
					if [ ${got_start} -eq 1 ]; then
						start=${1}
						got_start=0
					else
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
					fi
					shift
				;;
				-f)
					if [ ${isfileinput} -eq 0 ]; then
						echo "${S_ERR_2}"
						return 1
					fi
					if [ -r "${2}" ]; then
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
						if [ -n "${ndl}" ]; then
							shift
							continue
						fi
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
		
		
		if [ ${start} -lt 0 ]; then
			if [ ${isfileinput} -eq 0 ]; then
				strlen=$(wc -m "${filepath}")
				strlen="$(expr "${strlen}" : " *\(.*\)$")"
				strlen=${strlen%% *}
				strlen=$((strlen-1))
			else
				strlen=${#str}
			fi
			
			start=$((strlen+start))
		fi
		if [ ${start} -lt 0 ]; then
			start=1
		fi
		
		
		awk_script__='
		BEGIN { r_start_index=1 }
		{
			if (iflag==0) {
				l0=tolower($0)
				LFS=tolower(FS)
				n=split(l0,null,LFS)
			} else n=NF
			
			if (n>1) {
				rpos=start-r_start_index+1
				if (rpos > 0) {
					if (iflag==0) {
						findex=index(substr(l0,rpos),LFS)
					} else {
						findex=index(substr($0,rpos),FS)
					}
					if (findex>0) {
						print (start+findex-1)
						exit
					}
				} else {
					if (iflag==0) {
						findex=index(l0,LFS)
					} else {
						findex=index($0,FS)
					}
					if (findex>0) {
						print (r_start_index+findex-1)
						exit
					}
				}
			}
			r_start_index+=length+1
		} END { if (findex==0) print 0 }'
		
		awk_script__nl='
		BEGIN { pos=0 }
		{
			if (iflag==0) {
				n=split(tolower($0), larr, tolower(ENVIRON["ndl"]))
			} else {
				n=split($0, larr, ENVIRON["ndl"])
			}
			
			if (n>1) {
				i=1
				while(pos<start && i<n) {
					pos+=length(larr[i])+(i>1?length(ENVIRON["ndl"]):1)
					i+=1
				}
				print pos
			} else {
				print 0
			}
			exit
		}'
		
		
		cnl=$(echo "${ndl}" | wc -l | xargs echo)
		cnl=${cnl% *}
		if [ ${isfileinput} -eq 0 ]; then
			if [ ${cnl} -gt 1 ]; then
				export ndl
				${SHLIBS_AWK} -v start="${start}" -v RS='\003' \
					-v iflag="${iflag}"  "${awk_script__nl}" <"${filepath}"
			else
				${SHLIBS_AWK} -v start="${start}" -F "${ndl}" \
					-v iflag="${iflag}" "${awk_script__}" <"${filepath}"
			fi
		else
			if [ ${cnl} -gt 1 ]; then
				export ndl
				echo "${str}" | ${SHLIBS_AWK} -v start="${start}" \
					-v iflag="${iflag}"  -v RS='\003' "${awk_script__nl}"
			else
				echo "${str}" | ${SHLIBS_AWK} -v start="${start}" \
					-v iflag="${iflag}"  -F "${ndl}" "${awk_script__}"
			fi
		fi
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

str010_help() {
	echo 'Returns absolute index of the first occurrence of needle in string/file.'
	echo '(returns 0 if not found)'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
	echo ' - needle, search substring'
	echo ' - case insensitive search flag "-i" (optional)'
	echo ' - start position (optional, 1 based, can be negative)'
}

str010_examples() {
	echo 'shlibs str010 "A nice text with needle, stuff, and extra needles." "needle"'
	echo 'Result: 18'
}

str010_tests() {
	tests__='
shlibs str010 "$(shlibs tst003)" needle
=======
8


shlibs str010 "$(shlibs tst003)" needle 42 -i
=======
62


shlibs str010 -f "$(shlibs -p tst005)" needle -i 321
=======
335
'
	echo "${tests__}"
}
