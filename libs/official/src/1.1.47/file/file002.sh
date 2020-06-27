#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

file002() {
	if [ ${#} -lt 4 ]; then
		tmpdirpath="${shlibs_dirpath}/var/tmp"
		digitcount=16
		tmpfilepath=''

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
						tmpdirpath="${2}"
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
			tmpfilepath="${tmpdirpath%%/}/$(${shlibs_dirpath}/shlibs str005 ${digitcount})"
			if [ -e "${tmpfilepath}" ]; then :
				it_count=$((it_count+1))

				if [ ${it_count} -gt 20 ]; then
					it_count=0
					digitcount=$((digitcount+1))

					if [ ${digitcount} -gt 32 ]; then
						echo "Too many iterations. Check or change ${tmpdirpath}."
						return 1
					fi
				fi
			else
				if touch "${tmpfilepath}" ; then
					echo "${tmpfilepath}"
					return
				else
					echo "Cannot create a temporary file in ${tmpdirpath}"
					return 1
				fi
			fi
		done
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

file002_help() {
	echo 'Create a temporary file and return the path to it.'
	echo 'It is highly recommended to cleanup your temporary files when done!'
	echo 'Parameters:'
	echo ' - use -path to change destination (default ${SHLIBS_HOME}/var/tmp/)'
	echo ' - use digits to set the length of tmp file name (default 16, max 32)'
}

file002_examples() {
	echo 'tmpfile="$(shlibs file002)"'
	echo '# ops involving $tmpfile'
	echo '# cleanup'
	echo 'rm "${tmpfile}"'
}

file002_tests() {
	tests__='
tmpfile="$(shlibs file002)"; res=${?}; rm -f "${tmpfile}"; echo "${res}${?}"
=======
00
'
	echo "${tests__}"
}
