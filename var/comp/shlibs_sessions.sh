#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com


if [ -z "${shlibs_session}" ]; then
	mkdir -p './var/tmp'
	while [ -d "./var/tmp/${shlibs_session}" ]
	do
		if shlibs_session=$(./shlibs str005) ; then :
		else
			s_err 'Cannot create session. Missing lib code str005.'
			exit 1
		fi
	done
fi

shlibs_session_dir="${shlibs_dirpath}/var/tmp/${shlibs_session:?}"

if [ -d "${shlibs_session_dir}" ]; then :
else		
	if mkdir -p "${shlibs_session_dir}" ; then : :
	else
		s_err 'Cannot create session.'
		exit 1
	fi
fi

# $1 text
# $2 basename of destination (files), or name of variable (memory)
ss_store() {
	if [ ${dq_search_result_count} -gt ${SHLIBS_MAX_RESULTS_MEM} ]; then
		# store in files
		eval ss_store_2=$(printf "%s" "$"${2}"")
		
		if echo "${ss_store_2}${1}" >> \
			"${shlibs_session_dir}/${2}" ; then
			eval "$2"=''
		else
			return 1
		fi
	else
		# keep in memory
		if eval "$2"="$(printf "%s%b" "$"${2}"" \""${1}"\\n\")" ; then :
		else
			return 1
		fi
	fi
}

# $1 integer, the number of the line to be retrieved (or interval 
# given as 'digit,digit' i.e. '1,6'
# $2 basename of destination (files), or name of variable (memory)
ss_retrieve() {
	if [ ${dq_search_result_count} -gt ${SHLIBS_MAX_RESULTS_MEM} ]; then
		# retrieve from files
		if ss_rtrv=$(sed "${1}"' !d' "${shlibs_session_dir}/${2}") ; then :
		else
			# session info unavailable
			s_err 'Session info unavailable.'
			return 1
		fi
	else
		# retrieve from memory
		eval ss_retrieve_2=$(echo "$"${2}"")
		ss_rtrv=$(echo "${ss_retrieve_2}" | sed "${1}"' !d')
	fi
	echo "${ss_rtrv}"
}
