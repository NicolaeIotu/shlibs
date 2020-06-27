#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

# TAG: PRE-H/O, TEST

# issue: find utility missing on some systems (Q4OS)
# solution: indicate if missing 
	
if type file >/dev/null 2>&1 ; then
	SHLIBS_HAS_FILE=0
else
	SHLIBS_HAS_FILE=1
fi
export SHLIBS_HAS_FILE
