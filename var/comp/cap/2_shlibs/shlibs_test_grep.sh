#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

# TAG: PRE-H/O, TEST

SHLIBS_GREP=''

stg() {
	stg_test_fld="${shlibs_dirpath}/var/comp/cap/2_shlibs/grep"
	stg_test_file_E="${stg_test_fld}/shlibs_grep_has_-E.sh"
	stg_test_file_F="${stg_test_fld}/shlibs_grep_has_-F.sh"
	
	if eval "${SHLIBS_SHELL}" "${stg_test_file_E}" >/dev/null 2>&1 && \
		eval "${SHLIBS_SHELL}" "${stg_test_file_F}" >/dev/null 2>&1 ; then
		SHLIBS_GREP='grep'
	else
		# add here logic for other OSes if required
		if file /usr/xpg4/bin/grep | grep executable >/dev/null 2>&1 ; then
			# Solaris 10
			SHLIBS_GREP='/usr/xpg4/bin/grep'
		else
			SHLIBS_GREP=''
		fi
	fi
}

stg

export SHLIBS_GREP
