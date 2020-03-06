#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str005() {
	if [ ${#} -gt 5 ]; then
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
	
	p_size=16
	# important do not use classes of chars except punct
	p_alpha_lower='abcdefghijklmnopqrstuvwxyz'
	p_alpha_upper='ABCDEFGHIJKLMNOPQRSTUVWXYZ'
	p_digits='0123456789'
	p_punct=''
	while [ ${#} -gt 0 ]
	do
		case ${1} in
			-a)
				p_alpha_lower='abcdefghijklmnopqrstuvwxyz'
				shift
				;;
			-xa)
				p_alpha_lower=''
				shift
				;;
			-A)
				p_alpha_upper='ABCDEFGHIJKLMNOPQRSTUVWXYZ'
				shift
				;;
			-xA)
				p_alpha_upper=''
				shift
				;;
			-d)
				p_digits='0123456789'
				shift
				;;
			-xd)
				p_digits=''
				shift
				;;
			-p)
				p_punct="${SHLIBS_CCLASS_PUNCT}"
				shift
				;;
			-xp)
				p_punct=''
				shift
				;;
			[1-9]|[1-9][0-9]*)
				p_size=${1}
				shift
				;;
			*)
				echo "Invalid option '${1}'"
				return 1
				;;		
		esac
	done
	
	trans_seq="${p_alpha_lower}${p_alpha_upper}${p_digits}${p_punct}"
	if [ "${trans_seq}" = '' ]; then
		echo 'Must use at least one type of character.'
		return 1
	fi
	
	result=''
	while [ ${#result} -lt ${p_size} ]
	do
		res_int=$(printf "%s\n" $(dd if=/dev/urandom bs=10 count=10 2>/dev/null \
			| tr -dc ${trans_seq} 2>/dev/null) )
		result="${result}${res_int}"
	done
	
	if [ ${#result} -gt ${p_size} ]; then
		result=$(echo ${result} | cut -b -${p_size})
	fi
	
	echo $result
}

str005_help() {
	echo 'Generates random characters.'
	echo 'Maximum 5 optional parameters, any order:'
	echo ' - generated string length (default 16)'
	echo ' - (x)a options - (exclude) lowercase letters (default include -a)'
	echo ' - (x)A options - (exclude) uppercase letters (default include -A)'
	echo ' - (x)d options - (exclude) digits (default include -d)'
	echo ' - (x)p options - (exclude) punctuation (default exclude -xp)'
}

str005_examples() {
	echo 'shlibs str005    (exclude punctuation, 16 chars)'
	echo 'YdadcjB55r56q9eC'
	echo 'shlibs str005 10 -p -xA    (10 chars, include punctuation, exclude uppercase)'
	echo '%e<c8}5grd'
	echo 'shlibs str005 20 -xd    (20 chars, exclude digits)'
	echo 'dEEjpAPvNXAkdFKkwcjJ'
}

str005_tests() {
	tests__='
res="$(shlibs str005 22)"; echo ${#res}
=======
22


res="$(shlibs str005 22)"; shlibs str065 "${res}" -alnum ; echo ${?}
=======
0
'
	echo "${tests__}"
}
