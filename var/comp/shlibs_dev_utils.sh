#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

# record separator
IRS=$(printf '\036')
export IRS

sdu_cleanup_tmp() {
	# this cleans up tmp sessions older than a day only
	if find "./var/tmp"	 -depth -mtime 1 -a ! -name 'tmp' \
			-exec rm -rf "{}" ";" ; then :
	else
		s_err 'Non-critical: Cleaning up of tmp failed.'
		return 1
	fi
}

sdu_cleanup_tmp_onexit() {
	# this cleanup of tmp includes active session
	sdu_cleanup_tmp
	$(./shlibs dir001 "./var/tmp/${shlibs_session:?}")
	#important
	echo ' '
	exit
}
