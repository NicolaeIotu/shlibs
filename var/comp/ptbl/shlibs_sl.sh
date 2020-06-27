#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

# TAGS: PRE-H/O, PORTABLE, MORPH

(
	"unalias" -a
	umask 0002
	
	##sed d_s_b##
	
	# multiscript optimisation
	if [ -d "${shlibs_dirpath}" ] && [ -f "${shlibs_path}" ]; then
		. "./scripts/${d_s_b:?}"
		return ${?} 2>/dev/null
	fi
	
	shlibs_cwd=`cd "\`dirname -- . 2>/dev/null\`" ; pwd -L` || exit 1
	if [ -f "${shlibs_cwd}/shlibs" ] ; then
		# cd to dir and source script
		shlibs_dirpath="${shlibs_cwd}"
	else
		# execute script
		shlibs_dirpath=`cd "\`dirname -- "${0}" 2>/dev/null\`" ; pwd -L` || exit 1
		if [ -f "${shlibs_dirpath}/shlibs" ] ; then :
		else
			echo 'Error: execute script, or cd to script dir before sourcing it.'
			return 1 2>/dev/null
		fi
	fi
	shlibs_path="${shlibs_dirpath:?}/shlibs"
	
	# from this point use relative paths with no spaces
	cd "${shlibs_dirpath}" || exit 1
	
	if [ -r "${shlibs_path}" ] && [ -x "${shlibs_path}" ]; then
		if [ -z "${PATH}" ] ; then
			PATH='/bin:/sbin:/usr/bin:/usr/sbin'
		fi
		
		# make sure local shlibs is used first (this is just a subshell modif)
		PATH="${shlibs_dirpath}:${PATH}"
		IFS=`printf '%b' ' \t\n'`
		o_ifs=${IFS}
		
		export PATH IFS o_ifs shlibs_cwd shlibs_dirpath shlibs_path
		
		##sed S_F_S##
		export SHLIBS_FORCE_SHELL
		if [ -n "${SHLIBS_SHELL_PATH}" ]; then :
			# skip tests (assumed passed) if a shlibs lib calls other shlibs libs
		else
			. "${shlibs_dirpath}/var/comp/cap/shlibs_test_env.sh"
		fi
		
		if [ -r "./scripts/${d_s_b:?}" ]; then
			exec "${SHLIBS_SHELL_PATH}" "./scripts/${d_s_b:?}" "${@}"
		else
			echo "Error: unreadable '${shlibs_dirpath}/scripts/${d_s_b:?}'"
			return 1 2>/dev/null
		fi		
	else
		echo 'Cannot read+execute shlibs.'
		return 1 2>/dev/null
	fi
)
