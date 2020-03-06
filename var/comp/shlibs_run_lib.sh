
# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net 
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

# TAGS: PORTABLE, MORPH


if type s_err >/dev/null 2>&1 ; then :
else
	. './var/comp/ptbl/shlibs_err.sh'
fi

# important format
if ( echo ${shlibs_redir_vars:?} ) >/dev/null 2>&1 ; then :
	# development case
else
	. './var/comp/ptbl/shlibs_redir.sh'

	if [ "${shlibs_redir_vars_flag}" = '0' ]; then
		unset shlibs_redir_vars_flag
		if [ "${SHLIBS_COMPLEX_PIPE}" = '0' ]; then
			unset SHLIBS_COMPLEX_PIPE
			./shlibs "${@}" ${shlibs_redir_vars}
		else
			unset SHLIBS_COMPLEX_PIPE
			./shlibs "${@}" "${shlibs_redir_vars}"
		fi
		exit ${?}
	fi
fi


rl_get_script_path=1
# handle options
while echo "${1}" | ${SHLIBS_GREP} '^-.$' >/dev/null 2>&1 
do
	case ${1} in
		-z)
			opts_block_default_function=0
			export opts_block_default_function
			shift
			;;
		-v)
			if [ ${#} -gt 2 ]; then
				opts_lib_version=${2}
				test ${opts_lib_version} -gt 0 2>/dev/null || {
					s_err 'Invalid version number ( > 0 ).'
					exit 1
				}
				export opts_lib_version
				shift 2
			elif [ ${#} -gt 1 ]; then
				s_err 'No lib specified!'
				exit 1
			else
				echo "${SHLIBS_VERSION}"
				exit
			fi
			;;
		-p)
			rl_get_script_path=0
			shift
			;;
		*)
			s_err "Incompatible option ${1}."
			exit 1
			;;
	esac	
done


# filter libcode
rl_dev_code="${1}"
# important: pos params shifted 
shift

# force a maximum number of params
if [ ${#} -gt 20 ]; then
	s_err "Maximum number of params (20) exceeded."
	exit 1
fi


rl_count_libs_found=0 rl_force_section=1 rl_section=''
if [ -z "${rl_has_setenv}" ]; then
	if type setenv >/dev/null 2>&1 ; then
		rl_has_setenv=0
	else
		rl_has_setenv=1
	fi
fi

rl_post_find_preps() {
	# find outputs at least a line; filter here empty output

	if [ -n "${rl_lib_path}" ]; then
		rl_lib_file="${rl_lib_path##*/}"
		
		# required when calling main function of a lib
		# (keep it out of function scope)
		rl_lib_file_name=${rl_lib_file%.*}
		rl_lib_file_ext=${rl_lib_file##*.}
		
		# official shlibs contains only .sh files
		# having rl_lib_file_name of size at least 2
		if [ "${rl_section}" = 'official' ]; then
			if [ "${rl_lib_file_ext}" = 'sh' ] && \
				[ "${#rl_lib_file_name}" -gt 1 ]; then
				# keep rl_count_libs_found and ...
				return
			fi
		else
			# community and dev libs can have any extension
			return
		fi
	fi
	
	rl_count_libs_found=0
}

rl_find() {
	# handle forced calls to sections and path expressions
	# ${1} can contain "/"
	rl_lib_find_path="${shlibs_dirpath}"/libs
	if [ ${rl_force_section} -eq 0 ]; then
		rl_force_section=1
	else
		rl_lib_find_path="${rl_lib_find_path}/${rl_section}"
	fi
	rl_dev_dir=$(dirname -- "${1}")
	
	# handle symbolic links (dirs-sections)
	IFS='/'
	for rl_slash_seq in ${rl_dev_dir}
	do	
		if [ -n "${rl_slash_seq}" ] && [ "${rl_slash_seq}" != '.' ]; then
			rl_lib_find_path="${rl_lib_find_path}/${rl_slash_seq}"
			if [ -h "${rl_lib_find_path}" ]; then
				# resolve symbolic links
				rl_lib_find_path=$( cd "${rl_lib_find_path}" ; pwd -L ) || err_fs
			fi
		fi
	done
	IFS=${o_ifs}
	
	rl_fl="${1##*/}"
	
	# detect usage of paths
	# when a path is specified look for exact match
	# otherwise look for libs with name starting with provided code
	# official libs codes must be specified precisely (.sh optional)
	if [ "${rl_section}" = 'official' ]; then
		rl_fl=${1%.*}
		rl_fl="${rl_fl}.sh"
	else
		if echo "${1}" | ${SHLIBS_GREP} '/' >/dev/null 2>&1 ; then :
		else
			rl_fl="${rl_fl}*"
		fi
	fi
	
	if [ -d "${rl_lib_find_path}" ]; then
		# look for optimized! version of libs (src and headers)
		if [ -d "${rl_lib_find_path}/src" ] && [ -d "${rl_lib_find_path}/headers" ]; then
			rl_lib_find_path="${rl_lib_find_path}/src"
			rl_lib_headers_path="${rl_lib_find_path}/headers"
		else
			rl_lib_headers_path=''
		fi
		# find while stripping any preceding /
		rl_lib_path=$(find -L "${rl_lib_find_path}" -name "${rl_fl#/}" -type f)
	else
		return
	fi
		
	rl_count_libs_found=$(echo "${rl_lib_path}" | wc -l | xargs echo)
	
	if [ ${rl_count_libs_found} -eq 1 ]; then
		rl_post_find_preps
	elif [ "${rl_count_libs_found}" -gt 1 ]; then
		# multiple libs same name
		# trying to get the latest version (for optimized only)
		if [ -n "${rl_lib_headers_path}" ]; then
			# section comparable with dq_get_version() handling of versions
			# (change both if required)
			IFS=${nl}
			rl_mvers=0
			rl_find_index=0
			for rl_mvers_lib in ${rl_lib_path}
			do
				rl_find_index=$((rl_find_index+1))
				rl_mvers_lib=$(echo "${rl_mvers_lib}" | \
				${SHLIBS_AWK} '{
					match($0, /.\/libs\/(official|dev|community)\/src\//);
					if (RSTART > 0) {
						m=substr($0, RSTART, RLENGTH);
						sub("src","headers",m);
						print substr($0, 1, RSTART-1)m substr($0, RSTART+RLENGTH); 
					} else {
						print "";
					}
				}')
				
				rl_mvers_lib=${rl_mvers_lib%.*}
				if [ -r "${rl_mvers_lib}" ]; then
					rl_ivers=$(${SHLIBS_AWK} \
						'{ match($0,/r_l_s:/); \
						if (RSTART > 0) { print substr($0, RSTART+7); } }' \
						< "${rl_mvers_lib}" | xargs)
					
					if [ -n "${rl_ivers}" ]; then
						if [ -n "${opts_lib_version}" ] && \
							[ ${opts_lib_version} -gt 0 ] && \
							[ ${opts_lib_version} -eq ${rl_ivers} ]; then
							# version found!
							rl_mvers=${opts_lib_version}
							break
						elif [ ${rl_ivers} -gt ${rl_mvers} ]; then
							rl_mvers=${rl_ivers}
						fi
					fi
				#else
					# rl_mvers remains 0 which is handled below
				fi
			done
			IFS=${o_ifs}
			
			if [ ${rl_mvers} -gt 0 ]; then
				# specified vers cannot be found; using latest available				
				rl_lib_path=$(echo "${rl_lib_path}" | sed "${rl_find_index}"' !d')
				rl_count_libs_found=1
				rl_post_find_preps
			else
				s_err "Couldn't find a version number for ${rl_dev_code}"
				exit 1
			fi
		else
			# multiple libs, not optimized
			return
		fi
	fi
}


# Specific section request
# i.e. /dev/contains
rl_specific_parse_count=0
rl_specific_section=${rl_dev_code#/}
rl_specific_section=${rl_specific_section%%/*}
rl_specific_libcode=${rl_dev_code#*/}

if [ "${rl_specific_section}" = "${rl_specific_libcode}" ] &&
	[ ${#rl_dev_code} -eq ${#rl_specific_libcode} ]; then
	rl_specific_parse_count=1
else
	IFS='/'
	for rl_section in ${rl_dev_code#/}
	do	
		rl_section=$(echo ${rl_section} | xargs)
		if [ -z "${rl_section}" ] || [ "${rl_section}" = '.' ] || \
			[ "${rl_section}" = '..' ]; then		
			s_err "Invalid libcode. Use: shlibs section/libcode."
			exit 1
		fi
		rl_specific_parse_count=$((rl_specific_parse_count+1))
	done
	IFS=${o_ifs}
fi

if [ ${rl_specific_parse_count} -gt 1 ]; then
	case "${rl_specific_section}" in
		official|dev|community)
			rl_lib_path=$(echo "./libs/${rl_dev_code}" \
				| sed 's/[\/]\{2,\}/\//g')
			if [ -e "${rl_lib_path}" ]; then
				rl_count_libs_found=1
				rl_lib_file="${rl_lib_path##*/}"
				rl_lib_file_name=${rl_lib_file%.*}
			else
				# continue search with no exact match
				rl_force_section=0
				rl_find "${rl_dev_code}"
			fi
			;;
		*)
			s_err "Unknown section '${rl_specific_section}'.
To setup a script use: 'shlibs -s /path/to/script'"
			exit 1
			;;
	esac
elif [ ${rl_specific_parse_count} -eq 1 ]; then
	if [ ${rl_count_libs_found} -eq 0 ]; then
		# 'official' lib directory contains files having unique codes
		rl_section='official'
		rl_find "${rl_dev_code}"
	fi
	
	
	if [ ${rl_count_libs_found} -eq 0 ]; then
		rl_section='dev'
		rl_find "${rl_dev_code}"
	fi
	
	
	if [ ${rl_count_libs_found} -eq 0 ]; then
		rl_section='community'
		rl_find "${rl_dev_code}"
	fi
else
	s_err 'Unusual request. Use: shlibs section/libcode.'
	exit 1
fi
# end specific section


# at this point we must have a library
if [ ${rl_count_libs_found} -ne 1 ]; then
	s_err "Error: Found ${rl_count_libs_found} libraries for code '${rl_dev_code}'.
Use 'shlibs' to search for a library code first." 
	exit 1
fi


# if required return the script path
if [ ${rl_get_script_path} -eq 0 ]; then
	p_path=$( cd "$( dirname -- "${rl_lib_path}" )" ; pwd -L ) || err_fs
	p_path_bn="${rl_lib_path##*/}"
	echo "${p_path}/${p_path_bn}"
	exit
fi


rl_restore_lang() {
	if [ ${rl_has_setenv} -eq 0  ]; then
		setenv LANG=${prev_LC_MESSAGES}
	else
		LANG=${prev_LC_MESSAGES}
		export LANG
	fi
}


if [ -f "${rl_lib_path}" ] && [ -r "${rl_lib_path}" ]; then
	rl_dev_code_bn=$( echo "${rl_dev_code##*/}" | \
		sed -e 's/[^a-zA-Z0-9\./_-]//g' )
	rl_dev_code_bn="${rl_dev_code_bn%%.*}"
	
	# non official libs can contain any type of script
	# i.e. php, perl, python etc
	rl_var_script_return_code=0
	if ({	
		# help and examples requests are treated differently
			if [ "${opts_lib_help}" != '0' ] && \
				[ "${opts_lib_examples}" != '0' ]; then
				# regular requests
				rl_test_lib_wording_output='2>/dev/null'
			else
				# -h libcode or -x libcode requests
				rl_test_lib_wording_output='>/dev/null 2>&1'
			fi
			
			# makes a difference between shell scripts and other scripts
			rl_h1_interpreter=$(head -n 1 "${rl_lib_path}")
			if echo "${rl_h1_interpreter}" | \
				${SHLIBS_GREP} '^#!.\{0,\}/bin/.\{0,2\}sh$' >/dev/null ; then
				# .sh scripts category (i.e. #!/bin/sh)
				. "${rl_lib_path}" "${rl_test_lib_wording_output}"
			else
				# other types of scripts
				return 255 2>/dev/null
			fi			
			
			if type locale >/dev/null 2>&1 ; then
				# making sure 'function' keyword will be used
				prev_LC_MESSAGES=$(locale | ${SHLIBS_GREP} LC_MESSAGES 2>/dev/null)
				prev_LC_MESSAGES=${prev_LC_MESSAGES#*\"}
				prev_LC_MESSAGES=${prev_LC_MESSAGES%\"}
				prev_LC_MESSAGES=$(echo ${prev_LC_MESSAGES} | \
					${SHLIBS_GREP} -E "^(POSIX|C|en_.*)$" 2>/dev/null)
			else
				# this case is for systems where locale is not found
				prev_LC_MESSAGES=POSIX
			fi
			
			rl_plc=$(echo ${prev_LC_MESSAGES} | wc -l | xargs echo)
			if [ -n "${prev_LC_MESSAGES}" ] && [ ${rl_plc} -eq 1 ]; then :
			else
				if [ ${rl_has_setenv} -eq 0 ] ; then
					setenv LANG=POSIX
				else
					LANG=POSIX
					export LANG
				fi
			fi
			
			# by default shlibs runs the default function unless -z specified
			if [ "${opts_block_default_function}" != "0" ]; then
				if type "${rl_dev_code_bn}" 2>/dev/null | \
					${SHLIBS_GREP} 'function' >/dev/null 2>&1 ; then
					rl_restore_lang
					
					# critical: script ops are relative to shlibs_cwd
					cd "${shlibs_cwd}"	
					if ${rl_dev_code_bn} "${@}" ; then
						rl_var_script_return_code=0
					else
						return ${?} 2>/dev/null
					fi
				else
					rl_restore_lang
					s_err "Warning: Can't find a function \
'${rl_dev_code_bn}' in file '${rl_lib_path#\./}'.
You can use 'libpath=\$( shlibs -p \"${rl_dev_code}\" ); . \"\${libpath}\"' 
to source '${rl_dev_code_bn}' and call functions within as required."
					return 1 2>/dev/null
				fi
			fi
			
			if [ "${opts_lib_help}" = '0' ] \
				|| [ "${dq_lib_help}" = '0' ]; then
				if type "${rl_dev_code_bn}_help" 2>/dev/null | \
					${SHLIBS_GREP} 'function' >/dev/null 2>&1 ; then
					
					# $@ enables advanced help
					cd "${shlibs_cwd}"
					if [ "${dq_lib_help}" = '0' ]; then
						# query for libhelp: h+#
						eval "${rl_dev_code_bn}_help" "${@}" \
							> "${shlibs_dirpath}/var/tmp/${shlibs_session}/dq_libhelp"
					else
						# direct command
						eval "${rl_dev_code_bn}_help" "${@}"
					fi
					rl_var_script_return_code=${?}
					cd "${shlibs_dirpath}"
				else
					rl_var_script_return_code=1
					echo "No help available for '${rl_dev_code}'.
Missing '${rl_dev_code_bn}_help' function."
				fi
				rl_restore_lang
				exit ${rl_var_script_return_code}
			fi
			
			if [ "${opts_lib_examples}" = '0' ] \
				|| [ "${dq_lib_examples}" = '0' ]; then
				if type "${rl_dev_code_bn}_examples" 2>/dev/null | \
					${SHLIBS_GREP} 'function' >/dev/null 2>&1 ; then
					
					# $@ enables advanced examples
					cd "${shlibs_cwd}"
					if [ "${dq_lib_examples}" = '0' ]; then
						# query for libexamples: h+#
						eval "${rl_dev_code_bn}_examples" "${@}" \
							> "${shlibs_dirpath}/var/tmp/${shlibs_session}/dq_libexamples"
					else
						# direct command
						eval "${rl_dev_code_bn}_examples" "${@}"
					fi
					rl_var_script_return_code=${?}
					cd "${shlibs_dirpath}"					
				else
					rl_var_script_return_code=1
					echo "No examples available for '${rl_dev_code}'.
Missing '${rl_dev_code_bn}_examples' function."
				fi
				rl_restore_lang
				exit ${rl_var_script_return_code}
			fi
		}) ; then
		cd "${shlibs_dirpath}"
		exit ${rl_var_script_return_code}
	else
		# important position
		SHLIBS_SCRIPT_EXIT_CODE=${?}
		
		# critical! regular library calls Must Not return code 255	
		if [ ${SHLIBS_SCRIPT_EXIT_CODE} -eq 255 ]; then
			# other scripts (php, perl, python etc) ; must be executable (+x)
			if [ -x "${rl_lib_path}" ]; then
				rl_remove_x=1
			else
				# try to set +x temporary
				if chmod u+x "${rl_lib_path}" ; then
					if [ -x "${rl_lib_path}" ]; then
						rl_remove_x=0
					else
						s_err "Error: add +x for script '${rl_lib_path}' \
, or elevate privileges and try again."
						exit 1
					fi
				else
					s_err "Error: add +x for script '${rl_lib_path}' \
, or elevate privileges and try again."
					exit 1
				fi
			fi
			
			cd "${shlibs_cwd}"
			if [ ${#} -gt 0 ]; then
				"${rl_lib_path}" "${@}"
			else
				"${rl_lib_path}"
			fi
			# position sensitive
			rl_var_script_return_code=${?}
			cd "${shlibs_dirpath}"
			
			# restore x
			if [ ${rl_remove_x} -eq 0 ]; then
				chmod u-x "${rl_lib_path}"
			fi
			
			return ${rl_var_script_return_code} 2>/dev/null			
		else
			cd "${shlibs_dirpath}"
			exit ${SHLIBS_SCRIPT_EXIT_CODE}
		fi
	fi
else
	# not a regular or readable file
	rl_error_content="'${rl_lib_path}' is not a regular-readable file."
	s_err "${rl_error_content}"
	exit 1
fi
