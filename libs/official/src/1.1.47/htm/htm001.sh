#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

htm001() {
	if [ ${#} -gt 1 ] && [ ${#} -lt 5 ]; then
		isfileinput=1
		filepath=''
		str=''
		xhtml_br='<br>'
		skipempty=1
		
		while [ ${#} -gt 0 ]
		do		
			case ${1} in
				-skipempty)
					skipempty=0
					shift
				;;
				-xhtml)
					xhtml_br='<br />'
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
				echo 'Missing string.'
				return 1
			fi
		fi
		
		export xhtml_br
		awk_script__='
		BEGIN { L0="" }
		{
			if(NR>1) {
				if (skipempty==0 && pll==0) {
					print L0
				} else print L0 ENVIRON["xhtml_br"]
			}
			pll=(length>0?1:0)
			L0=$0			
		}
		END { print L0 }'
		
		if [ ${isfileinput} -eq 0 ]; then 
			${SHLIBS_AWK} -v skipempty="${skipempty}" \
				"${awk_script__}" <"${filepath}"
		else
			echo "${str}" | ${SHLIBS_AWK} -v skipempty="${skipempty}" \
				"${awk_script__}"
		fi
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

htm001_help() {
	echo 'Inserts (X)HTML line breaks at each new line in string/file'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
	echo ' - use "-xhtml" to insert <br> instead of <br /> (optional)'
	echo ' - use "-skipempty" to keep empty lines intact (optional)'
}

htm001_examples() {
	echo 'shlibs htm001 -f "$(shlibs -p tst006)" -xhtml'
	echo 'Result:'
	echo 'needle<br />'
	echo 'right'
}

htm001_tests() {
	tests__='
shlibs htm001 -f "$(shlibs -p tst005)" -skipempty | head -n 2
=======
This is multiline sample text<br>
It contains moderate amounts of text and can be used to test<br>
'
	echo "${tests__}"
}
