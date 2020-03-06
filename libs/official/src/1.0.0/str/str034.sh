#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com


str034() {
	if [ ${#} -gt 1 ]; then
		isfileinput=1
		filepath=''
		str=''
		ndl=''
		iflag=1
		start=1
		got_start=1
		isfwd=1
		
		while [ ${#} -gt 0 ]
		do		
			case ${1} in
				-fwd)
					isfwd=0
					shift
					;;
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
						if [ -n "${ndl}" ]; then
							shift
							continue
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
		BEGIN { r_start_index=1; got_findex=1 }
		{
			if(got_findex==0) {
				if(isfwd==0) exit ; else print
			} else {
				if (iflag==0) {
					l0=tolower($0)
					lndl=tolower(ENVIRON["ndl"])
					n=split(l0,larr,lndl)
				} else {
					n=split($0,larr,ENVIRON["ndl"])
				}
				
				r_end_index=r_start_index+length
				
				if (n>1) {
					rpos=start-r_start_index+1
					if (rpos > 0) {
						# sl string
						if (iflag==0) {
							findex=index(substr(l0,rpos),lndl)
						} else {
							findex=index(substr($0,rpos),ENVIRON["ndl"])
						}
						if (findex>0) {
							got_findex=0
							if(isfwd==0) {
								if(findex>0){
									print substr($0,rpos,findex-1)
								}
								exit
							} else {
								print substr($0,rpos+findex-1)
							}
						} else {
							if(isfwd==0 && got_findex==1) {
								print
							}
						}
					} else {
						if (iflag==0) {
							findex=index(l0,lndl)
						} else {
							findex=index($0,ENVIRON["ndl"])
						}
						if (findex>0) {
							got_findex=0
							if(isfwd==0) {
								if(findex>0){
									print substr($0,1,findex-1)
								}
								exit
							} else {
								print substr($0,findex)
							}
						} else {
							if(isfwd==0 && got_findex==1) {
								print
							}
						}
					}
				} else {
					if (isfwd==0) {
						if (start>r_start_index && start<=r_end_index) {
							print substr($0,start)
						} else print
					}
				}
			}
			
			r_start_index+=length+1
		} END { if (got_findex==1) exit 1 }'
		
		awk_script__nl='
		BEGIN { pos=0; got_findex=1 }
		{
			if (iflag==0) {
				n=split(tolower($0), larr, tolower(ENVIRON["ndl"]))
			} else {
				n=split($0, larr, ENVIRON["ndl"])
			}
			
			if (n>1) {
				i=1
				lenndl=length(ENVIRON["ndl"])
				while(pos<start && i<n) {
					pos+=length(larr[i])+(i>1?lenndl:1)
					i+=1
				}
				if(isfwd==0) {
					if(pos>0){
						print substr($0,start,pos-start-1)
					}
					exit
				} else {
					print substr($0,pos)
				}
			} else exit 1
			exit
		}'
		
		
		cnl=$(echo "${ndl}" | wc -l | xargs echo)
		cnl=${cnl% *}
		export ndl
		if [ ${isfileinput} -eq 0 ]; then
			if [ ${cnl} -gt 1 ]; then
				${SHLIBS_AWK} -v start="${start}" -v RS='\003' -v iflag="${iflag}" \
					-v isfwd="${isfwd}" "${awk_script__nl}" <"${filepath}"
			else
				${SHLIBS_AWK} -v start="${start}" -v iflag="${iflag}" \
					-v isfwd="${isfwd}" "${awk_script__}" <"${filepath}"
			fi
		else
			if [ ${cnl} -gt 1 ]; then
				echo "${str}" | ${SHLIBS_AWK} -v start="${start}" -v iflag="${iflag}" \
					-v isfwd="${isfwd}" -v RS='\003' "${awk_script__nl}"
			else
				echo "${str}" | ${SHLIBS_AWK} -v start="${start}" \
					-v iflag="${iflag}" -v isfwd="${isfwd}" "${awk_script__}"
			fi
		fi
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

str034_help() {
	echo 'Returns substring needle until end, or start until needle.'
	echo '(returns 1 if not found)'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
	echo ' - needle, search substring'
	echo ' - use "-fwd" to output portion beginning until needle'
	echo ' - case insensitive search flag "-i" (optional)'
	echo ' - start position (optional, 1 based, can be negative)'
}

str034_examples() {
	echo 'shlibs str034 "A nice text with needle, stuff, and extra needles." "needle"'
	echo 'Result: '
	echo 'needle, stuff, and extra needles.'
}

str034_tests() {
	tests__='
shlibs str034 "A nice text with needle, stuff, and extra needles." "needle"
=======
needle, stuff, and extra needles.


mn="$(shlibs -p tst006)"; mn="$(cat ${mn})" ; shlibs str034 -f "$(shlibs -p tst005)" "${mn}" -i 300 | head -n 2
=======
NeedLe
RiGht is back, but with some uppercase chars.


shlibs str034 -f "$(shlibs -p tst005)" "it" -i 100 | head -n 1
=======
It contains empty lines
'
	echo "${tests__}"
}
