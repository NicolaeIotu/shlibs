#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

. ./var/comp/shlibs_dev_query.sh

# identifies replaceable shlibs instances
_s_='[^a-zA-Z0-9_]?'
ss_psl_shlibs_ere="${_s_}shlibs${_s_}"

proc_shlibs_line(){	
	# get line number and line content
	ss_psl_line_no="${1%:*}"
	ss_psl_line_content="${1#${ss_psl_line_no}:}"

	# $ss_psl_line_content can have multiple instances of shlibs
	ss_psl_shlibs_count=$(echo "${ss_psl_line_content}" | \
		${SHLIBS_AWK} -v SHL="${ss_psl_shlibs_ere}" '{ print gsub(SHL, "") }')

	ss_wording_at_line="At line #${ss_psl_line_no} found ${ss_psl_shlibs_count} instance(s):"
	ss_intro="${ss_intro}${_nl}${ss_wording_at_line}"
	echo "${ss_wording_at_line}"
	
	# Prefix - Match - Sufix
	if [ "${ss_psl_shlibs_count}" -ge 1 ]; then
		# working line content
		ss_psl_hlt="${SHLIBS_MATCH_HIGHLIGHT}"
		ss_psl_hlt="${ss_psl_hlt}${ss_psl_hlt}${ss_psl_hlt}"
		ss_psl_preprefix=''
		ss_psl_preprefix_print=''
		ss_psl_wlc="${ss_psl_line_content}"
		ss_psl_instance_no=1
		ss_psl_chosen_match=''
		ss_psl_chosen_match_print=''
		while [ "${ss_psl_instance_no}" -le "${ss_psl_shlibs_count}" ]
		do
			# reset chosen_lib and the option to get lib path
			ss_psl_chosen_lib=''
			ss_psl_chosen_get_script_path=''
			
			# prefix
			ss_psl_prefix=$(echo "${ss_psl_wlc}" | ${SHLIBS_AWK} -F "${ss_psl_shlibs_ere}" \
				'{ print $1 }' -)

			# match
			ss_psl_match=$(echo "${ss_psl_wlc}" | \
				${SHLIBS_AWK} '{ match($0, /'"${ss_psl_shlibs_ere}"'/); print substr($0, 
				RSTART, RLENGTH) }' -)
			
			# sufix
			ss_psl_sufix=$(echo "${ss_psl_wlc}" | \
				${SHLIBS_AWK} '{ match($0, /'"${ss_psl_shlibs_ere}"'/); print substr($0, 
				RSTART+RLENGTH) }' -)
			
			# precise match
			ss_psl_precise_match=$(echo "${ss_psl_match}" | \
				${SHLIBS_AWK} '{ match($0, /shlibs/); 
				print substr($0, 1, RSTART-1)"'"${ss_psl_hlt}\033[1;31m"'"substr($0, RSTART, 
				RLENGTH)"'"\033[m${ss_psl_hlt}"'"substr($0, RSTART+RLENGTH) }' -)

			ss_psl_pre_match="${ss_psl_match%%shlibs*}"
			ss_psl_post_match="${ss_psl_match##*shlibs}"
			
			ss_wording_line="- line ${ss_psl_line_no}/instance ${ss_psl_instance_no}: \
${ss_psl_preprefix}${ss_psl_prefix}${ss_psl_precise_match}${ss_psl_sufix}"
			ss_intro="${ss_intro}${_nl}${ss_wording_line}"
			printf -- "${ss_wording_line}\n"
			
			if dev_query 1 ; then	
				if [ -n "${ss_psl_chosen_lib}" ]; then
					ss_psl_chosen_match=$(echo "${ss_psl_match}" | \
						${SHLIBS_AWK} '{ match($0, /shlibs/); print substr($0, 1, 
						RSTART-1)substr($0, RSTART, RLENGTH)" '\
"${dq_p_wording}${dq_v_wording}${ss_psl_chosen_lib}"'"substr($0, RSTART+RLENGTH) }' -)
				else
					printf "\tSkipping instance %s \
(line %s).\n" "${ss_psl_instance_no}" "${ss_psl_line_no}"
					ss_psl_chosen_match=${ss_psl_match}
				fi
			else
				# return 1 = cancel setup of this line
				printf "\tSkipping the rest of instances on line %s.\n" \
					"${ss_psl_line_no}"
				ss_psl_chosen_match=${ss_psl_match}
			fi

			ss_psl_wlc="${ss_psl_sufix}"	
			ss_psl_chosen_match_print="$( echo "${ss_psl_chosen_match%%${ss_psl_post_match}}" | \
				sed 's/shlibs/\\033\[1;31mshlibs/' )"
			ss_psl_chosen_match_print="${ss_psl_chosen_match_print}"'\033[m'"${ss_psl_post_match}"

			ss_psl_preprefix="${ss_psl_preprefix}${ss_psl_prefix}${ss_psl_chosen_match}"
			ss_psl_preprefix_print="${ss_psl_preprefix_print}${ss_psl_prefix}${ss_psl_chosen_match_print}"

			ss_psl_instance_no=$((ss_psl_instance_no+1))
		done
	else
		# no instances of shlibs found
		ss_msln=${ss_psl_line_no}
		return 1
	fi
	
	ss_wording_becomes="Line #${ss_psl_line_no} becomes:
${ss_psl_preprefix_print}${ss_psl_sufix}"
	ss_intro="${ss_intro}\n${ss_wording_becomes}"
	printf "${ss_wording_becomes}\n"
	
	ss_msln=${ss_psl_line_no}
	ss_msl="${ss_psl_preprefix}${ss_psl_sufix}"
}


