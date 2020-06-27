#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

port001_get_random_port() {
	retries=$((retries+1))
	rnd=$( "${shlibs_dirpath}"/shlibs str005 -xp -xa -xA 8 )
	rnd="0.${rnd}"
	port001_active_port=$( "${shlibs_dirpath}"/shlibs mth004 -fmt "%.0f" \
		"(${rnd}*${delta_port})+${min_port}" )
}

port001() {
	# port001 relies on tool lsof
	if type lsof >/dev/null 2>&1 ; then :
	else
		echo 'Installing critical tool "lsof" ...' >/dev/fd/2
		if "${shlibs_dirpath}"/shlibs gen001 -install -y lsof >/dev/fd/2 2>&1 ; then :
		else
			echo 'Could not find/install critical tool "lsof". Retry or install manually.'
			return 1
		fi
	fi
	
	if [ ${#} -lt 4 ]; then
		ports_count=1
		ports_out=''
		port_index=1
		max_retries=100
		retries=0
		req_ephemeral_min_port=1025
		req_ephemeral_max_port=65535
		iana_ephemeral_min_port=49152
		iana_ephemeral_max_port=65535
		local_ephemeral_min_port=0
		local_ephemeral_max_port=0
		
		while [ ${#} -gt 0 ]
		do
			case ${1} in
				+[1-9][0-9]*)
					req_ephemeral_min_port=${1#+}
					shift
				;;
				-[1-9][0-9]*)
					req_ephemeral_max_port=${1#-}
					shift
				;;
				[1-9]|[1-9][0-9]*)
					if [ ${1} -gt 0 2>/dev/null ] && \
						[ ${1} -lt 101 2>/dev/null ]; then
						ports_count=${1}
					else
						echo "Too many ports: ${1}"
						return 1
					fi
					shift
				;;
				*)
					printf "${S_ERR_1}" "${rl_dev_code}"
					return 1
				;;
			esac
		done

		# get the real range
		local_port_range_file='/proc/sys/net/ipv4/ip_local_port_range'
		if [ -r "${local_port_range_file}" ]; then
			local_ephemeral_min_port=$( \
				cat "${local_port_range_file}" | cut -f1 ) 2>/dev/null
			local_ephemeral_max_port=$( \
				cat "${local_port_range_file}" | cut -f2 ) 2>/dev/null
		fi
		if [ ${local_ephemeral_min_port} -gt 0 2>/dev/null ] && \
			[ ${local_ephemeral_max_port} -gt 0 2>/dev/null ]; then :
		else
			local_ephemeral_min_port=${iana_ephemeral_min_port}
			local_ephemeral_max_port=${iana_ephemeral_max_port}
		fi
		
		req_ephemeral_min_port=$( "${shlibs_dirpath}"/shlibs mth001 \
			${req_ephemeral_min_port} \
			${local_ephemeral_min_port} ${local_ephemeral_max_port} )
		req_ephemeral_max_port=$( "${shlibs_dirpath}"/shlibs mth001 \
			${req_ephemeral_max_port} \
			${local_ephemeral_min_port} ${local_ephemeral_max_port} )
		
		min_port=$( "${shlibs_dirpath}"/shlibs mth003 \
			${req_ephemeral_min_port} ${local_ephemeral_min_port} )
		max_port=$( "${shlibs_dirpath}"/shlibs mth002 \
			${req_ephemeral_max_port} ${local_ephemeral_max_port} )
		if [ ${max_port} -lt ${min_port} ]; then
			tmp=${min_port}
			min_port=${max_port}
			max_port=${tmp}
		fi
		
		delta_port=$((max_port-min_port))
		if [ $((delta_port+1)) -lt ${ports_count} ]; then
			echo "Too many ports (${ports_count}) for the available range ${min_port}-${max_port}."
			return 1
		fi
		port001_get_random_port
		
		while [ ${port_index} -le ${ports_count} ];
		do
			if lsof -i :${port001_active_port} >/dev/null ; then :
			else
				if echo "${ports_out}" |  grep ${port001_active_port} >/dev/null ; then :
				else
					if [ -n "${ports_out}" ]; then
						ports_out="${ports_out} ${port001_active_port}"
					else
						ports_out="${port001_active_port}"
					fi
					port_index=$((port_index+1))
				fi
			fi
			
			port001_get_random_port
			if [ ${retries} -ge ${max_retries} ]; then
				echo "Reached max effort: ${max_retries} iterations. Please try again."
				return 1
			fi
		done
		
		echo "${ports_out}"
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

port001_help() {
	echo 'Get random free ephemeral ports'
	echo 'Default adjustable range is IANA 49152-65535'
	echo 'Requires elevated privileges.'
	echo 'Optional parameters:'
	echo ' - the number of ports (default 1, maximum 100)'
	echo ' - use "+integer" representing the start of the IP range'
	echo ' - use "-integer" representing the end of the IP range'
	echo 'Custom ranges must be continuous, otherwise limits get swapped.'
	echo 'Returns 0 on success and 1 on errors.'
}

port001_examples() {
	echo 'shlibs port001 3'
	echo 'Result: 53376 40186 48727'
	echo 'sudo -i shlibs port001 5'
	echo 'Result: 37731 55796 58276 46436 41123'
}

# prevent failing tests on OSes missing required components
port001_skip_tests=0
