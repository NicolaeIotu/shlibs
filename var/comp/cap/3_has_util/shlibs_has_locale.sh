#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

# TAG: PRE-H/O, TEST

# issue: locale utility missing on some systems (Minix)
# solution: indicate if missing 
if type locale >/dev/null 2>&1 ; then
	SHLIBS_HAS_LOCALE=0
	SHLIBS_YESEXPR="`locale yesexpr`"
else
	SHLIBS_HAS_LOCALE=1
	SHLIBS_YESEXPR='y'
fi


if [ ${SHLIBS_HAS_LOCALE} -eq 0 ] ; then
	SHLIBS_ORIG_LC_MESSAGES=`locale | ${SHLIBS_GREP} LC_MESSAGES \
		2>/dev/null | sed 's/\(LC_MESSAGES=\|\"\)//g' | ${SHLIBS_GREP} \
		-E "^(POSIX|C|en_.*)$" 2>/dev/null`
else
	# this case is for systems where locale is not found
	SHLIBS_ORIG_LC_MESSAGES=POSIX
fi


if type setenv >/dev/null 2>&1 ; then
	SHLIBS_HAS_SETENV=0
else
	SHLIBS_HAS_SETENV=1
fi
export SHLIBS_HAS_LOCALE SHLIBS_YESEXPR SHLIBS_ORIG_LC_MESSAGES SHLIBS_HAS_SETENV
