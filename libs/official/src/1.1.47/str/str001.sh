#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str001_assign_str() {
	if [ ${#str} -lt ${#1} ]; then
		ndl="${str}"
		str="${1}"
	else
		ndl="${1}"
	fi
}

str001() {
	if [ ${#} -gt 1 ]; then
		isfileinput=1
		filepath=''
		iflag=1
		str=''
		ndl=''
		start=0
		end=0
		
		while [ ${#} -gt 0 ]
		do			
			case ${1} in
				-i)
					iflag=0
					shift
				;;
				[1-9]|[1-9][0-9]*|-[1-9]|-[1-9][0-9]*)
					if [ ${start} -eq 0 ]; then
						start=${1}
					elif [ ${end} -eq 0 ]; then
						end=${1}
					else
						str001_assign_str "${1}"
					fi
					shift
				;;
				-f)
					if [ -n "${str}" ] || [ ${isfileinput} -eq 0 ]; then
						echo "${S_ERR_2}"
						return 2
					fi
					if [ -r "${2}" ]; then
						isfileinput=0
						filepath="${2}"
						shift 2
					else
						echo "Invalid file '${2}'"
						return 2
					fi
				;;
				*)
					str001_assign_str "${1}"
					shift
				;;
			esac
		done
		
		
		if [ ${isfileinput} -eq 0 ]; then
			strlen=$(wc -m "${filepath}")
			# comments valid project wide
			# correct wc outputs such as: '   462 /path/to/file'
			strlen="$(expr "${strlen}" : " *\(.*\)$")"
			# takes into account paths containing spaces
			strlen=${strlen%% *}
			strlen=$((strlen-1))
			
			if [ -z "${ndl}" ] && [ -n "${str}" ]; then
				ndl="${str}"
				str=''
			fi
		else
			if [ -z "${str}" ]; then
				echo 'Missing string.'
				return 2
			fi
			strlen=${#str}
		fi
		if [ -z "${ndl}" ]; then
			echo 'Missing needle.'
			return 2
		fi
	
		
		if [ ${start} -eq 0 ]; then
			start=1
		elif [ ${start} -lt 0 ]; then
			start=$((strlen+start+1))
		fi
		if [ ${start} -lt 1 ]; then
			echo "Invalid index: ${start}"
			return 2
		fi
		
		if [ ${end} -lt 0 ]; then
			end=$((strlen+end+1))
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
		
		dim=$((end-start+1))
		if [ ${#ndl} -gt ${dim#-} ]; then
			echo "The needle cannot fit specified section."
		 	return 2
		fi
		
		
		awk_script__ml='
		{
			if (iflag==0) {
				n=split(tolower(substr($0,start,end)), null, tolower(ENVIRON["ndl"]))
			} else {
				n=split(substr($0,start,end), null, ENVIRON["ndl"])
			}
			if (n<2) exit 1
			exit
		}'
		
		awk_script__='
		BEGIN{cnt=0; r_start_index=0}
		{
			if (length>0) {
				r_end_index=r_start_index+length
				if (end > 0 && r_start_index>=end) {
					exit
				} else if (start>r_end_index) {
					1
				} else if (start<=r_end_index) {
					if (end <= r_end_index) {
						slc=substr($0,start-r_start_index,end-r_start_index-1)
					} else {
						slc=substr($0,start-r_start_index)
					}
					if (length(slc) >= length(NF)) {
						cnt+=split(slc,larr)-1
					}
				} else {
					cnt+=(NF-1)
				}
				if(cnt>0) exit
			}
			
			r_start_index+=length+1
		}
		END{ if(cnt==0) exit 1 }'
		
		# a cross OS resolve for this task
		cnl=$(echo "${ndl}" | wc -l | xargs echo)
		cnl=${cnl% *}
		if [ ${isfileinput} -eq 0 ]; then
			if [ ${cnl} -gt 1 ]; then
				export ndl
				${SHLIBS_AWK} -v start="${start}" -v end="${end}" -v iflag="${iflag}" \
					-v RS='\003' "${awk_script__ml}" <"${filepath}"
			else
				if [ ${iflag} -eq 0 ]; then
					ndl="$(echo "${ndl}" | dd conv=lcase 2>/dev/null)"
					dd if="${filepath}" conv=lcase 2>/dev/null | \
						${SHLIBS_AWK} -F "${ndl}" -v start="${start}" \
					 	-v iflag="${iflag}" -v end="${end}" "${awk_script__}"
				else
					${SHLIBS_AWK} -F "${ndl}" -v start="${start}" -v end="${end}" \
						-v iflag="${iflag}" "${awk_script__}" <"${filepath}"
				fi
			fi
		else
			if [ ${cnl} -gt 1 ]; then
				export ndl
				echo "${str}" | ${SHLIBS_AWK} -v start="${start}" -v end="${end}" \
					-v iflag="${iflag}" -v RS='\003' "${awk_script__ml}"
			else
				if [ ${iflag} -eq 0 ]; then
					ndl="$(echo "${ndl}" | dd conv=lcase 2>/dev/null)"
					echo "${str}" | dd conv=lcase 2>/dev/null | \
						${SHLIBS_AWK} -F "${ndl}" -v start="${start}" \
					 	-v iflag="${iflag}" -v end="${end}" "${awk_script__}"
				else
					echo "${str}" | ${SHLIBS_AWK} -F "${ndl}" -v start="${start}" \
						-v end="${end}" -v iflag="${iflag}"  "${awk_script__}"
				fi
			fi
		fi
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 2
	fi
}

str001_help() {
	echo 'Checks if string/file contains needle.'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
	echo ' - the needle'
	echo ' - use "-i" for case insensitive search (optional)'
	echo ' - start index (integer, included, 1 based, optional, can be negative).'
	echo ' - end index (integer, included, 1 based, optional, can be negative).'
	echo 'Returns 0 (test passed), 1 (test failed), or 2 (errors)'
}

str001_examples() {
	echo 'txt="A test string containing needle and other stuff."'
	echo 'shlibs str001 "${txt}" "needle"'
	echo 'echo ${?}'
	echo 'Result: 0 (success)'
}

str001_tests() {
	tests__='
shlibs str001 "A test string" "test" ; echo ${?}
=======
0


shlibs str001 -f "$(shlibs -p tst005)" nEEdle ; echo ${?}
=======
1


shlibs str001 1 67 45435439321 3543 ; echo ${?}
=======
0
'
	echo "${tests__}"
}
