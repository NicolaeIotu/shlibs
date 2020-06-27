#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str024() {
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
					else
						if [ ${end} -ne 0 ]; then
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
					if [ -n "${str}" ] && [ -n "${ndl}" ]; then
						printf "${S_ERR_1}" "${rl_dev_code}"
						return 1
					fi
					if [ ${#str} -lt ${#1} ]; then
						ndl="${str}"
						str="${1}"
					else
						ndl="${1}"
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
			
			if [ -z "${ndl}" ] && [ -n "${str}" ]; then
				ndl="${str}"
				str=''
			fi
		else
			if [ -z "${str}" ]; then
				echo 'Missing string.'
				return 1
			fi
			strlen=${#str}
		fi
		if [ -z "${ndl}" ]; then
			echo 'Missing needle.'
			return 1
		fi
	
		
		if [ ${start} -eq 0 ]; then
			start=1
		elif [ ${start} -lt 0 ]; then
			start=$((strlen+start+1))
		fi
		if [ ${start} -lt 1 ]; then
			echo "Invalid index: ${start}"
			return 1
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
		 	return 1
		fi
		
		
		awk_script__ml='
		{
			if (iflag==0) {
				print split(tolower(substr($0,start,end)), null, tolower(ENVIRON["ndl"]))-1
			} else {
				print split(substr($0,start,end), null, ENVIRON["ndl"])-1
			}
			exit
		}'
		
		awk_script__='
		BEGIN{cnt=0; r_start_index=0 }
		{
			r_end_index=r_start_index+length
			if (length>0) {
				if (end > 0 && r_start_index>=end) {
					exit
				} else if (start>r_end_index) {
					;
				} else if (start<=r_end_index) {
					if (r_end_index>end) {
						slc=substr($0,start-r_start_index,end-r_start_index-start+1)
					} else {
						slc=substr($0,start-r_start_index)
					}
					if (length(slc) >= length(NF)) {
						cnt+=split(slc,larr)-1
					}
				} else {
					cnt+=(NF-1)
				}
			}
			
			r_start_index+=length+1
		}
		END{print cnt}'
		
		
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
		return 1
	fi
}

str024_help() {
	echo 'Count occurrences of needle in string.'
	echo 'Maximum 5 parameters, any order'
	echo '$1 - Subject string'
	echo '$2 - Needle, search substring'
	echo '$3 - Case insensitive search flag "-i" (optional)'
	echo '$4 - Start index (integer, included, 1 based, optional, can be negative).'
	echo '$5 - End index (integer, included, 1 based, optional, can be negative).'
}

str024_examples() {
	echo 'teststring="A test string containing needle, needle, needle and needle."'
	echo 'shlibs str024 "${teststring}" "needle"'
	echo 'Result: 4'
}

str024_tests() {
	tests__='
shlibs str024 "A test string containing needle, needle, needle and needle." "needle"
=======
4


shlibs str024 "$(shlibs tst003)" needle -i 12 -14
=======
3


shlibs str024 -f "$(shlibs -p tst005)" needle -i 146 -50
=======
5
'
	echo "${tests__}"
}
