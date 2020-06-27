#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

# TAG: PRE-H/O, TEST

# issue: awk on some systems doesn't have a 'match' function to work with
# solution: find another awk version

echo a | ${SHLIBS_AWK} '{ match($0, "a") }'
