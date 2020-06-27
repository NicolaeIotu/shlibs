#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

gen001() {
	is_show=0
	m_field=1
	is_pkm=0
	is_install=1
	is_remove=1
	is_force=1
	pkg_list=''
	gen001_orig_params="${@}"
	
	while [ ${#} -gt 0 ]
	do
		case ${1} in
			-install)
				if [ ${is_remove} -eq 0 ]; then
					echo 'Cannot install and remove at the same time.'
					return 1
				else
					is_pkm=1
					is_install=0
					m_field=2
				fi
				shift
			;;
			-remove)
				if [ ${is_install} -eq 0 ]; then
					echo 'Cannot install and remove at the same time.'
					return 1
				else
					is_pkm=1
					is_remove=0
					m_field=3
				fi
				shift
			;;
			-y)
				is_pkm=1
				is_force=0
				shift
			;;
			*)
				if [ -n "${pkg_list}" ]; then
					pkg_list="${pkg_list} ${1}"
				else
					pkg_list="${1}"
				fi
				shift
			;;
		esac
	done
	
	if type "${pkg_list}" >/dev/null 2>&1 ; then
		return
	fi
	
	gen001_ostable="$(cat ${rl_lib_dirpath}/gen001.dat)"
	
	# post input logic
	if [ -n "${pkg_list}" ] ; then
		if [ ${is_install} -eq 1 ] && [ ${is_remove} -eq 1 ]; then
			echo 'No operations specified.'
			return 1
		fi
		is_show=1
	else
		if [ ${is_force} -eq 0 ]; then
			echo 'No packages specified.'
			return 1
		fi
		is_show=0
	fi
	
	IFS=${_nl}
	for osline in ${gen001_ostable}
	do
		# check line format
		tst=$(echo "${osline}" | tr -dc ':')
		if [ "${tst}" = ':::' ] ; then
			# assume yes
			if [ ${is_force} -eq 0 ]; then
				fo="$(echo ${osline} | cut -d':' -f4)"
			else
				fo=''
			fi
			
			# tool checks
			r_tool="$(echo ${osline} | cut -d':' -f${m_field})"
			test_tool="$(echo ${r_tool} | cut -d' ' -f1)"
			if [ -n "${test_tool}" ] && type ${test_tool} >/dev/null 2>&1 ; then
				if [ ${is_show} -eq 0 ]; then
					echo "${r_tool}"
					return
				else
					if eval ${r_tool} ${pkg_list} ${fo} ; then
						return
					else
						printf "Library '%s' requires elevated privileges as in:\n" 'gen001'
						echo "    sudo -i shlibs ${rl_dev_code} ${gen001_orig_params}"
						echo ", or '${pkg_list}' cannot be found by tool '${r_tool}'."
						return ${res}
					fi
				fi
			else
				continue
			fi
		fi
	done
	IFS=${o_ifs}
	
	return 250
}

gen001_help() {
	echo 'Install/remove packages or show package management tools (i.e. install, remove)'
	echo 'By default returns the package manager of the system.'
	echo 'Requires elevated privileges.'
	echo 'Parameters:'
	echo ' - use flag "-install ..." to install packages or show install cmd'
	echo ' - use flag "-remove ..." to remove packages or show remove cmd'
	echo ' - use flag "-y" to assume "yes" on all operations (if possible)'
	echo 'Returns 0 on success, 1 on errors and code 250 when no tools found.'
}

gen001_examples() {
	echo 'shlibs gen001'
	echo 'Result: dnf'
	echo 'shlibs gen001 -install'
	echo 'Result: dnf install'
	echo 'sudo -i shlibs gen001 tmux -y -install screen'
}

gen001_skip_tests=0
