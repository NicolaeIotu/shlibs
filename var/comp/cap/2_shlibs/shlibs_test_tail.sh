#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

# TAG: PRE-H/O, TEST

SHLIBS_TAIL=''

stt() {
	stt_test_fld='./var/comp/cap/2_shlibs/tail'
	
	if eval "${SHLIBS_SHELL}" "${stt_test_fld}/shlibs_tail_has_n.sh" \
		>/dev/null 2>&1 ; then
		SHLIBS_TAIL='tail'
	else
		# add here checks for other OSes if required
		if file /usr/xpg4/bin/tail | grep executable >/dev/null 2>&1 ; then
			# Solaris
			SHLIBS_TAIL='/usr/xpg4/bin/tail'
		else
			SHLIBS_TAIL=''
		fi
	fi
}

stt

export SHLIBS_TAIL
