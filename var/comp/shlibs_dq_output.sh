#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

# controls some of shlibs own output (libs are handled in ss_retrieve)
dq_cut_print() {
	echo "${1}" | cut -b -${SHLIBS_ADJ_TERMINAL_CHAR_WIDTH}
}

dq_last_fold_count_lines=0
export dq_last_fold_count_lines

dq_fold() {
	if [ ${#1} -gt ${SHLIBS_ADJ_TERMINAL_CHAR_WIDTH} ]; then
		dq_fold_result=$(echo "${1}" | fold -w ${SHLIBS_ADJ_TERMINAL_CHAR_WIDTH})
	else
		dq_fold_result=$(echo "${1}")
	fi
	
	dq_last_fold_count_lines=$(echo "${dq_fold_result}" | wc -l)
	#important!
	dq_last_fold_count_lines=$((dq_last_fold_count_lines))
	echo "${dq_fold_result}"
}
