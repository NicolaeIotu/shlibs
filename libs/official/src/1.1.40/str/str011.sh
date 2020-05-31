#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str011() {
	if [ ${#} -gt 1 ]; then
		isfileinput=1
		filepath=''
		str=''
		ndl=''
		iflag=1
		end=0
		got_end=1
		
		
		while [ ${#} -gt 0 ]
		do		
			case ${1} in
				-i)
					iflag=0
					shift
				;;
				[1-9]|[1-9][0-9]*|-[1-9]|-[1-9][0-9]*)
					if [ ${got_end} -eq 1 ]; then
						end=${1}
						got_end=0
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
		
		
		if [ ${end} -lt 0 ]; then
			if [ ${isfileinput} -eq 0 ]; then
				strlen=$(wc -m "${filepath}")
				strlen="$(expr "${strlen}" : " *\(.*\)$")"
				strlen=${strlen%% *}
				strlen=$((strlen-1))
			else
				strlen=${#str}
			fi
			
			end=$((strlen+end))
		fi
		if [ ${end} -lt 0 ]; then
			end=0
		fi
		
		
		awk_script__='
		BEGIN { pos=0; r_start_index=1; fs_len=length(FS) }
		{
			if (NF>1) {
				s_len=r_start_index+length($1)
				if(end>0 && s_len+fs_len>end) exit
				pos=s_len
				
				if(NF>2) {
					i=2
					while(i<NF) {
						tmp_len=fs_len+length($i)
						if(end>0 && pos+tmp_len+fs_len>end) exit
						pos+=tmp_len
						i+=1
					}
				}
			}
			r_start_index+=length+1
		} 
		END { print pos }'
		
		awk_script__nl='
		{
			if (end > 0) {
				if (iflag==0) {
					n=split(substr(tolower($0),1,end), larr, tolower(ENVIRON["ndl"]))
				} else {
					n=split(substr($0,1,end), larr, ENVIRON["ndl"])
				}
			} else {
				if (iflag==0) {
					n=split(tolower($0), larr, tolower(ENVIRON["ndl"]))
				} else {
					n=split($0, larr, ENVIRON["ndl"])
				}
			}
			
			if (n>1) {
				if (end > 0) {
					print end-length(larr[n])-length(ENVIRON["ndl"])+1
				} else {
					print length-length(larr[n])-length(ENVIRON["ndl"])+1
				}
			} else print 0
			exit
		}'
		
		
		cnl=$(echo "${ndl}" | wc -l | xargs echo)
		cnl=${cnl% *}
		if [ ${isfileinput} -eq 0 ]; then
			if [ ${cnl} -gt 1 ]; then
				export ndl
				${SHLIBS_AWK} -v end="${end}" -v RS='\003' -v iflag="${iflag}" \
					"${awk_script__nl}" <"${filepath}"
			else
				if [ ${iflag} -eq 0 ]; then
					ndl="$(echo "${ndl}" | dd conv=lcase 2>/dev/null)"
					dd if="${filepath}" conv=lcase 2>/dev/null | \
						${SHLIBS_AWK} -v end="${end}" -F "${ndl}" \
						"${awk_script__}"
				else
					${SHLIBS_AWK} -v end="${end}" -F "${ndl}" \
						"${awk_script__}" <"${filepath}"
				fi
			fi
		else
			if [ ${cnl} -gt 1 ]; then
				export ndl
				echo "${str}" | ${SHLIBS_AWK} -v end="${end}" -v RS='\003' \
					-v iflag="${iflag}" "${awk_script__nl}"
			else
				if [ ${iflag} -eq 0 ]; then
					ndl="$(echo "${ndl}" | dd conv=lcase 2>/dev/null)"
					echo "${str}" | dd conv=lcase 2>/dev/null | \
						${SHLIBS_AWK} -v end="${end}" -F "${ndl}" \
						"${awk_script__}"
				else
					echo "${str}" | ${SHLIBS_AWK} -v end="${end}" \
						-F "${ndl}" "${awk_script__}"
				fi
			fi
		fi
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

str011_help() {
	echo 'Returns index of the last occurrence of needle in string/file.'
	echo '(returns 0 if not found)'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
	echo ' - needle, search substring'
	echo ' - case insensitive search flag "-i" (optional)'
	echo ' - end position (optional, 1 based, can be negative)'
}

str011_examples() {
	echo 'shlibs str011 "A nice text with needle, stuff, and extra needles." "needle"'
	echo 'Result: 43'
}

str011_tests() {
	tests__='
shlibs str011 "$(shlibs tst003)" needle
=======
41


shlibs str011 "$(shlibs tst003)" needle -i 71
=======
62


shlibs str011 -f "$(shlibs -p tst005)" needle -i 390
=======
335
'
	echo "${tests__}"
}
