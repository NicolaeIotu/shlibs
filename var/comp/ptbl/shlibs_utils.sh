#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

# TAGS: PORTABLE

# a newline
_nl=$(printf '%b' '\n\r')

# record separator
IRS=$(printf '\036')

# shlibs version
SHLIBS_VERSION=1.3.35
SHLIBS_RELEASE=4

# the email for requests
SHLIBS_REQUESTS='contact@shlibs.net'

export _nl IRS SHLIBS_VERSION SHLIBS_RELEASE SHLIBS_REQUESTS

su_cleanup_tmp() {
	# this cleans up tmp sessions older than a day only
	if find "./var/tmp"	 -depth -mtime +1 -a ! -name 'tmp' \
			-exec rm -rf "{}" ";" ; then :
	else
		s_err 'Non-critical: Cleaning up of tmp failed.'
		return 1
	fi
}

su_cleanup_tmp_onexit() {
	# this cleanup of tmp includes active session
	su_cleanup_tmp
	./shlibs dir001 "./var/tmp/${shlibs_session:?}" &
	wait
	#important
	echo ' '
	exit
}
