#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com


opts_help=1 opts_examples=1 opts_autorun_script=1
opts_force_cleanup=1 opts_block_default_function=1 opts_last_script=0
opts_setup_script='' opts_dev_destination='' opts_error_content=''
opts_scripts_count=0 opts_scripts_processed=0 opts_miss_file_warn=0

# check options and prioritize
while [ "${#}" != '0' ];
do
	case ${1} in
		-reset)
			if cp -f './var/comp/default/shlibs_settings_default.sh' \
				'./var/shlibs_settings.sh' ; then
				echo 'shlibs reset completed successfully!'
				exit
			else
				s_err 'Error(s) occured during reset. Please try again.'
				exit 1
			fi
			;;
		-h)
			opts_help=0
			if [ ${#} -gt 2 ]; then
				shift
			else
				break
			fi
			;;
		-x)
			opts_examples=0
			if [ ${#} -gt 2 ]; then
				shift
			else
				break
			fi
			;;
		-s)
			if [ ${#} -gt 1 ]; then
				# important: cd to launch location
				cd "${shlibs_cwd}" || err_fs
				
				sn=$(dirname -- "${2}")
				sn=$(cd "${sn}" ; pwd -L )/"${2##*/}" || err_fs
				sn=$(echo "${sn}" | sed 's/[\/]\{2,\}/\//g')			
					
				if [ -r "${sn}" ]; then :
				else
					opts_error_content="Unreachable script (${sn})"
					break
				fi
				
				# only scripts allowed 
				# (file utility is required and missing on some systems)
				if [ ${SHLIBS_HAS_FILE} -eq 0 ]; then
					opts_tf=$(file "${sn}" | ${SHLIBS_AWK} \
						'{ match($0,/(text|script)/) ; print RSTART; }')
					if [ "${opts_tf}" = '0' ]; then
						opts_error_content="Only scripts allowed! (${sn})"
						break
					fi
				else
					if [ ${opts_miss_file_warn} -eq 0 ]; then
						opts_miss_file_warn=1
						echo '(shlibs is for scripts only)'
					fi
				fi
				
				opts_scripts_count=$((opts_scripts_count+1))
				opts_setup_script="${opts_setup_script}${sn}${IRS}"
				shift 2
				
				# restore wd
				cd "${shlibs_dirpath}" || err_fs
			else
				opts_error_content='No script specified!'
				break
			fi
			;;
		-d)
			if [ -z "${opts_dev_destination}" ]; then
				if [ ${#} -gt 1 ]; then
					# important: cd to launch location
					cd "${shlibs_cwd}" || err_fs
					
					if [ -d "${2}" ]; then :
					else
						if mkdir -p "${2}" ; then :
						else
							opts_error_content="Cannot create destination: \
${2}"
							break
						fi
					fi
					
					opts_dev_destination=$(cd "${2%/}" ; pwd -L ) || err_fs
					
					shift 2
					
					# restore wd
					cd "${shlibs_dirpath}" || err_fs
				else
					opts_error_content='No destination specified!'
					break
				fi
			else
				opts_error_content='Only one destination allowed.'
				break
			fi
			;;
		-y)
			# runs a realistic test on script after it has been processed
			opts_autorun_script=0
			shift
			;;
		-clean)
			# valid only when -d is specified
			opts_force_cleanup=0
			shift
			break
			;;
		*)
			opts_error_content="Invalid option ${1}"
			break
			;;
	esac
done

# 1st error handler
if [ -n "${opts_error_content}" ]; then
	s_err "${opts_error_content}"
	exit 1
fi


# handle here help and lib usage requests
if [ ${opts_help} -eq 0 ] || [ ${opts_examples} -eq 0 ]; then
	# check for malformed options specified after -h
	
	if echo "${2}" | ${SHLIBS_GREP} '^-[.]$' >/dev/null 2>&1 ; then
		s_err "Invalid extra option ${2}
Use 'shlibs ${1}', or 'shlibs ${1} libcode'"
		exit 1
	else
		if [ ${#} -eq 1 ] || [ -z "${2}" ]; then
			# show shlibs main help
			if [ ${opts_help} -eq 0 ]; then
				. './var/comp/dlg/shlibs_help.sh'
				printf "%b" "${SHLIBS_HELP}"
			else
				. './var/comp/dlg/shlibs_examples.sh'
				printf "%b" "${SHLIBS_EXAMPLES}"
			fi
		else
			# show library help
			shift
			
			opts_block_default_function=0
			export opts_block_default_function
			
			. './var/comp/shlibs_run_lib.sh'
		fi	
		
		exit ${?}
	fi
fi


# we must have a script to setup at this point
if [ -z "${opts_setup_script}" ]; then
	opts_error_content='No script to setup!'
fi


# we must have a valid destination (if any)
if [ -n "${opts_dev_destination}" ]; then
	if [ -d "${opts_dev_destination}" ]; then
		if [ ${opts_force_cleanup} -eq 0 ]; then
			if $( ./shlibs dir001 "${opts_dev_destination}" ) ; then :
			else
				s_err 'Could not force clean the destination!'
				exit 1
			fi
		fi
	else
		if mkdir -p "${opts_dev_destination}" 2>/dev/null; then :
		else
			opts_error_content="Cannot create destination: \
${opts_dev_destination}"
		fi
	fi
fi


# 2nd error handler
if [ -n "${opts_error_content}" ]; then
	s_err "${opts_error_content}"
	exit 1
fi


# start processing scripts
if [ -t 0 ]; then
	if [ -p "/dev/fd/1" ]; then
		# piped output case
		s_err 'No piping allowed in setup script mode!'
		exit 1
	fi
else
	s_err 'Interactive mode available only in terminal.'
	exit 1
fi
. ./var/comp/shlibs_setup_script.sh
opts_created_paths="${shlibs_session_dir}"/created_paths

# setup script main info
echo "shlibs v ${SHLIBS_VERSION}/libs ${dq_libs_version}"

IFS=${IRS}
for opts_nrscript in ${opts_setup_script}
do
	opts_scripts_processed=$((opts_scripts_processed+1))

	# delete log of ops before processing a new file
	if rm -f "${opts_created_paths}" 2>/dev/null ; then :
	else
		s_err 'Could not remove log of previous ops!'
		exit 1
	fi
	
	if [ ${opts_scripts_processed} -eq ${opts_scripts_count} ]; then
		opts_last_script=0
	else
		opts_last_script=1
	fi
	
	# proc_script returns 1 on critical errors
	if proc_script "${opts_nrscript}" "${opts_last_script}" ; then	
		# autorun script if -y is supplied
		if [ ${opts_autorun_script} -eq 0 ]; then
			if [ ${opts_scripts_count} -eq 1 ] || \
				{ [ ${opts_scripts_count} -gt 1 ] && \
				{ [ -z "${opts_dev_destination}" ] || \
				[ ${opts_scripts_count} -eq ${opts_scripts_processed} ] ; } ; }; then
				# ss_opts_destination is set at shlibs_setup_script
				# and is script dependent if a -d is not specified
				so_dest_script_name="${opts_nrscript##*/}"
				so_dest_script_path="${ss_opts_destination}/${so_dest_script_name}"
				printf "\nTesting: %s
============================================================\n" \
					"${so_dest_script_path}"
				# real case scenario simulation
				(
					PATH='/bin:/sbin:/usr/bin:/usr/sbin'
					unset SHLIBS_HOME 2>/dev/null
					unset SHLIBS_SHELL_PATH 2>/dev/null
					cd "${ss_opts_destination}"
					/bin/sh "./${so_dest_script_name}"
				)
				printf "\
============================================================
End test: %s\n" "${so_dest_script_path}"
			fi
		fi
	else
		# cleanup on errors
		if { 
				if [ -r "${opts_created_paths}" ]; then
					if cat -u "${opts_created_paths}" | xargs rm -rf ; then :
					else
						s_err 'Cannot cleanup on errors!'
						exit 1
					fi					
				fi
				if [ -d "${ss_opts_destination}" ]; then
					if $( ./shlibs dir001 "${ss_opts_destination}" ) ; then :
					else
						s_err 'Cannot cleanup on errors!'
						exit 1
					fi
				fi
			} ; then :
		else
			s_err 'Could not clean up on error!'
			exit 1
		fi
	fi
done
IFS=${o_ifs}
# end processing scripts
sdu_cleanup_tmp_onexit