proc_script() {
	ss_wording_processing="\nProcessing '${1}'\n"
	printf "${ss_wording_processing}"
	ss_intro="${ss_intro}\n${ss_wording_processing}"
	
	opts_created_paths=${opts_created_paths:?}
	
	# readable is a must
	if [ -r "${1}" ]; then
		# get script name with no extension
		ss_script_fullname="${1##*/}"
		ss_script_name="${ss_script_fullname%%\.*}"		
		
		# set the destination of generated script
		if [ -z "${opts_dev_destination}" ]; then
			ss_opts_destination="$(dirname -- "${1}")/${ss_script_name}_shlibs"
			ss_do_clean=0
		else
			ss_opts_destination="${opts_dev_destination}"
			if [ ${opts_force_cleanup} -eq 0 ]; then
				ss_do_clean=0
			else
				ss_do_clean=1
			fi
		fi
		#protect shlibs structure
		ss_dest_check=0
		ss_destination_index=0
		while [ ${ss_dest_check} -eq 0 ]
		do
			if expr "${ss_opts_destination}" : "${shlibs_dirpath}.*" >/dev/null ; then
				echo "Output to shlibs folders is forbidden!"
				
				case ${ss_destination_index} in
					0)
						echo "Saving to current working directory."
						ss_destination_index=1
						ss_opts_destination="${shlibs_cwd}/${ss_script_name}_shlibs"
					;;
					1)
						echo "Saving to your home directory."
						ss_destination_index=2
						ss_opts_destination=~/"${ss_script_name}_shlibs"
					;;
					*)
						s_err 'Cannot use home or current working directory.
