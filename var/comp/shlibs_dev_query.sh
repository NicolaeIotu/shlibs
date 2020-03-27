#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

trap - INT KILL TERM
trap sdu_cleanup_tmp_onexit INT KILL TERM

. ./var/comp/shlibs_sessions.sh
. ./var/comp/shlibs_dq_output.sh

# libs version
if dq_libs_version=$(./shlibs -h ofc002) ; then
	export dq_libs_version
else
	s_err 'Critical Error: Cannot find the version of the libraries (lib code ofc002).'
	exit 1
fi

dq_get_version() {
	# function comparable with shlibs_run_lib.sh handling of versions
	# (change both if required)
	dq_mvers=0
	dq_find_index=0
	dq_mfind_index=0
	IFS=${nl}
	for dq_mvers_lib in ${dq_opti_hdr_for_code}
	do
		dq_find_index=$((dq_find_index+1))
		if [ -r "${dq_mvers_lib}" ]; then
			dq_ivers=$(${SHLIBS_AWK} \
				'{ match($0,/r_l_s:/); \
				if (RSTART > 0) { print substr($0, RSTART+7); } }' \
				< "${dq_mvers_lib}" | xargs)
			
			if [ -n "${dq_ivers}" ]; then
				if [ ${dq_opti_hdr_for_code_count} -gt 1 ]; then
					if [ ${dq_ivers} -gt ${dq_mvers} ]; then
						dq_mvers=${dq_ivers}
						dq_mfind_index=${dq_find_index}
					fi
				else
					dq_mvers=${dq_ivers}
				fi
			fi
		fi
	done
	IFS=${o_ifs}
	
	test ${dq_mvers} -gt 0 2>/dev/null || {
		s_err "Invalid version number (${dq_mvers}) at '${dq_opti_hdr_for_code}'"
		exit 1
	}
	
	if [ ${dq_mvers} -gt 0 ]; then
		if [ ${dq_opti_hdr_for_code_count} -gt 1 ]; then
			dq_opti_hdr_for_code=$(echo "${dq_opti_hdr_for_code}" \
				| sed "${dq_mfind_index}"' !d' )
		fi
		# else just keep dq_opti_hdr_for_code intact
	else
		# no valid version; just get the last found lib
		dq_opti_hdr_for_code=$(echo "${dq_opti_hdr_for_code}" \
			| sed "${dq_find_index}"' !d' )
	fi
}


