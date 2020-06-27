#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str046() {
	if [ ${#} -gt 0 ]; then
		isfileinput=1
		filepath=''
		kol=1
		str=''
		
		while [ ${#} -gt 0 ]
		do
			case ${1} in
				-kol)
					kol=0
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
					else
						str="${1}"
					fi
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
			{
				res=""
				for (i=length; i>0; i--) {
					res=res substr($0,i,1)
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
			${SHLIBS_AWK} -v kol="${kol}" "${awk_script__}" <"${filepath}"
		else
			echo "${str}" | ${SHLIBS_AWK} -v kol="${kol}" "${awk_script__}"
		fi		
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

str046_help() {
	echo 'Reverse order of chars in string/file (+-keep order of lines).'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
	echo ' - use "-kol" to keep the order of lines (optional)'
}

str046_examples() {
	echo 'string=$(printf "%b" "This is the >>first<< line.\\n\\nSecond .?=line..,, here.\\nThird% #%li,ne-from-aliens.k; here.")'
	echo 'shlibs str046 "${string}"'
	echo 'Result: '
	printf "%b" 'here. #%li,ne-from-aliens.k; Third%\nhere. .?=line..,, Second\n\nline. >>first<< the is This\n'
}

str046_tests() {
	tests__='
shlibs str046 "A test string"
=======
gnirts tset A


shlibs str046 -f "$(shlibs -p tst007)" -kol
=======
eldEEn
tHgIr
'
	echo "${tests__}"
}
