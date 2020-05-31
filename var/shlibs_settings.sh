#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

# TAGS: PRE-H/O


# The number of results per page
# default: 10 (interval 3-50)
SHLIBS_MATCH_PAGE_SIZE=10


# The maximum number of results displayed
# default: 400 (use 0 to display all; minimum 5)
SHLIBS_MATCH_MAX=400


# The maximum number of results kept in memory
# shlibs tries to keep in vars the search results. If this value is exceeded
# shlibs uses files to store / retrieve results. These I/O ops will 
# slow down search related operations, but decrease memory load.
# default: 10000
SHLIBS_MAX_RESULTS_MEM=10000


# Shows options and shortcuts when query or setup is active
# default: 0 (meaning true)
SHLIBS_SHOW_OPTIONS=0


# When setting up a script ( -s ), instances of 'shlibs'
# will be highlighted ( i.e. *** shlibs *** ) using below character 
# default: *
SHLIBS_MATCH_HIGHLIGHT="*"


# Keeps the terminal clean.
# default: 0 (meaning true) (recommended)
SHLIBS_CLEANUP_DISPLAY=0


# This setting is used to fold lines in order to fit display device.
# default: 80 (minimum 36)
SHLIBS_TERMINAL_CHAR_WIDTH=80


# Forces shlibs to run using specified shell 
# (one word, or comma separated, no whitespace, list of shells)
# default: '' (auto selection)
# usage: SHLIBS_FORCE_SHELL='bash'
SHLIBS_FORCE_SHELL=''


# Prints the version of each lib when showing the list of search results
# in query or setup mode. This is particularly useful for advanced users 
# when developing new versions of libs or/and using own libs/versions.
# default: 1 (meaning false)
SHLIBS_SHOW_VERSION_IN_QUERY=1
export SHLIBS_MATCH_PAGE_SIZE SHLIBS_MATCH_MAX SHLIBS_MAX_RESULTS_MEM \
	SHLIBS_SHOW_OPTIONS SHLIBS_MATCH_HIGHLIGHT SHLIBS_CLEANUP_DISPLAY \
	SHLIBS_TERMINAL_CHAR_WIDTH SHLIBS_FORCE_SHELL SHLIBS_SHOW_VERSION_IN_QUERY
