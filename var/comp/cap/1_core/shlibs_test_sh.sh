#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

# TAG: PRE-H/O, TEST

# shell vars
SHLIBS_SHELL='dash'
sts_allowed_shells='dash sh bash ksh'
SHLIBS_SHELL_PATH='/bin/dash'

sts() {
	SHLIBS_SHELL_PATH=`type "${1}" 2>/dev/null`
	if [ -n "$SHLIBS_SHELL_PATH" ]; then
		for sts_ssp in ${SHLIBS_SHELL_PATH}
		do :
		done
		SHLIBS_SHELL_PATH="${sts_ssp}"
		#IFS=${o_ifs}
	else
		return 1
	fi

	sts_tests='./var/comp/cap/1_core/1_sh/*'
	for sts_test_file in ${sts_tests}
	do
		if [ -d "${sts_test_file}" ]; then
			continue
		elif [ -r "${sts_test_file}" ]; then
			if ( eval "${1}" "${sts_test_file}" >/dev/null 2>&1 ) ; then :
			else
				return 1
			fi
		else
			return 1
		fi
	done
}

# expecting SHLIBS_FORCE_SHELL in env
if [ -n "${SHLIBS_FORCE_SHELL}" ]; then
	sts_allowed_shells=$SHLIBS_FORCE_SHELL
fi

for SHLIBS_SHELL in ${sts_allowed_shells}
do
	SHLIBS_SHELL_PATH=''
	if [ -n "${SHLIBS_SHELL}" ]; then
		if sts "${SHLIBS_SHELL}" ; then
			break
		else
			SHLIBS_SHELL=''
			SHLIBS_SHELL_PATH=''
			continue
		fi
	fi
done
export SHLIBS_SHELL SHLIBS_SHELL_PATH