dq_fs_mem_err='Could not process search results due to fs/mem issues.'
dq_file_on_trav_dir() {
	otd_all='' otd_any=''
	otd_any_count=0
	
	otd_lib_code="${1##*/}"
	otd_lib_dir=$( pwd -L )
	otd_lib_dir_libs_relative="${otd_lib_dir#${shlibs_dirpath}/libs/}"

	dq_mvers=0 dq_ivers=0
	dq_opti_hdr_for_code='' dq_opti_hdr_for_code_count=0
	
	# determine if keywords are present
	# split by commas first
	IFS=','
	for otd_any in ${dq_keywords_esc}
	do
		otd_match=1
		
		# minimum 2 chars
		if [ ${#otd_any} -ge 2 ]; then
			IFS=' '
			for otd_all in ${otd_any}
			do
				if [ ${#otd_all} -ge 2 ]; then
					if ${SHLIBS_GREP} "${dq_k_search_grep_opts_i_F}" \
						"${otd_all}" "${1}" >/dev/null 2>&1 ; then
						# no duplicate codes allowed for optimized
						if [ ${sk_optimized} -eq 0 ]; then
							dq_opti_hdr_for_code=$(find -L "${otd_lib_dir}" \
								-name "${otd_lib_code}" -type f)
							dq_opti_hdr_for_code_count=$(echo \
								"${dq_opti_hdr_for_code}" | wc -l | xargs echo)
							dq_get_version
						fi
					else
						otd_match=0
						break
					fi				
				fi
			done
			
			if [ ${otd_match} -eq 1 ]; then
				otd_any_count=$((otd_any_count+1))
			fi
		fi
	done
	IFS=${o_ifs}
	
	if [ ${otd_any_count} -gt 0 ]; then
		dq_search_result_count=$((dq_search_result_count+1))
		
		# full path and section is required in order to copy dependencies 
		if [ ${sk_optimized} -eq 0 ]; then
			dq_search_keywords_file="${dq_opti_hdr_for_code}"
			
			dq_opti_paths_for_code=$(echo "${dq_opti_hdr_for_code}" | \
				${SHLIBS_AWK} '{
					match($0, /.\/libs\/(official|dev|community)\/headers\//);
					if (RSTART > 0) {
						m=substr($0, RSTART, RLENGTH);
						sub("headers","src",m);
						print substr($0, 1, RSTART-1)m substr($0, RSTART+RLENGTH)".sh"; 
					} else {
						print "";
					}
				}')
				
			if [ -r "${dq_opti_paths_for_code}" ]; then :
			else
				s_err "Cannot read src of \
'${dq_opti_paths_for_code:-${dq_opti_hdr_for_code}}'."
				exit 1
			fi
			
			if {
				ss_store "${dq_opti_hdr_for_code}" 'search_results_headers' ;
				ss_store "${dq_opti_paths_for_code}" 'search_results_deps' ;
				} ; then :
			else
				s_err "${dq_fs_mem_err}"
				exit 1
			fi
		else
			dq_search_keywords_file="${1}"
			
			if {
				ss_store '' 'search_results_headers' ;
				ss_store "${otd_lib_dir}/${otd_lib_code}" 'search_results_deps' ;
				} ; then :
			else
				s_err "${dq_fs_mem_err}"
				exit 1
			fi
		fi
		
		otd_dest_hdr_raw="${otd_lib_dir_libs_relative#${sk_section}}"
		if [ ${sk_optimized} -eq 0 ]; then
			otd_dest_src_raw=$(echo "${otd_dest_hdr_raw}" | \
				sed "s/\/headers\//\/src\//")
				
			if [ "${sk_section}" = 'official' ]; then
				otd_dest_src_raw="${otd_dest_src_raw}/${otd_lib_code}.sh"
			else
				otd_dest_src_raw="${sk_section}${otd_dest_src_raw}/${otd_lib_code}.sh"
			fi
		else
			otd_dest_src_raw="${otd_lib_dir#${shlibs_dirpath}/libs/}"
			otd_dest_hdr_raw=''
		fi
		
		
		if {
			ss_store "${otd_dest_hdr_raw}" 'search_results_ext_headers' ;
			ss_store "${otd_dest_src_raw}" 'search_results_ext_srcs' ;
			ss_store "${sk_section}" 'search_results_section' ;
			ss_store "${otd_lib_code}" 'search_results_lib_code' ;
			} ; then :
		else
			s_err "${dq_fs_mem_err}"
			exit 1
		fi
		
		if ss_store "${dq_mvers}" 'search_results_version' ; then :
		else
			s_err "${dq_fs_mem_err}"
			exit 1
		fi	
		
		if [ -f "${dq_search_keywords_file}" ]; then
			sk_info=$(${SHLIBS_AWK} \
				'{ match($0,/i_n_f:/); \
				if (RSTART > 0) { print substr($0, RSTART+7); } }' \
				< "${dq_search_keywords_file}" | xargs)

			if [ ${dq_mvers} -gt 0 ]; then
				if [ ${SHLIBS_SHOW_VERSION_IN_QUERY} -eq 0 ]; then
					sk_info=" - (v ${dq_mvers}) ${sk_info}"
				else
					sk_info=" - ${sk_info}"
				fi
			fi
		else
			sq_print_error "Cannot read ${dq_search_keywords_file}"
			return 1
		fi
				
		
		if [ "${sk_section}" = 'official' ]; then
			if {
				dq_tmp_ops=$(printf "[%s] %s%s\n" "${dq_search_result_count}" \
					"${otd_lib_code}" "${sk_info}")
				ss_store "${dq_tmp_ops}" 'search_results' ;
				
				ss_store "${otd_lib_code}" 'search_results_target_lib_code' ;
				} ; then :
			else
				s_err "${dq_fs_mem_err}"
				exit 1
			fi
		else
			if {				
				if [ ${sk_optimized} -eq 0 ]; then
					dq_tmp_ops=$(printf "[%s] %s\n" "${dq_search_result_count}" \
						"${otd_dest_src_raw}" ) ;
					ss_store "${dq_tmp_ops}" 'search_results' ;
					
					dq_tmp_ops=$(printf "%s\n" "${otd_dest_src_raw}" ) ;
				else
					dq_tmp_ops=$(printf "[%s] %s/%s%s\n" "${dq_search_result_count}" \
						"${otd_dest_src_raw}" "${otd_lib_code}" \
						"${sk_info}") ;
					ss_store "${dq_tmp_ops}" 'search_results' ;
					
					dq_tmp_ops=$(printf "%s/%s\n" \
						"${otd_lib_dir_libs_relative}" "${otd_lib_code}") ;
				fi
				ss_store "${dq_tmp_ops}" 'search_results_target_lib_code' ;
				} ; then :
			else
				s_err "${dq_fs_mem_err}"
				exit 1
			fi
		fi
	fi
}


dq_trav_dir() {	
	cd "${1}" || err_fs
	for td_file in ./*
	do
		if [ ${dq_search_result_count} -ge ${SHLIBS_MATCH_MAX} ]; then
			cd "${shlibs_dirpath}" || err_fs
			return
		fi
		if [ -d "${td_file}" ]; then
			dq_trav_dir "${td_file}"
		else
			if [ -f "${td_file}" ]; then
				td_basename="${td_file##*/}"
				# if optimized allow only files with no extension
				if [ ${sk_optimized} -eq 0 ] && \
					[ "${td_basename}" != "${td_basename%.*}" ]; then
						continue
				fi
				sk_search_count=$((sk_search_count+1))
				dq_file_on_trav_dir "${td_file}"
			fi
		fi
	done
	cd "./.." || err_fs
}


dq_search_rep_seq() {
	# $1 - official, dev, community
	sk_section="${1}"
	# try to find an optimized version: split headers and src folders
	if [ -d "${sk_td}/${1}/src" ] && [ -d "${sk_td}/${1}/headers" ]; then
		sk_optimized=0
		dq_trav_dir "${sk_td}/${1}/headers"
	else
		sk_optimized=1
		dq_trav_dir "${sk_td}/${1}"
	fi
}

dq_search_keywords() {
	dq_search_result_count=0
	# clean up previous search results
	if [ -d "${shlibs_session_dir}" ]; then
		if find "${shlibs_session_dir}" -name "search_results*" \
				-type f -exec rm -f {} ";" 2>/dev/null ; then
			# important
			search_results='' search_results_deps='' 
			search_results_ext_headers='' search_results_ext_srcs='' 
			search_results_headers='' search_results_lib_code=''
			search_results_section='' search_results_target_lib_code='' 
			search_results_version=''
		else
			s_err 'Dev Query: Could not start a fresh search. Cleanup failed.'
			exit 1
		fi
	fi
	
	sk_search_count=0
	# expecting ${shlibs_dirpath} current working dir!
	sk_td="./libs"
	
	if [ ${dq_k_search} -eq 1 ]; then
		dq_k_search_grep_opts_i_F='-iF'
	else
		dq_k_search_grep_opts_i_F='-i'
	fi
	
	cd "${shlibs_dirpath}" || err_fs
	if [ -n "${dq_focused_section}" ]; then
		dq_search_rep_seq "${dq_focused_section}"
	else
		dq_search_rep_seq "official"
		cd "${shlibs_dirpath}" || err_fs
		if [ ${dq_search_result_count} -ge ${SHLIBS_MATCH_MAX} ]; then
			return
		fi
		
		dq_search_rep_seq "dev"
		cd "${shlibs_dirpath}" || err_fs
		if [ ${dq_search_result_count} -ge ${SHLIBS_MATCH_MAX} ]; then
			return
		fi
		
		dq_search_rep_seq "community"
		cd "${shlibs_dirpath}" || err_fs
		if [ ${dq_search_result_count} -ge ${SHLIBS_MATCH_MAX} ]; then
			return
		fi
	fi
	cd "${shlibs_dirpath}" || err_fs
	
	#important
	dq_k_search=1
}


dq_reset() {
	dq_keywords='' dq_keywords_esc='' dq_libcode='' dq_target_libcode=''
	dq_on=0 dq_search_on=1 dq_navigate=1 dq_oob_nav=1
	dq_search_result_count=0 dq_rc=0 dq_ui='' dq_k_search=1
	dq_page=1 dq_max_page=1 dq_lib_help=1 dq_lib_examples=1
	dq_v_wording='' dq_mvers=0 dq_ivers=0
	dq_focused_section='' dq_overwrite_search_start_lines=0
	dq_tmp_print='' dq_page_list_diff_count_lines=0
	
	# important
	search_results='' search_results_deps='' search_results_ext_headers=''
	search_results_ext_srcs='' search_results_headers='' search_results_lib_code=''
	search_results_section='' search_results_target_lib_code='' search_results_version=''
	
	if [ -d "${shlibs_session_dir}" ]; then
		if find "${shlibs_session_dir}" -name "[search_results|dq_lib]*" \
				-type f -exec rm -f {} ";" 2>/dev/null ; then :
		else
			s_err 'Dev Query: Could not reset environment!'
			exit 1
		fi
	fi
	
	if [ -n "${1}" ]; then
		dq_overwrite=1 dq_show_basic_help=1 dq_show_full_help=1
		dq_overwrite_listing=0 dq_overwrite_prompt=0
		dq_overwrite_found=0 dq_page_list_diff_count_lines=0
		dq_overwrite_he_ex=0 dq_overwrite_total=0
		dq_ui_duplicate=1
	fi
}


dq_process_keywords() {
	if [ ${#dq_ui} -lt 2 ]; then
		dq_show_basic_help=0
		return
	fi
	
	# important!
	dq_ui=$(echo "${dq_ui}" | tr -d '[:cntrl:]')
	
	# simple search (no k+) allows focused search, with no BRE
	# a simple search (no k+) activates focused search for all terms stored
	if [ ${dq_k_search} -eq 1 ]; then
		# identify focused search i.e. dev/trim
		dq_focused_section=${dq_ui#/}
		dq_focused_section=${dq_focused_section%%/*}
		if [ "${dq_focused_section}" = "${dq_ui}" ]; then
			dq_focused_section=''
		else
			dq_ui=${dq_ui#*/}
			
			case "${dq_focused_section}" in
				official|dev|community)
					dq_ui=${dq_ui#/}
					dq_ui=${dq_ui#${dq_focused_section}/}
				;;
				*)
					dq_focused_section=''
				;;
			esac
		fi
	else
		# k+ does unfocused search; BRE can be used
		# k+ enables unfocused search for all terms stored until k+ occured
		dq_focused_section=''
	fi
	
	# handle duplicates
	# 'k+term' and 'term' are duplicates!
	dq_ui_duplicate=1
	IFS=','
	for ex_kywrd in ${dq_keywords}
	do
		if [ "${ex_kywrd}" = "${dq_ui}" ]; then
			dq_ui_duplicate=0
			break
		fi
	done
	IFS=${o_ifs}
	
	if [ ${dq_ui_duplicate} -eq 1 ]; then		
		if [ ${#dq_ui} -gt 1 ]; then
			dq_keywords="${dq_keywords:+${dq_keywords},}${dq_ui}"
			dq_search_on=0
		else
			if [ ${dq_ctrl_d} -eq 0 ]; then
				dq_overwrite_listing=$((dq_overwrite_listing-1))
			else
				dq_cut_print 'At least 2 characters required.'
				dq_overwrite_listing=$((dq_overwrite_listing+1))
			fi
			dq_show_basic_help=0
		fi
	else
		# this will trigger search simulacrum in order to keep a correct
		# count of lines to be rewritten
		dq_search_on=0
	fi
}

		
dev_query(){
	dq_reset 0
	if [ "${1}" = '0' ]; then
		dq_intro="shlibs Query (v ${SHLIBS_VERSION}/libs ${dq_libs_version})\n"
		printf "${dq_intro}\n"
		dq_reset_summary_wording='Reset'
	else
		dq_intro="${ss_intro}"
		dq_reset_summary_wording='Summarize'
	fi
	
	while [ ${dq_on} -eq 0 ]
	do
		if [ ${dq_overwrite} -eq 0 ] && \
			[ "${SHLIBS_CLEANUP_DISPLAY}" = '0' ]; then	
			
			if [ ${dq_show_basic_help} -ne 0 ] && [ ${dq_show_full_help} -ne 0 ] \
				&& ( [ ${dq_lib_help} -eq 0 ] || [ ${dq_lib_examples} -eq 0 ] ) ; then
				dq_overwrite_total=$((dq_overwrite_prompt+dq_overwrite_he_ex))
			else
				if [ ${dq_oob_nav} -eq 1 ]; then
					dq_overwrite_total=$((dq_overwrite_prompt+\
						dq_overwrite_listing+dq_overwrite_he_ex+\
						dq_overwrite_found))
				else
					dq_overwrite_total=$((dq_overwrite_prompt+dq_overwrite_he_ex))
				fi
			fi
			
			printf "\r\033[%sA\033[J" "${dq_overwrite_total}"
		fi
		
		dq_overwrite=0
		dq_overwrite_prompt=0
		if ( [ ${dq_oob_nav} -eq 1 ] && [ ${dq_lib_help} -eq 1 ] && \
			[ ${dq_lib_examples} -eq 1 ] ) || [ ${dq_show_basic_help} -eq 0 ] \
			|| [ ${dq_show_full_help} -eq 0 ] ; then
			dq_overwrite_found=0
		fi
		if [ ${dq_show_basic_help} -ne 0 ] && [ ${dq_show_full_help} -ne 0 ] \
			&& ( [ ${dq_lib_help} -eq 0 ] || [ ${dq_lib_examples} -eq 0 ] ) ; then :
		else
			dq_overwrite_listing=0
		fi
		
		# show help
		if [ ${dq_show_basic_help} -eq 0 ] || [ ${dq_show_full_help} -eq 0 ]; then
			dq_reset			
			
			if [ ${dq_show_basic_help} -eq 0 ]; then
				dq_show_basic_help=1
				if [ -z "${SHLIBS_SETUP_DIALOG_BASIC_HELP}" ]; then
					. './var/comp/dlg/shlibs_setup_basic_help.sh'
				fi
				
				dq_tmp_print=$(printf "%b" "${SHLIBS_SETUP_DIALOG_BASIC_HELP}")
				
				#important
				if [ ${dq_ctrl_d} -eq 0 ] ; then
					echo ' '
					dq_ctrl_d=1
				fi
				
				dq_fold "${dq_tmp_print}"
				dq_overwrite_listing=$((dq_overwrite_listing+dq_last_fold_count_lines))
			else
				dq_show_full_help=1
				if [ -z "${SHLIBS_SETUP_DIALOG_FULL_HELP}" ]; then
					. './var/comp/dlg/shlibs_setup_full_help.sh'
				fi
				
				dq_tmp_print=$(printf "%b" "${SHLIBS_SETUP_DIALOG_FULL_HELP}")
				dq_fold "${dq_tmp_print}"
				dq_overwrite_listing=$((dq_overwrite_listing+dq_last_fold_count_lines))
			fi
		fi
		
		
		if [ ${dq_search_on} -eq 0 ]; then
			dq_search_on=1	
			
			# escape \
			dq_keywords_esc=$(echo "${dq_keywords}" | sed 's/[\]/\\/g')
			
			dq_tmp_print=$(printf "\tSearch started: %s\n" "${dq_keywords_esc}")
			dq_fold "${dq_tmp_print}"
			dq_overwrite_search_start_lines="${dq_last_fold_count_lines}"
			
			# simulate the search if duplicate dq_ui
			if [ ${dq_ui_duplicate} -eq 1 ]; then
				dq_search_keywords
			fi
			
			if [ ${dq_overwrite_search_start_lines} -ne 0 ]; then
				printf "\r\033[%sA\033[J" "${dq_overwrite_search_start_lines}"
				dq_overwrite_search_start_lines=0
			fi
			
			if [ ${dq_search_result_count} -gt 0 ]; then
				dq_max_page=$((dq_search_result_count/SHLIBS_MATCH_PAGE_SIZE))
				dq_rc=$((dq_max_page*SHLIBS_MATCH_PAGE_SIZE))
				if [ ${dq_rc} -lt ${dq_search_result_count} ]; then
					dq_max_page=$((dq_max_page+1))
				fi
				dq_navigate=0
			else
				dq_tmp_print=$(printf "\tFound 0 / %s lib(s).\n\t[%s]\n" \
					"${sk_search_count}" "change keywords, request lib: ${SHLIBS_REQUESTS}")
				dq_fold "${dq_tmp_print}"
				dq_overwrite_found=${dq_last_fold_count_lines}
				dq_overwrite_listing=0
			fi
		fi
				
		if [ ${dq_navigate} -eq 0 ] ; then
			dq_navigate=1
				
			if [ ${dq_oob_nav} -eq 1 ]; then
				dq_page_start_index=$(((SHLIBS_MATCH_PAGE_SIZE*(dq_page-1))+1))
				dq_page_end_index=$((SHLIBS_MATCH_PAGE_SIZE*dq_page))
				if [ ${dq_page_end_index} -gt ${dq_search_result_count} ]; then
					dq_page_end_index=${dq_search_result_count}
				fi
							
				if dq_tmp_print=$(ss_retrieve \
					"${dq_page_start_index},${dq_page_end_index}" \
					'search_results') ; then
					dq_fold "${dq_tmp_print}"
					dq_page_list_diff_count_lines=$((dq_last_fold_count_lines-\
						dq_page_end_index+dq_page_start_index-1))
				else
					s_err 'Session info unavailable.'
					exit 1
				fi
			fi
			
			if [ ${dq_oob_nav} -eq 1 ]; then
				dq_tmp_print=$(printf "\tFound %s / %s lib(s).\n" \
					"${dq_search_result_count}" "${sk_search_count}")
				dq_fold "${dq_tmp_print}"
				dq_overwrite_found=${dq_last_fold_count_lines}
			else
				dq_oob_nav=1
			fi		
			
			dq_overwrite_listing=$((dq_overwrite_listing+dq_page_end_index-\
				dq_page_start_index+dq_page_list_diff_count_lines+1))	
		fi		

		# show options
		dq_options=''
		if [ "${SHLIBS_SHOW_OPTIONS}" = '0' ]; then
			if [ ${dq_search_result_count} -gt 0 ]; then
				dq_count_wording="\n\t[f] nav Fwd, [b] nav Back, [h+#] lib Help, \
[x+#] lib eXamples"
				if [ "${1}" != '0' ]; then
					dq_skip_wording='\n\t[s] Skip instance, [l] skip Line'
					dq_block_wording='\n\t[p+#] get lib path'
				fi
			else
				dq_count_wording=''
				dq_skip_wording=''
				dq_block_wording=''
			fi
			
			dq_options="\t[c] clear keywords, [C] Clear & ${dq_reset_summary_wording}, [h] Help, [x] Examples\
${dq_skip_wording}\
${dq_count_wording}${dq_block_wording}\n"			
		fi

		if [ ${dq_search_result_count} -gt 0 ]; then
			if [ ${dq_lib_help} -eq 0 ]; then
				if dq_heex_lib_code=$(ss_retrieve "${dq_ui}" \
					'search_results_target_lib_code') ; then :
				else
					s_err 'Session info unavailable.'
					exit 1
				fi
				
				dq_tmp_print="--- Help: ${dq_heex_lib_code}"
				dq_fold "${dq_tmp_print}"
				dq_overwrite_he_ex=${dq_last_fold_count_lines}
				if [ -r "${shlibs_session_dir}/dq_libhelp" ]; then
					dq_tmp_print=$(cat "${shlibs_session_dir}/dq_libhelp")
					dq_fold "${dq_tmp_print}"
					dq_overwrite_he_ex=$((dq_overwrite_he_ex+dq_last_fold_count_lines))
				else
					dq_fold 'No help available!'
					dq_overwrite_he_ex=$((dq_overwrite_he_ex+dq_last_fold_count_lines))
				fi
				dq_cut_print '-----------------------------------------------------------------------'
				dq_overwrite_he_ex=$((dq_overwrite_he_ex+1))
			elif [ ${dq_lib_examples} -eq 0 ]; then
				if dq_heex_lib_code=$(ss_retrieve "${dq_ui}" \
					'search_results_target_lib_code') ; then :
				else
					s_err 'Session info unavailable.'
					exit 1
				fi
				
				dq_tmp_print="--- Examples: ${dq_heex_lib_code}"
				dq_fold "${dq_tmp_print}"
				dq_overwrite_he_ex=${dq_last_fold_count_lines}
				if [ -r "${shlibs_session_dir}/dq_libexamples" ]; then					
					dq_tmp_print=$(cat "${shlibs_session_dir}/dq_libexamples")
					dq_fold "${dq_tmp_print}"
					dq_overwrite_he_ex=$((dq_overwrite_he_ex+dq_last_fold_count_lines))
				else
					dq_fold 'No examples available!'
					dq_overwrite_he_ex=$((dq_overwrite_he_ex+dq_last_fold_count_lines))
				fi
				dq_cut_print '-----------------------------------------------------------------------'
				dq_overwrite_he_ex=$((dq_overwrite_he_ex+1))
			else
				dq_overwrite_he_ex=0
			fi
		else
			dq_overwrite_he_ex=0
		fi
		dq_lib_help=1
		dq_lib_examples=1

		dq_tmp_print=$(printf "%b\tKeywords { %s }\n" "${dq_options}" "${dq_keywords_esc}")
		dq_fold "${dq_tmp_print}"
		dq_overwrite_prompt=$((dq_last_fold_count_lines+1))
		printf "%b" "\tInput: "
		
		
		if read -r dq_ui ; then
			dq_ctrl_d=1
		else
			dq_ctrl_d=0
		fi
		
		case ${dq_ui} in
			k+*)
				dq_ui=${dq_ui#k+}
				# unfocused search
				dq_k_search=0
				dq_process_keywords
				;;
			b|B)
				# back navigation
				if [ ${dq_search_result_count} -gt 0 ]; then
					if [ ${dq_max_page} -gt 1 ] && [ ${dq_page} -gt 1 ]; then
						dq_page=$((dq_page-1))
					else
						dq_oob_nav=0
					fi
					dq_navigate=0
				else
					dq_process_keywords
				fi
				;;
			f|F)
				# fwd navigation
				if [ ${dq_search_result_count} -gt 0 ]; then
					if [  ${dq_page} -lt ${dq_max_page} ]; then
						dq_page=$((dq_page+1))
					else
						dq_oob_nav=0
					fi
					dq_navigate=0
				else
					dq_process_keywords
				fi
				;;
			c)
				# clear keywords
				dq_reset
				;;
			C)
				# clear and reset
				tput clear
				ssa_run_adjustment
				printf "${dq_intro}\n"
				dq_reset 0
				#return ${?}
				;;
			s|S)
				if [ "${1}" = "0" ]; then
					dq_process_keywords
				else
					# skip instance
					return 0
				fi
				;;
			l|L)
				if [ "${1}" = "0" ]; then
					dq_process_keywords
				else
					# skip rest of line
					return 1
				fi
				;;
			h|H)
				# full help
				dq_show_full_help=0
				;;
			q)
				sdu_cleanup_tmp_onexit
				;;
			*)				
				case ${dq_ui} in
					p+*)
						dq_ui=${dq_ui#p+}
						if [ "${1}" = '0' ]; then
							dq_show_basic_help=0
							continue
						else
							ss_psl_chosen_get_script_path='-p'
						fi
						;;
					h+*)
						dq_ui=${dq_ui#h+}
						dq_lib_help=0
						;;
					x+*)
						dq_ui=${dq_ui#x+}
						dq_lib_examples=0
						;;
				esac
				
				
				# lib selection followed by options (setup script mode only)
				# i.e. 5+-xd 32
				dq_target_lib_options=''
				if [ "${1}" != '0' ]; then
					dq_target_lib_options=" ${dq_ui#*+}"					
					if [ "${dq_target_lib_options}" != " ${dq_ui}" ] ; then
						dq_ui=${dq_ui%%+*}
						if [ -n "${ss_psl_chosen_get_script_path}" ] ; then
							dq_target_lib_options=''
						fi
						# important
						dq_target_lib_options=$(echo "${dq_target_lib_options}" \
							| sed 's/"/\\\"/g')
					else
						dq_target_lib_options=''
					fi
				fi
				
				
				# lib selection by number case
				if test ${dq_ui} -gt 0 2>/dev/null ; then
					if [ ${dq_ui} -gt ${dq_search_result_count} ]; then
						dq_show_basic_help=0
					else
						if {
							dq_target_libcode=$(ss_retrieve "${dq_ui}" \
								'search_results_target_lib_code') ;
							dq_libcode=$(ss_retrieve "${dq_ui}" \
								'search_results_lib_code') ;
							dq_mvers=$(ss_retrieve "${dq_ui}" \
								'search_results_version') ;
						} ; then :
						else
							s_err 'Session info unavailable.'
							exit 1
						fi
						
						# handle h+# and x+# requests
						if [ ${dq_lib_help} -eq 0 ] || \
							[ ${dq_lib_examples} -eq 0 ]; then
							
							# clean up previous results
							if [ ${dq_lib_help} -eq 0 ]; then
								if rm -f "${shlibs_session_dir}/dq_libhelp" \
										2>/dev/null ; then :
								else
									s_err 'Dev Query: Could not delete dq_libhelp!'
									exit 1
								fi
							else
								if rm -f "${shlibs_session_dir}/dq_libexamples" \
										2>/dev/null ; then :
								else
									s_err 'Dev Query: Could not delete dq_libexamples!'
									exit 1
								fi
							fi
							
							(
								if [ ${dq_mvers} -gt 0 ]; then
									set -- -z -v ${dq_mvers} \
										"${dq_target_libcode}"
								else
									set -- -z "${dq_target_libcode}"
								fi
								. './var/comp/shlibs_run_lib.sh'
							) >/dev/null 2>&1 #important
															
							continue
						fi
						
						dq_quoted_target_libcode=$(./shlibs str001 \
							"${dq_target_libcode}" ' ')
						if [ "${dq_quoted_target_libcode}" = '0' ] ; then
							dq_quoted_target_libcode="'${dq_target_libcode}'"
						else
							dq_quoted_target_libcode="${dq_target_libcode}"
						fi
						
						
						
						
						dq_v_wording=''
						if [ ${dq_mvers} -gt 0 ]; then
							# if just a version omit -v #
							if {
								if [ ${dq_search_result_count} -gt ${SHLIBS_MAX_RESULTS_MEM} ]; then
									dq_sel_count_versions=$( ${SHLIBS_GREP} \
										-c -iE "^${dq_target_libcode}$" \
										"${shlibs_session_dir}/search_results_target_lib_code" ) \
										>/dev/null 2>&1 ;
								else
									dq_sel_count_versions=$( \
										echo "${search_results_target_lib_code}" \
										| ${SHLIBS_GREP} \
										-c -iE "^${dq_target_libcode}$" ) \
										>/dev/null 2>&1 ;
								fi 
							} ; then :
							else
								dq_sel_count_versions=1
							fi
							if [ "${dq_sel_count_versions}" = '1' ] ; then :
							else
								dq_v_wording="-v ${dq_mvers} "
							fi
						fi
							
						
						dq_p_wording=''
						if [ -n "${ss_psl_chosen_get_script_path}" ]; then
							dq_p_wording="${ss_psl_chosen_get_script_path} "
						fi	
						
						
						# print selection info
						if [ "${1}" = '0' ]; then
							dq_eqp="\n\tSelected library %s: shlibs %s%s%s
\tFor help use:\n\t\tshlibs %s-h %s
\tFor examples use:\n\t\tshlibs %s-x %s\n"
							
							dq_tmp_print=$(printf "${dq_eqp}" "${dq_ui}" \
								"${dq_p_wording}" "${dq_v_wording}" "${dq_quoted_target_libcode}" \
								"${dq_v_wording}" "${dq_quoted_target_libcode}" \
								"${dq_v_wording}" "${dq_quoted_target_libcode}")
							dq_fold "${dq_tmp_print}"
						fi
						
						
						# copy dependency if setup script
						if [ "${1}" != '0' ]; then
							if {
								dq_dep_src=$(ss_retrieve "${dq_ui}" \
									'search_results_deps') ;
								dq_dep_hdr=$(ss_retrieve "${dq_ui}" \
									'search_results_headers') ;
								
								dq_dep_section=$(ss_retrieve "${dq_ui}" \
									'search_results_section') ;
								
								dq_dep_hdr_dest=$(ss_retrieve "${dq_ui}" \
									'search_results_ext_headers') ;
								
								dq_dep_dest=$(ss_retrieve "${dq_ui}" \
									'search_results_ext_srcs') ;
							} ; then :
							else
								s_err 'Session info unavailable.'
								exit 1
							fi
						
							
							
							dq_dep_hdr_dest="${ss_opts_destination}/libs/${dq_dep_section}${dq_dep_hdr_dest}"
							if [ "${dq_dep_section}" = 'official' ] ; then
								dq_dep_dest="${ss_opts_destination}/libs/${dq_dep_section}${dq_dep_dest}"
							else
								dq_dep_dest="${ss_opts_destination}/libs/${dq_dep_dest}/${dq_libcode}"
							fi
								
							ss_opts_destination=${ss_opts_destination:?}
							opts_created_paths=${opts_created_paths:?}
							
							
							
							
							# 1. copy header
							# lib code can be a path
							if [ -n "${dq_dep_hdr}" ]; then
								if [ -d "${dq_dep_hdr_dest}" ]; then :
								else
									if mkdir -p "${dq_dep_hdr_dest}" ; then : :
									else
										s_err "Critical error: \
cannot create destination ${dq_dep_hdr_dest}"
										exit 1
									fi
								fi
	
								if cp -f "${dq_dep_hdr}" \
									"${dq_dep_hdr_dest}" ; then :
								else
									s_err "Critical error: \
cannot copy '${dq_dep_hdr}' to '${dq_dep_hdr_dest}'."
									exit 1
								fi
								
								
								# register copy op
								if printf "%s\n" "${dq_dep_hdr_dest}" \
									>> "${opts_created_paths}" ; then :
								else
									s_err "Cannot register copy op: ${dq_dep_hdr_dest}"
									exit 1
								fi
							fi
							
							
							
							
							# 2. copy lib (strip help and examples; 
							# must be the last functions in file)
							# lib code can be a path
							dq_dep_dest_dir=$(dirname -- "${dq_dep_dest}")
							if [ -d "${dq_dep_dest_dir}" ]; then :
							else
								if mkdir -p "${dq_dep_dest_dir}" ; then :
								else
									s_err "Critical error: \
cannot create destination ${dq_dep_dest_dir}"
									exit 1
								fi
							fi
							
							
							if ${SHLIBS_AWK} '{ 
								match($0,/'"${dq_libcode}"'_help|'"${dq_libcode}"'_examples/); 
								if (RSTART==0) { print $0; } else { print RS; exit; } }' \
								< "${dq_dep_src}" \
								> "${dq_dep_dest}" ; then :
							else
								s_err "Critical error: \
cannot copy '${dq_dep_src}' to '${dq_dep_dest}'."
								exit 1
							fi
							
							# register copy op
							if printf "%s\n" "${dq_dep_dest}" \
								>> "${opts_created_paths}" ; then :
							else
								s_err "Cannot register copy op: ${dq_dep_dest}"
								exit 1
							fi							
						fi						
						
						dq_on=1
					fi
				else
					dq_process_keywords
				fi
				;;
		esac		
		
	done	
	
	if [ "${1}" != '0' ]; then
		ss_psl_chosen_lib="${dq_quoted_target_libcode}${dq_target_lib_options}"
	fi
}
