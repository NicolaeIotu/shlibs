#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str015() {
	if [ ${#} -gt 0 ]; then
		isfileinput=1
		filepath=''
		gflag=1
		iflag=1
		str=''
		ndl=''
		repl=''
		gotrepl=1
		
		
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
							repl="${1}"
							gotrepl=0
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
			if [ ${gotrepl} -eq 1 ]; then
				repl="${ndl}"
				ndl="${str}"
				str=''
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
							start=1
							for(i=1;i<=n;i++) {
								larr[i]=substr($0,start,length(larr[i]))
								start+=length(larr[i])+ndllen
							}
							
							str=larr[1]
							if(gflag==0) {
								for(i=2; i<=n; i++) {
									str=str ENVIRON["repl"] larr[i] 
								}
							} else {
								str=larr[1] ENVIRON["repl"]
								str=str substr($0,length(larr[1] ENVIRON["ndl"])+1)
							}
							
							single_repl=0
							print str
						} else print
					}
				} else {
					if(gflag==0) {
						gsub(ENVIRON["ndl"],ENVIRON["repl"])
					} else if(single_repl==1) {
						n=sub(ENVIRON["ndl"],ENVIRON["repl"])
						if (n==1) single_repl=0						
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
						for(i=1;i<n;i++) {
							larr[i]=substr($0,start-i,length(larr[i]))
							start+=length(larr[i])+ndllen
						}
					}									
				} else {
					n=split($0, larr, ENVIRON["ndl"])
				}
				
				if (n>1) {
					str=larr[1]
					
					if(gflag==0) {
						for(i=2; i<=n; i++) {
							str=str ENVIRON["repl"] larr[i]
						}
					} else {
						for(i=2; i<=n; i++) {
							str=str (i==2?ENVIRON["repl"]:ENVIRON["ndl"]) larr[i]
						}
					}
					
					print substr(str,1,length(str)-1)
				} else print substr($0,1,length-1)
				exit
			}'
		
		
		cnl=$(echo "${ndl}" | wc -l | xargs echo)
		cnl=${cnl% *}
		crl=$(echo "${repl}" | wc -l | xargs echo)
		crl=${crl% *}
		export ndl
		export repl
		if [ ${isfileinput} -eq 0 ]; then
			if [ ${cnl} -gt 1 ] || [ ${crl} -gt 1 ]; then
				${SHLIBS_AWK} -v RS='\003' -v gflag="${gflag}" \
					-v iflag="${iflag}" "${awk_script__nl}" <"${filepath}"
			else
				${SHLIBS_AWK}  -v gflag="${gflag}" -v iflag="${iflag}" \
					"${awk_script__}" <"${filepath}"
			fi			
		else
			if [ ${cnl} -gt 1 ] || [ ${crl} -gt 1 ]; then
				echo "${str}" | ${SHLIBS_AWK} -v RS='\003' -v cnl="${cnl}" \
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

str015_help() {
	echo 'Replace sequence in string/file (first instance or global).'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
	echo ' - sequence to replace'
	echo ' - replacement string'
	echo ' - use "-g" to replace all instances of the sequence (optional)'
	echo ' - use "-i" for case insensitive search and replacement (optional)'
}

str015_examples() {
	echo 'teststring=$(printf "%b" "This is the >>first<< line.\\n\\nSecond .?=line..,, here.\\nThird% #%li,ne-from-aliens.k; here.")'
	echo 'shlibs str015 -g "${teststring}" "line" "transmission"'
	echo 'Result: '
	echo 'This is the >>first<< transmission.'
	echo ''
	echo 'Second .?=transmission..,, here.'
	echo 'Third% #%li,ne-from-aliens.k; here.'
}

str015_tests() {
	tests__='
shlibs str015 "A test string" "test" "simple test"
=======
A simple test string


shlibs str015 "Test string used to test g/i flags" "test" "TEST" -g -i
=======
TEST string used to TEST g/i flags


shlibs str015 -f "$(shlibs -p tst005)" it tst005 -i | head -n 2
=======
This is multiline sample text
tst005 contains moderate amounts of text and can be used to test
'
	echo "${tests__}"
}
