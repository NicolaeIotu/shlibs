#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

# TAG: PRE-H/O, TEST

# issue: some versions of awk don't recognize char classes format
# solution: declare vars replacing char classes

test "$(echo ' a' | ${SHLIBS_AWK} '{ sub(/[[:space:]]/,""); print }' 2>/dev/null)" = 'a'
