#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

# TAGS: PRE-H/O, PORTABLE

if [ -p '/dev/fd/0' ]; then
	# pipe to case
	shlibs_redirect=0
else
	if [ -t 0 ]; then
		# no redirection case
		shlibs_redirect=1
		shlibs_fb=''
	else
		# redirection to shlibs input
		# i.e. shlibs str002 < file.txt
		shlibs_redirect=0
	fi
fi	

# START important format! prevents Solaris11 errors
if [ ${shlibs_redirect} -eq 0 ]; then
	shlibs_fb=`dd bs=1 count=1 2>/dev/null`
	shlibs_fc=`echo "${shlibs_fb}" | od -t o1 -A n | tr -dc '0123456789'`
fi
if [ -n "${shlibs_fb}" ]; then
	shlibs_redir_vars_flag=0
	shlibs_redir_vars="${shlibs_fb}"`cat`
else
	shlibs_redir_vars_flag=1
	shlibs_redir_vars=''
fi
# END important format
