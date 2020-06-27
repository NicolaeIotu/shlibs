#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

# TAGS: PRE-H/O, PORTABLE

S_ERR_1="Invalid arguments. Use 'shlibs -h %s' for help.\n"
S_ERR_2="Flag '-f' does not allow processing of extra strings."
export S_ERR_1 S_ERR_2

s_err() {
	if [ -n "${1}" ]; then
		# log administration
		sg_ld="${shlibs_dirpath}/var/log"
		sg_el="${sg_ld}/error.log"
		if [ -e "${sg_el}" ]; then
			# log administration
			sg_log_lines=`wc -l "${sg_el}" 2>/dev/null | xargs echo`
			sg_log_lines=${sg_log_lines% *}
			
			if [ ${sg_log_lines} -gt 1000 ]; then
				sg_logs_count=`ls -A "${sg_el}"* | wc -l | xargs echo`
				sg_logs_count=${sg_logs_count% *}
				sg_max_logs_count=10
				sg_log_id_no=${sg_logs_count}
				while [ ${sg_log_id_no} -gt 0 ] ;
				do
					sg_tlid="${sg_el}.${sg_log_id_no}"
					if [ -e "${sg_tlid}" ]; then
						if [ ${sg_log_id_no} -ge ${sg_max_logs_count} ]; then
							rm -f "${sg_tlid}" 2>/dev/null
						else
							sg_log_id_next=`expr ${sg_log_id_no} + 1`
							cp -f "${sg_tlid}" "${sg_el}.${sg_log_id_next}"
						fi
					fi
					sg_log_id_no=`expr ${sg_log_id_no} - 1`
				done
				
				mv -f "${sg_el}" "${sg_el}.1"
			fi
		else
			touch "${sg_el}"
		fi
		
		# show main error message
		if [ -n "${shlibs_dirpath}" ]; then
			printf "[ `date '+%F %T'` ] %s\n" "${1}" >> \
				"${sg_el}"
			echo "${1}"
		else
			printf "%s\n" "${1}"
		fi
	fi
}

err_fs() {
	s_err 'Critical file sys ops failed!'
	exit 1
}
