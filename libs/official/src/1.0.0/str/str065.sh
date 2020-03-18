#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str065() {
	if [ ${#} -gt 1 ]; then
		isfileinput=1
		filepath=''
		str=''
		class_yes=''
		class_no=''
		
		while [ ${#} -gt 0 ]
		do
			case ${1} in
				-alnum|-alpha|-blank|-cntrl|-digit|-graph|-lower|-print|-punct|-space|-upper|-xdigit)
					str065_class_aloc 'y' "${1#-}"
					shift
				;;
				-kalnum|-kalpha|-kblank|-kcntrl|-kdigit|-kgraph|-klower|-kprint|-kpunct|-kspace|-kupper|-kxdigit)
					str065_class_aloc 'n' "${1#-k}"
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
				--x*)
					class_no="${class_no}|${1#--x}"
					shift
					;;
				--*)
					class_yes="${class_yes}|${1#--}"
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
			( [ -n "${class_yes}" ] || [ -n "${class_no}" ] ); then
			
			if [ -n "${class_no}" ]; then
				class_no="^[^${class_no}]*$"
			fi
			if [ -n "${class_yes}" ]; then
				class_yes="^[${class_yes}]*$"
			fi
			
			
			awk_script__='
			BEGIN { class_yes="'"${class_yes}"'"; class_no="'"${class_no}"'" }
			{
				if(length>0) {
					if(ly>0 && match($0,""class_yes)==0) exit 1
					if(ln>0 && match($0,""class_no)==0) exit 1
				}
			}'
			
			if [ ${isfileinput} -eq 0 ]; then
				${SHLIBS_AWK} -v ly=${#class_yes} -v ln=${#class_no} \
					"${awk_script__}" <"${filepath}"
			else
				echo "${str}" | ${SHLIBS_AWK} -v ly=${#class_yes} \
					-v ln=${#class_no}  "${awk_script__}"
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

str065_class_aloc() {
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

str065_help() {
	echo 'Test string/file contains only (or no) classes of chars / chars'
	echo '(NO and YES tests can coexist)'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
	echo ' - use "-alnum" to pass if letters and numbers (-kalnum to fail)'
	echo ' - use "-alpha" to pass if letters (-kalpha to fail)'
	echo ' - use "-blank" to pass if blanks (-kblank to fail)'
	echo ' - use "-cntrl" to pass if control characters (-kcntrl to fail)'
	echo ' - use "-digit" to pass if numbers (-kdigit to fail)'
	echo ' - use "-graph" to pass if graphical characters (-kgraph to fail)'
	echo ' - use "-lower" to pass if lowercase characters (-klower to fail)'
	echo ' - use "-print" to pass if printable characters (-kprint to fail)'
	echo ' - use "-punct" to pass if punctuation characters (-kpunct to fail)'
	echo ' - use "-space" to pass if whitespace characters (-kspace to fail)'
	echo ' - use "-upper" to pass if uppercase characters (-kupper to fail)'
	echo ' - use "-xdigit" to pass if hexadecimal notation chars (-kxdigit to fail)'
	echo ' - use "--chars_to_look_for" to pass if chars ("--kchars_to_look_for" to fail)'
}

str065_examples() {
	echo 'shlibs str065 "abcd%^&*#.,ABCD1234567890" -punct -alnum -kspace -kcntrl'
	echo 'echo "${?}"'
	echo 'Result: 0'
}

str065_tests() {
	tests__='
shlibs str065 "abcd%^&*#.,ABCD1234567890" -punct -alnum -kspace -kcntrl ; echo ${?}
=======
0


shlibs str065 -f "$(shlibs -p tst009)" -punct -alnum -space; echo ${?}
=======
0
'
	echo "${tests__}"
}
