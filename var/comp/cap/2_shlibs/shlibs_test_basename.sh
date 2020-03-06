#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

# TAG: PRE-H/O, TEST

SHLIBS_BASENAME=''

stb() {
	stb_test_file='./var/comp/cap/2_shlibs/basename/shlibs_basename_has--.sh'
	if eval "${SHLIBS_SHELL}" "${stb_test_file}" >/dev/null 2>&1 ; then
		SHLIBS_BASENAME='basename'
	else
		SHLIBS_BASENAME='basename --'
	fi
}

stb

export SHLIBS_BASENAME
