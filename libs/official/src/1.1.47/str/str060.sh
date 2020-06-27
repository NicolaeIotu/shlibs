#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str060() {
	if [ ${#} -gt 0 ]; then
		isfileinput=1
		filepath=''
		kol=1
		kpunct=0
		str=''
		
		while [ ${#} -gt 0 ]
		do
			case ${1} in
				-kol)
					kol=0
					shift
				;;
				-op)
					kpunct=1
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
						echo "Invalid file."
						return 1
					fi
				;;
				*)
					if [ ${isfileinput} -eq 0 ]; then
						echo "${S_ERR_2}"
						return 1
					fi
					if [ -n "${str}" ]; then
						printf "${S_ERR_1}" "${rl_dev_code}"
						return 1
					fi
					str="${1}"
					shift
				;;
			esac
		done
		
		
		if [ ${isfileinput} -eq 0 ]; then :
		else
			if [ -z "${str}" ]; then
				printf "${S_ERR_1}" "${rl_dev_code}"
				return 1
			fi
		fi
		
		
		awk_script__='
		BEGIN { cpunctspace="["ENVIRON["SHLIBS_CCLASS_PUNCT"]ENVIRON["SHLIBS_CCLASS_SPACE"]"]" }
		{
			res=""
			for(i=NF; i>0; i--){
				ai=""
				if (kpunct==1 && sub(""cpunctspace,"&",$i)>0) {
					wrd=""
					n=split($i, sr, "")
					for (j=1; j<n+1; j++) {
						if(match(sr[j],""cpunctspace)>0) {
							ai=sr[j] wrd ai
							wrd=""
						} else {
							wrd=wrd sr[j]
						}
					}
					ai=ai wrd
				} else {
					ai=$i
				}
				
				if (length(res) > 0) {
					res=res " " ai
				} else {
					res=ai
				}
			}
			
			if (kol==0) {
				print res
			} else {
				if (NR==1) {
					kol_1_res=res
				} else {
					kol_1_res=sprintf("%s\n%s", res, kol_1_res)
				}
			}
		}
		END { if (kol==1) print kol_1_res }'
			
		if [ ${isfileinput} -eq 0 ]; then
			${SHLIBS_AWK} -v kol="${kol}" -v kpunct="${kpunct}" \
				"${awk_script__}" <"${filepath}"
		else
			echo "${str}" | ${SHLIBS_AWK} -v kol="${kol}" \
				-v kpunct="${kpunct}" "${awk_script__}"
		fi		
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

str060_help() {
	echo 'Reverse order of words in string/file (+-keep order of lines).'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
	echo ' - use "-kol" to keep the order of lines (optional)'
	echo ' - use "-op" to reverse the order of punctuation as well (optional)'
	echo '   (can output better results in some cases i.e. no paths in string)'
}

str060_examples() {
	echo 'string=$(printf "%b" "This is the >>first<< line.\\n\\nSecond .?=line..,, here.\\nThird% #%li,ne-from-aliens.k; here.")'
	echo 'shlibs str060 "${string}"'
	echo 'Result: '
	printf "%b" 'here. #%li,ne-from-aliens.k; Third%\nhere. .?=line..,, Second\n\nline. >>first<< the is This\n'
}

str060_tests() {
	tests__='
shlibs str060 -f "$(shlibs -p tst007)"
=======
rIgHt
nEEdle
'
	echo "${tests__}"
}
