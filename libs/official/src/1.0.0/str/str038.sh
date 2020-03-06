#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str038() {
	if [ ${#} -gt 1 ]; then
		isfileinput=1
		filepath=''
		gflag=1
		iflag=1
		str=''
		ndl=''
		
		while [ ${#} -gt 0 ]
		do
			case ${1} in
				-g)
					gflag=0
					shift
				;;
				-i)
					iflag=0
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
		
		
		awk_script__='
			BEGIN { single_repl=1; ndllen=length(ENVIRON["ndl"]) }
			{
				if(iflag==0) {
					if (single_repl==0 && gflag!=0) {
						print
					} else {
						l0=tolower($0)
						ln=tolower(ENVIRON["ndl"])
						
						n=split(l0, larr, ln)
						if (n>1) {
							str=""
							start=1
							for(i=1;i<=n;i++) {
								larr[i]=substr($0,start,length(larr[i]))
								start+=length(larr[i])+ndllen
							}
							
							if(gflag==0) {
								for(i=1; i<=n; i++) {
									str=str larr[i]
								}
							} else {
								str=larr[1]
								str=str substr($0,length(larr[1] ENVIRON["ndl"])+1)
							}
							
							single_repl=0
							print str
						} else print
					}
				} else {
					if(gflag==0) {
						gsub(ENVIRON["ndl"],"")
					} else if(single_repl==1) {
						if (sub(ENVIRON["ndl"],"")==1)
							single_repl=0						
					}
					print
				}
			}'
		
		awk_script__nl='
			{
				if(iflag==0) {
					ndllen=length(ENVIRON["ndl"])
					n=split(tolower($0), larr, tolower(ENVIRON["ndl"]))
					if(n>1) {
						start=2
						for(i=1;i<n+1;i++) {
							larr[i]=substr($0,start-i,length(larr[i]))
							start+=length(larr[i])+ndllen+1
						}
					}	
				} else {
					n=split($0, larr, ENVIRON["ndl"])
				}
				
				if (n>1) {
					str=larr[1]
					
					if(gflag==0) {
						for(i=2; i<=n; i++) {
							str=str larr[i]
						}
					} else {
						str=str substr($0,length(larr[1] ENVIRON["ndl"]))
					}
					
					print substr(str,1,length(str)-1)
				} else print substr($0,1,length-1)
				exit
			}'
		
		cnl=$(echo "${ndl}" | wc -l | xargs echo)
		cnl=${cnl% *}
		export ndl
		if [ ${isfileinput} -eq 0 ]; then
			if [ ${cnl} -gt 1 ]; then
				${SHLIBS_AWK} -v RS='\003' -v gflag="${gflag}" \
					-v iflag="${iflag}" "${awk_script__nl}" <"${filepath}"
			else
				${SHLIBS_AWK}  -v gflag="${gflag}" -v iflag="${iflag}" \
					"${awk_script__}" <"${filepath}"
			fi
		else
			if [ ${cnl} -gt 1 ]; then
				echo "${str}" | ${SHLIBS_AWK} -v RS='\003' \
					-v gflag="${gflag}" -v iflag="${iflag}" "${awk_script__nl}"
			else
				echo "${str}" | ${SHLIBS_AWK} -v gflag="${gflag}" \
					-v iflag="${iflag}" "${awk_script__}"
			fi
		fi
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

str038_help() {
	echo 'Delete sequence from string/file (options: global, case insensitive).'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
	echo ' - sequence to delete (if above is string, the sequence must follow it)'
	echo ' - use "-g" to delete all instances of the sequence (optional)'
	echo ' - use "-i" for case insensitive search and deletion (optional)'
}

str038_examples() {
	echo 'teststring=$(printf "%b" "This is the >>first<< line.\\n\\nSecond .?=line..,, here.\\nThird% #%li,ne-from-aliens.k; here.")'
	echo 'shlibs str038 "${teststring}" "line"'
	echo 'Result: '
	echo 'This is the >>first<< .'
	echo ' '
	echo 'Second .?=line..,, here.'
	echo 'Third% #%li,ne-from-aliens.k; here.'
}

str038_tests() {
	tests__='
ndlf="$(shlibs -p tst006)"; shlibs str038 -f "$(shlibs -p tst005)" "$(cat ${ndlf})" -g -i | shlibs str043 8 3
=======
A repeating multiline  here.
			
Multiple tabs above
'
	echo "${tests__}"
}
