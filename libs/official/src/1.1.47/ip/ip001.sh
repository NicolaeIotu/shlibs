#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

ip001() {
	# ip001 relies on tool dig
	if type dig >/dev/null 2>&1 ; then :
	else
		echo 'Installing critical tool "dig" ...' >/dev/fd/2
		if "${shlibs_dirpath}"/shlibs gen001 -install -y dig >/dev/fd/2 2>&1 ; then :
		else
			echo 'Could not find/install critical tool "dig". Retry or install manually.'
			return 1
		fi
	fi
	
	if [ ${#} -lt 2 ]; then
		isipv4=1
		isipv6=1
	
		while [ ${#} -gt 0 ]
		do
			case ${1} in
				-4)
					isipv4=0
					shift
				;;
				-6)
					isipv6=0
					shift
				;;
				*)
					printf "${S_ERR_1}" "${rl_dev_code}"
					return 1
				;;
			esac
		done
		
		if [ ${isipv4} -eq 0 ]; then
			q_type=A
			q_opt='-4'
		elif [ ${isipv6} -eq 0 ]; then
			q_type=AAAA
			q_opt='-6'
		else
			q_type=ANY
			q_opt=''
		fi
		
		while read dig_set ;
		do
			res=$(eval "${dig_set}" | tr -d [\"\'])
			if [ -n "${res}" ]; then
				if echo "${res}" | "${shlibs_dirpath}"/shlibs str065 \
						-digit -punct ; then
					# is IPv4
					echo "${res}" | tr -dc ".${SHLIBS_CCLASS_DIGIT}" \
						| xargs echo
					return
				elif echo "${res}" | "${shlibs_dirpath}"/shlibs str065 \
						-xdigit -punct ; then
					# is IPv6
					echo ${res}  | \
						tr -dc ":.${SHLIBS_CCLASS_XDIGIT}${SHLIBS_CCLASS_SPACE}" \
						| xargs echo
					return
				else
					continue
				fi
			fi
		done < "${rl_lib_dirpath}/ip001.dat"
		
		printf "Could not get a valid IP%s. Please check services listed in %s\n" \
			"${q_opt}" "${rl_lib_dirpath}/ip001.dat"
		return 1

	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

ip001_help() {
	echo 'Get public facing IPv4, or IPv6'
	echo 'Parameters:'
	echo ' - optional use "-4" to return IPv4 address'
	echo ' - optional use "-6" to return IPv6 address'
}

ip001_examples() {
	echo 'Get public facing IPv4 of current connection:'
	echo 'shlibs ip001 -4'
	echo 'Get public facing IPv6 of current connection:'
	echo 'shlibs ip001 -6'
}

ip001_skip_tests=0
