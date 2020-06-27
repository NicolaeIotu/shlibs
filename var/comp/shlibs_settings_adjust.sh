#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

ssa_run_adjustment() {
	# page size
	tput_lines=`tput lines`
	req_p_s=`expr ${SHLIBS_MATCH_PAGE_SIZE} + 8`
	SHLIBS_ADJ_MATCH_PAGE_SIZE=${SHLIBS_MATCH_PAGE_SIZE}
	if [ ${req_p_s} -gt ${tput_lines} ]; then
		SHLIBS_ADJ_MATCH_PAGE_SIZE=`expr ${tput_lines} - 8`
	fi
	
	if [ ${SHLIBS_ADJ_MATCH_PAGE_SIZE} -lt 3 ]; then
		SHLIBS_ADJ_MATCH_PAGE_SIZE=3
	elif [ ${SHLIBS_ADJ_MATCH_PAGE_SIZE} -gt 50 ]; then
		SHLIBS_ADJ_MATCH_PAGE_SIZE=50
	fi
	
	
	# results
	if [ ${SHLIBS_MATCH_MAX} -eq 0 ]; then
		SHLIBS_ADJ_MATCH_MAX=9999
	elif [ ${SHLIBS_MATCH_MAX} -lt 5 ]; then
		SHLIBS_ADJ_MATCH_MAX=5
	else
		SHLIBS_ADJ_MATCH_MAX=${SHLIBS_MATCH_MAX}
	fi
	
	
	# terminal width
	SHLIBS_ADJ_TERMINAL_CHAR_WIDTH=${SHLIBS_TERMINAL_CHAR_WIDTH}
	if [ ${SHLIBS_TERMINAL_CHAR_WIDTH} -lt 36 ]; then
		SHLIBS_ADJ_TERMINAL_CHAR_WIDTH=36
	fi
	tput_cols=`tput cols`
	# enables proper display on BSDs
	if [ "${tput_cols}" = "${SHLIBS_ADJ_TERMINAL_CHAR_WIDTH}" 2>/dev/null ] ; then
		SHLIBS_ADJ_TERMINAL_CHAR_WIDTH=`expr ${SHLIBS_ADJ_TERMINAL_CHAR_WIDTH} - 2`
	fi
	export SHLIBS_ADJ_MATCH_PAGE_SIZE SHLIBS_ADJ_MATCH_MAX SHLIBS_ADJ_TERMINAL_CHAR_WIDTH
	
	unset -v tput_lines tput_cols req_p_s
}

ssa_run_adjustment
