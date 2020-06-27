#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

# TAG: PRE-H/O, TEST

# awk vars
SHLIBS_AWK='awk'
sta_allowed_awk='awk gawk mawk'
SHLIBS_AWK_PATH='/bin/awk'

sta() {
	SHLIBS_AWK_PATH=`type "${1}" 2>/dev/null`
	if [ -n "$SHLIBS_AWK_PATH" ]; then
		for sta_sap in ${SHLIBS_AWK_PATH}
		do :
		done
		SHLIBS_AWK_PATH="${sta_sap}"
	else
		return 1
	fi
	
	sta_tests="${shlibs_dirpath}/var/comp/cap/2_shlibs/awk/*"
	for sta_test_file in ${sta_tests}
	do
		if [ -d "${sta_test_file}" ]; then
			continue
		elif [ -r "${sta_test_file}" ]; then
			export SHLIBS_AWK
			if eval "${SHLIBS_SHELL}" \
				"${sta_test_file}" >/dev/null 2>&1 ; then :
			else
				return 1
			fi
		else
			return 1
		fi
	done
}


for SHLIBS_AWK in ${sta_allowed_awk}
do
	SHLIBS_AWK_PATH=''
	if [ -n "${SHLIBS_AWK}" ]; then
		if sta "${SHLIBS_AWK}" ; then
			break
		else
			SHLIBS_AWK=''
			SHLIBS_AWK_PATH=''
			continue
		fi
	fi
done
# default (bin) awk on Solaris is highly unreliable for shlibs tasks
if [ -z "${SHLIBS_AWK_PATH}" ]; then
	# add here logic for other OSes if required
	if file /usr/xpg4/bin/awk | grep executable >/dev/null 2>&1 ; then
		# Solaris
		SHLIBS_AWK='/usr/xpg4/bin/awk'
		SHLIBS_AWK_PATH='/usr/xpg4/bin/awk'
	fi
fi
export SHLIBS_AWK SHLIBS_AWK_PATH
