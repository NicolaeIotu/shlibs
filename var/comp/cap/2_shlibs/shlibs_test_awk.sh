#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

# TAG: PRE-H/O, TEST

# awk vars
SHLIBS_AWK='awk'
sta_allowed_awk='awk,nawk,gawk,mawk'
SHLIBS_AWK_PATH='/bin/awk'

sta() {
	SHLIBS_AWK_PATH=`type "${1}" 2>/dev/null`
	if [ -n "$SHLIBS_AWK_PATH" ]; then
		IFS=' '
		for sta_sap in ${SHLIBS_AWK_PATH}
		do :
		done
		SHLIBS_AWK_PATH="${sta_sap}"
		IFS=${o_ifs}
	else
		return 1
	fi
	
	sta_tests='./var/comp/cap/2_shlibs/awk/*'
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


IFS=','
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
IFS=${o_ifs}
export SHLIBS_AWK
export SHLIBS_AWK_PATH