Try using -d to specify destination, or change current working directory.'
						exit 1
					;;
				esac
			else
				ss_dest_check=1
			fi
		done
		
		
		# cleanup destination
		if [ ${ss_do_clean} -eq 0 ]; then
			if [ -d "${ss_opts_destination}" ]; then
				if $(./shlibs dir001 "${ss_opts_destination}") ; then :
				else
					s_err "Could not clean the destination: ${ss_opts_destination}"
					exit 1
				fi
			fi
		fi
		
		
		# the path of the script to be handled
		ss_target_script_path="${ss_opts_destination}/scripts/${ss_script_fullname}"
		
		# a temporary working file
		ss_tmp_script_path="${shlibs_session_dir}/tmp_${ss_script_fullname}"
		
		# check/create destination directory
		if [ -d "${ss_opts_destination}/scripts" ]; then :
		else
			if mkdir -p "${ss_opts_destination}/scripts" ; then :
			else
				s_err "Cannot create destination: ${ss_opts_destination}/scripts"
				return 1
			fi
		fi
		
		
		# register copy op
		if printf "%s/%s\n" "${ss_opts_destination}/scripts" \
			"${ss_script_fullname}" >> "${opts_created_paths}" ; then :
		else
			exit 1
		fi
		
		
		# copy script to destination
		if cp -f "${1}" "${ss_target_script_path}" ; then :
		else
			s_err "Cannot copy ${1} to ${ss_opts_destination}/scripts"
			return 1
		fi		
		
		
		# check (again) script is readable
		if [ -r "${ss_target_script_path}" ]; then
			if { scan_shlibs_output=$(${SHLIBS_AWK} -v SHL="${ss_psl_shlibs_ere}" \
				'{ match($0, "#"); 
					if (RSTART != 1) { match($0, SHL); 
						if (RSTART > 0) { print NR":"$0;}}}' \
				< "${ss_target_script_path}") ; } 2>/dev/null ; then :
			else
				s_err "Error(s) occured while scanning ${1}"
				return 1
			fi
			
				
			
			if [ -n "${scan_shlibs_output}" ]; then
				ss_wording_editing="Editing: ${ss_target_script_path}
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
				ss_intro="${ss_intro}${ss_wording_editing}"
				echo "${ss_wording_editing}"
			fi
				
			ss_awk_repl=''
			ss_awk_ln=''
			IFS=${_nl}
			for ss_scriptline in ${scan_shlibs_output}
			do
				ss_msln=0
				ss_msl=''
				proc_shlibs_line "${ss_scriptline}"			
				if [ -z "${ss_msln}" ]; then
					# abnormal case when no instances of shlibs found
					s_err "No 'shlibs' found on line #${ss_msln} !"
					exit
				else
					if [ -n "${ss_awk_ln}" ]; then
						ss_awk_ln="${ss_awk_ln},${ss_msln}"
					else
						ss_awk_ln="${ss_msln}"
					fi
					
					if [ -n "${ss_awk_repl}" ]; then
						ss_awk_repl="${ss_awk_repl}${IRS}${ss_msl}"
					else
						ss_awk_repl="${ss_msl}"
					fi
				fi		
			done
			IFS=${o_ifs}
				
			# replace instances of shlibs as chosen by dev
			if ${SHLIBS_AWK} -v PS_MSLN="${ss_awk_ln}" \
				-v PS_REPL="${ss_awk_repl}" -v rs="${IRS}" \
				'BEGIN {
					awk_c_l=split(PS_MSLN, ss_msln, ",");
					awk_c_r=split(PS_REPL, ss_repl, rs);
					if (awk_c_l != awk_c_r) {
						exit 1
					}
					ss_index=1
				}
				
				{ 
					if (NR == ss_msln[ss_index]) {
						print ss_repl[ss_index]
						ss_index=ss_index+1
					} else {
						print $0
					}
				}' \
				< "${ss_target_script_path}" \
				> "${ss_tmp_script_path}" ; then :
			else
				s_err "Couldn't process correctly ${ss_target_script_path}."
				return 1
			fi					
			
			printf "\nGenerating structures. Please wait ...\n"
			
			
			# START OUTPUT STANDALONE FILES
			
			# 1. dev script
			if mkdir -p "${ss_opts_destination}/scripts" ; then :
			else
				s_err 'Could not create scripts destination!'
				exit 1
			fi
			if cp -f "${ss_tmp_script_path}" "${ss_target_script_path}" ; then
				if rm -f "${ss_tmp_script_path}" 2>/dev/null ; then :
				else
					s_err 'Could not clean scripts destination!'
					exit 1
				fi
			else
				s_err "Cannot copy script to '${ss_target_script_path}'."
				return 1
			fi
			
			
			# 2. shlibs (minimal version)
			# register copy op
			if printf "%s/shlibs\n" "${ss_opts_destination}" >> \
				"${opts_created_paths}" ; then :
			else
				exit 1
			fi
							
			
			# copy main component responsible for running dependencies
			if cp -f './var/comp/shlibs_run_lib.sh' \
				"${ss_opts_destination}/shlibs" ; then
				# and add x perm
				if chmod u+x "${ss_opts_destination}/shlibs" 2>/dev/null; then
					if [ -x "${ss_opts_destination}/shlibs" ]; then :
					else
						s_err "Couldn't change permission to +x \
${ss_opts_destination}/shlibs. Try again using a different destination (-d)."
						return 1
					fi
				else
					s_err "Couldn't change permission to +x \
${ss_opts_destination}/shlibs. Try again using a different destination (-d)."
					return 1
				fi
			else
				s_err 'Cannot copy minimal shlibs.'
				return 1
			fi
	
			
			# 3. log folder
			# create the log path
			if mkdir -p "${ss_opts_destination}/var/log" ; then :
			else
				s_err 'Could not create log destination!'
				exit 1
			fi
			
			
			# 4. copy portable components and register copy ops
			ss_dest_ptbl="${ss_opts_destination}/var/comp/ptbl"
			if mkdir -p "${ss_dest_ptbl}" ; then :
			else
				s_err 'Could not create components destination!'
				exit 1
			fi
			if {
				cp -f "${shlibs_dirpath}/var/comp/ptbl/shlibs_redir.sh" \
					"${ss_dest_ptbl}/shlibs_redir.sh" ;
				cp -f "${shlibs_dirpath}/var/comp/ptbl/shlibs_err.sh" \
					"${ss_dest_ptbl}/shlibs_err.sh" ;
				} ; then :
			else
				s_err 'Could not copy shlibs_redir.sh.'
				return 1
			fi

			if find "${ss_dest_ptbl}" -type f \
					-exec echo {} >> "${opts_created_paths}" ";" ; then :
			else
				s_err 'Errors occured while copying components.'
				return 1
			fi
			

			# 5. copy cap components and register copy ops
			ss_dest_cap="${ss_opts_destination}/var/comp/cap"

			if cp -rf "${shlibs_dirpath}/var/comp/cap" \
				"${ss_dest_cap}" ; then :
			else
				s_err 'Could not copy cap components.'
				return 1
			fi
			if find "${ss_dest_cap}" -type f \
					-exec echo {} >> "${opts_created_paths}" ";" ; then :
			else
				s_err 'Errors occured while copying components.'
				return 1
			fi
			
			
			# 6. launcher of dev's script
			# modify line designated to hold $dev_script_basename
			# and move launcher/change name
			if sed -e "s/\#\#sed d_s_b\#\#/d_s_b=\"${ss_script_fullname}\"/" \
				-e "s/\#\#sed S_F_S\#\#/SHLIBS_FORCE_SHELL='${SHLIBS_FORCE_SHELL}'/" \
				< "${shlibs_dirpath}/var/comp/ptbl/shlibs_sl.sh" \
				> "${ss_opts_destination}/${ss_script_fullname}" ; then
				# register op
				if printf "%s/%s\n" "${ss_opts_destination}" "${ss_script_fullname}" \
					>> "${opts_created_paths}" ; then :
				else
					exit 1
				fi	
			else
				s_err 'Could not complete the setup.
sed could not process final replacements.'
				return 1
			fi
			
			# END OUTPUT STANDALONE FILES
			
			# info on completion
			printf "Processed successfully '%s'\n\n" "${1}"
			
			# include multiscript+dev dest case
			if [ -z "${opts_dev_destination}" ] || \
				{ [ -n "${opts_dev_destination}" ] && \
				 [ "${2}" = '0' ] ; } ; then
				printf "Transfer the folder '%s' and contents to any POSIX \
compliant system. Visit https://shlibs.org, https://shlibs.net and get info on how to ensure \
cross OS compatibility of your scripts.\n" "${ss_opts_destination}"
				ss_opts_destination_basename="${ss_opts_destination##*/}"
				printf "Run script with: cd '/path/to/%s' ; . './%s' ( or /bin/sh './%s' )\n" \
				"${ss_opts_destination_basename}" \
				"${ss_script_fullname}" "${ss_script_fullname}"
			fi
		else
			s_err "Failed setup of generated script: \
${ss_target_script_path}
Make sure the file exists and read permission is granted."
			return 1
		fi
	else
		s_err "Failed setup of script: ${1}
Make sure the file exists and read permission is granted."
		return 1
	fi
}
