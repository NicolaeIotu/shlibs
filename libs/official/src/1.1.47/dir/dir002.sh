#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

dir002() {
	if [ ${#} -lt 4 ]; then
		targetdirpath="${shlibs_dirpath}/var/tmp"
		digitcount=16
		tmpdirpath=''

		while [ ${#} -gt 0 ]
		do
			case ${1} in
				[1-9]|[1-9][0-9]*)
					if [ ${1} -gt 32 ]; then
						digitcount=32
					else
						digitcount=${1}
					fi
					shift
				;;
				-path)
					if [ -d "${2}" ]; then
						targetdirpath="${2}"
					else
						printf "${S_ERR_1}" "${rl_dev_code}"
						return 1
					fi
					shift 2
				;;
				*)
					printf "${S_ERR_1}" "${rl_dev_code}"
					return 1
				;;
			esac
		done

		it_count=0
		while :
		do
			tmpdirpath="${targetdirpath%%/}/$(${shlibs_dirpath}/shlibs str005 ${digitcount})"
			if [ -e "${tmpdirpath}" ]; then :
				it_count=$((it_count+1))

				if [ ${it_count} -gt 20 ]; then
					it_count=0
					digitcount=$((digitcount+1))

					if [ ${digitcount} -gt 32 ]; then
						echo "Too many iterations. Check or change ${targetdirpath}."
						return 1
					fi
				fi
			else
				if mkdir -p "${tmpdirpath}" ; then
					echo "${tmpdirpath}"
					return
				else
					echo "Cannot create a temporary file in ${targetdirpath}"
					return 1
				fi
			fi
		done
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

dir002_help() {
	echo 'Create a temporary directory and return the path to it.'
	echo 'It is highly recommended to cleanup your temporary locations when done!'
	echo 'Parameters:'
	echo ' - use -path to change destination (default ${SHLIBS_HOME}/var/tmp/)'
	echo ' - use digits to set the length of tmp directory name (default 16, max 32)'
}

dir002_examples() {
	echo 'tmpdir="$(shlibs dir002)"'
	echo '# ops involving $tmpdir'
	echo '# cleanup'
	echo 'shlibs dir001 "${tmpdir}"'
}

dir002_tests() {
	tests__='
tmpdir="$(shlibs dir002)"; res=${?}; shlibs dir001 "${tmpdir}"; echo "${res}${?}"
=======
00
'
	echo "${tests__}"
}
