#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str029() {
	if [ ${#} -gt 1 ]; then
		isfileinput=1
		filepath=''
		str=''
		class_no=''
		class_yes=''
		
		while [ ${#} -gt 0 ]
		do
			case ${1} in
				-alnum|-alpha|-blank|-cntrl|-digit|-graph|-lower|-print|-punct|-space|-upper|-xdigit)
					str029_class_aloc 'n' "${1#-}"
					shift
				;;
				-kalnum|-kalpha|-kblank|-kcntrl|-kdigit|-kgraph|-klower|-kprint|-kpunct|-kspace|-kupper|-kxdigit)
					str029_class_aloc 'y' "${1#-k}"
					shift
				;;
				-f)
					if [ -n "${str}" ] || [ ${isfileinput} -eq 0 ]; then
						echo "${S_ERR_2}"
						return 1
					fi
					if [ -n "${2}" ] && [ -r "${2}" ]; then
						isfileinput=0
						filepath="${2}"
						shift 2
					else
						echo "Invalid file '${2}'"
						return 1
					fi
				;;
				--k*)
					class_yes="${class_yes}${1#--x}"
					shift
					;;
				--*)
					class_no="${class_no}${1#--}"
					shift
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
		
		if ( [ -n "${str}" ] || [ ${isfileinput} -eq 0 ] ) && \
			( [ -n "${class_no}" ] || [ -n "${class_yes}" ] ); then
			if [ ${isfileinput} -eq 0 ]; then
				if [ -n "${class_no}" ]; then
					if [ -n "${class_yes}" ]; then
						tr -d ${class_no} <"${filepath}" | tr -dc ${class_yes}
					else
						tr -d ${class_no} <"${filepath}"
					fi
				else
					tr -dc ${class_yes} <"${filepath}"
				fi
			else
				if [ -n "${class_no}" ]; then
					if [ -n "${class_yes}" ]; then
						echo "${str}" | tr -d ${class_no} | tr -dc ${class_yes}
					else
						echo "${str}" | tr -d ${class_no}
					fi
				else
					echo "${str}" | tr -dc ${class_yes}
				fi
			fi	
		else
			printf "${S_ERR_1}" "${rl_dev_code}"
			return 1
		fi			
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

str029_class_aloc() {
	ctype=$(echo "${2}" | dd conv=ucase 2>/dev/null)
	cname=$(printf '${SHLIBS_CCLASS_%s}' "${ctype}")
	
	if [ "${1}" = 'y' ]; then
		if [ -n "${class_yes}" ]; then
			eval inst_cname="${cname}"
			if [ "${2}" = 'space' ] || [ "${2}" = 'blank' ]; then
				class_yes="${inst_cname}|${class_yes}"
			else
				class_yes="${class_yes}|${inst_cname}"
			fi
		else
			eval class_yes="${cname}"
		fi
	else
		if [ -n "${class_no}" ]; then
			eval inst_cname="${cname}"
			if [ "${2}" = 'space' ] || [ "${2}" = 'blank' ]; then
				class_no="${inst_cname}|${class_no}"
			else
				class_no="${class_no}|${inst_cname}"
			fi
		else
			eval class_no="${cname}"
		fi
	fi
}

str029_help() {
	echo 'Delete (or delete all except) classes of chars, or chosen chars.'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
	echo ' - use "-alnum" to delete letters and numbers (-kalnum to keep them)'
	echo ' - use "-alpha" to delete letters (-kalpha to keep them)'
	echo ' - use "-blank" to delete blanks (-kblank to keep them)'
	echo ' - use "-cntrl" to delete control characters (-kcntrl to keep them)'
	echo ' - use "-digit" to delete numbers (-kdigit to keep them)'
	echo ' - use "-graph" to delete graphical characters (-kgraph to keep them)'
	echo ' - use "-lower" to delete lowercase characters (-klower to keep them)'
	echo ' - use "-print" to delete printable characters (-kprint to keep them)'
	echo ' - use "-punct" to delete punctuation characters (-kpunct to keep them)'
	echo ' - use "-space" to delete whitespace characters (-kspace to keep them)'
	echo ' - use "-upper" to delete uppercase characters (-kupper to keep them)'
	echo ' - use "-xdigit" to delete hexadecimal notation chars (-kxdigit to keep them)'
	echo ' - use "--chars_to_del" to delete chars ("--kchars_to_del" to keem them)'
}

str029_examples() {
	echo 'result=$(shlibs str029 "abcd%^&*#.,ABCD1234567890" -punct)'
	echo 'echo "${result}"'
	echo 'Result: abcdABCD1234567890'
	echo 'result=$(shlibs str029 "abcd%^&*#.,ABCD1234567890" --aAdD123\&)'
	echo 'echo "${result}"'
	echo 'Result: bc%^*#.,BC4567890'
}

str029_tests() {
	tests__='
shlibs str029 "abcd%^&*#.,ABCD1234567890" -punct
=======
abcdABCD1234567890


shlibs str029 "abcd%^&*#.,ABCD1234567890" --aAdD123\&
=======
bc%^*#.,BC4567890


shlibs str029 -f "$(shlibs -p tst005)" -lower -space -punct
=======
TIYIAMAONLRGFTT
'
	echo "${tests__}"
}
