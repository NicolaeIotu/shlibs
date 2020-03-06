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
		class_del=''
		class_keep=''
		
		while [ ${#} -gt 0 ]
		do
			case ${1} in
				-alnum|-alpha|-blank|-cntrl|-digit|-graph|-lower|-print|-punct|-space|-upper|-xdigit)
					class_del="${class_del}[:${1#-}:]"
					shift
				;;
				-kalnum|-kalpha|-kblank|-kcntrl|-kdigit|-kgraph|-klower|-kprint|-kpunct|-kspace|-kupper|-kxdigit)
					class_keep="${class_keep}[:${1#-k}:]"
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
					class_keep="${class_keep}${1#--x}"
					shift
					;;
				--*)
					class_del="${class_del}${1#--}"
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
			( [ -n "${class_del}" ] || [ -n "${class_keep}" ] ); then
			if [ ${isfileinput} -eq 0 ]; then
				if [ -n "${class_del}" ]; then
					if [ -n "${class_keep}" ]; then
						tr -d ${class_del} <"${filepath}" | tr -dc ${class_keep}
					else
						tr -d ${class_del} <"${filepath}"
					fi
				else
					tr -dc ${class_keep} <"${filepath}"
				fi
			else
				if [ -n "${class_del}" ]; then
					if [ -n "${class_keep}" ]; then
						echo "${str}" | tr -d ${class_del} | tr -dc ${class_keep}
					else
						echo "${str}" | tr -d ${class_del}
					fi
				else
					echo "${str}" | tr -dc ${class_keep}
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
