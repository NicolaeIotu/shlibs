#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com


. './var/comp/ptbl/shlibs_err.sh'
. './var/comp/ptbl/shlibs_utils.sh'
. './var/comp/shlibs_dev_utils.sh'

# query shlibs
if [ ${#} -eq 0 ]; then
	if [ -t 0 ]; then
		. './var/comp/shlibs_dev_query.sh'
		dev_query 0
		sdu_cleanup_tmp_onexit
	else
		s_err 'Interactive mode available only in terminal.'
		exit 1
	fi
fi

# handle options
if echo "${1}" | ${SHLIBS_GREP} -E '^-([^zvp]|reset)$' >/dev/null 2>&1 ; then
	. './var/comp/shlibs_options.sh'
	exit ${?}
fi

# handle lib requests
sg_lib_format='^[a-zA-Z0-9/_-][a-zA-Z0-9 ./_-]*$'
if echo "${1}" | ${SHLIBS_GREP} "${sg_lib_format}" >/dev/null 2>&1 ; then
	. './var/comp/shlibs_run_lib.sh'
		exit ${?}
else
	s_err 'Lib codes allow chars: a-zA-Z0-9./_-'
	exit 1
fi
