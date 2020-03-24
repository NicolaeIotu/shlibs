#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

ssa_run_adjustment() {
	tput_lines=`tput lines`
	req_p_s=`expr ${SHLIBS_MATCH_PAGE_SIZE} + 10`
	if [ ${req_p_s} -ge ${tput_lines} ]; then
		SHLIBS_MATCH_PAGE_SIZE=`expr ${tput_lines} - 10`
	fi
	if [ ${SHLIBS_MATCH_PAGE_SIZE} -lt 3 ]; then
		SHLIBS_MATCH_PAGE_SIZE=3
	elif [ ${SHLIBS_MATCH_PAGE_SIZE} -gt 50 ]; then
		SHLIBS_MATCH_PAGE_SIZE=50
	fi
	
	
	if [ ${SHLIBS_MATCH_MAX} -eq 0 ]; then
		SHLIBS_MATCH_MAX=9999
	elif [ ${SHLIBS_MATCH_MAX} -lt 5 ]; then
		SHLIBS_MATCH_MAX=5
	fi
	
	
	if [ ${SHLIBS_TERMINAL_CHAR_WIDTH} -lt 36 ]; then
		SHLIBS_TERMINAL_CHAR_WIDTH=36
	fi
	tput_cols=`tput cols`
	# enables proper display on BSDs
	if [ "${tput_cols}" = "${SHLIBS_TERMINAL_CHAR_WIDTH}" ] ; then
		SHLIBS_TERMINAL_CHAR_WIDTH=`expr ${SHLIBS_TERMINAL_CHAR_WIDTH} - 2`
	fi
}

ssa_run_adjustment
