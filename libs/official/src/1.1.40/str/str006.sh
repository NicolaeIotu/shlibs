#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str006() {
	if [ ${#} -gt 2 ]; then
		isfileinput=1
		filepath=''
		iflag=1
		str=''
		ndl=''		
		pos=0
		
		while [ ${#} -gt 0 ]
		do
			case ${1} in
				-i)
					iflag=0
					shift
				;;
				[1-9]|[1-9][0-9]*|-[1-9]|-[1-9][0-9]*)
					if [ ${pos} -eq 0 ]; then
						pos=${1}
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
							printf "${S_ERR_1}" "${rl_dev_code}"
							return 1
						else
							ndl="${1}"
						fi
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
		if [ -z "${ndl}" ] || [ ${pos} -eq 0 ]; then
			printf "${S_ERR_1}" "${rl_dev_code}"
			return 1
		fi
		
		
		awk_script__='
		function getIsplit(indx) {
			start=1
			for(i=1;i<indx;i++) {
				start+=length(larr[i])+ndl_len
			}
			end=length(larr[indx])			
			return substr($0,start,end)
		}
		BEGIN{cnt=1; slice=""; ndl_len=length(ENVIRON["ndl"]) }
		{
			if (iflag==0) {
				n=split(tolower($0), larr, tolower(ENVIRON["ndl"]))
			} else {
				n=split($0, larr, ENVIRON["ndl"])
			}
			
			if (n>1) {
				if(pos==cnt+1) {
					slice=slice RS getIsplit(1)
				}
				cnt+=n-1
				if(pos<cnt) {
					slice=(pos==cnt-n+2?"":slice) getIsplit(pos-cnt+n)
					print slice
					exit
				} else {
					slice=getIsplit(n)
				}
			} else {
				slice=slice (slice==""?"":RS) $0
			}
		}
		END{ if(pos==cnt) print slice; else if (pos>cnt) exit 1 }'
		
		awk_script__nl='
		{
			ndl_len=length(ENVIRON["ndl"])
			if (iflag==0) {
				n=split(tolower($0), larr, tolower(ENVIRON["ndl"]))
			} else {
				n=split($0, larr, ENVIRON["ndl"])
			}
			if (pos<0) pos=n+pos+1
			if (pos<=0 || pos>n) exit 1
			
			if (iflag==0) {
				start=1
				for(i=1;i<pos;i++) {
					start+=length(larr[i])+ndl_len
				}
				end=length(larr[pos])
				print substr($0,start,end-1)
			} else {
				print substr(larr[pos],1,length(larr[pos])-1)
			}
			exit
		}'
		
		
		cnl=$(echo "${ndl}" | wc -l | xargs echo)
		cnl=${cnl% *}
		export ndl
		if [ ${isfileinput} -eq 0 ]; then
			if [ ${cnl} -gt 1 ] || [ ${pos} -lt 0 ]; then
				if ${SHLIBS_AWK} -v pos="${pos}" -v iflag="${iflag}" \
					-v RS='\003' "${awk_script__nl}" <"${filepath}" ; then :
				else
					echo "Invalid index."
					return 1
				fi
			else
				if ${SHLIBS_AWK} -v pos="${pos}" -v iflag="${iflag}" \
					"${awk_script__}" <"${filepath}" ; then :
				else
					echo "Invalid index."
					return 1
				fi
			fi
		else
			if [ ${cnl} -gt 1 ] || [ ${pos} -lt 0 ]; then
				if echo "${str}" | ${SHLIBS_AWK} -v pos="${pos}" \
					-v RS='\003' -v iflag="${iflag}" "${awk_script__nl}" ; then :
				else
					echo "Invalid index."
					return 1
				fi
			else
				if echo "${str}" | ${SHLIBS_AWK} -v pos="${pos}" \
					-v iflag="${iflag}" "${awk_script__}" ; then :
				else
					echo "Invalid index."
					return 1
				fi
			fi
		fi
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

str006_help() {
	echo 'Split string/file by sequence and return slice at index.'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
	echo ' - sequence splitting the string (follows the string above)'
	echo ' - slice index, 1 based (can be negative i.e. -1 for last slice)'
	echo ' - use "-i" for case insensitive search and deletion (optional)'
}

str006_examples() {
	echo 'txt="The text to be split and slice served."'
	echo 'shlibs str006 "${txt}" " " 2'
	echo 'Result: text'
}

str006_tests() {
	tests__='
shlibs str006 "$(shlibs tst003)" needle 2
=======
 line with 


shlibs str006 "$(shlibs tst003)" needle -1 -i
=======
s all over.

mn="$(shlibs -p tst006)"; mn="$(cat ${mn})"; shlibs str006 -f "$(shlibs -p tst005)" "${mn}" 2
=======
 here.
			
Multiple tabs above
'
	echo "${tests__}"
}
