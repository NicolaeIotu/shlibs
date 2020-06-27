#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

dir001() {
	if [ ${#} -eq 0 ]; then
		echo 'Nothing to delete.'
		return 1
	fi
	
	for dir001_rmpath in "${@}"
	do
		if [ -d "${dir001_rmpath}" ]; then
			if find "${dir001_rmpath}" -depth -type f \
				-exec rm -rf "{}" ";" ; then			
				if find "${dir001_rmpath}" -depth -type d \
					-exec rmdir "{}" ";" ; then :
				else
					return 1
				fi				
			else
				return 1
			fi
		else
			rm "${dir001_rmpath}" 2>/dev/null
		fi
	done
}

dir001_help() {
	echo 'Recursively empties and removes directory or file'
	echo '${@} - Path(s) to be removed'
}

dir001_examples() {
	echo 'shlibs dir001 "/path/to/be/removed" "/other/path" ...'
	echo 'echo ${?}'
	echo 'Success: 0'
	echo 'Fail: 1'
}

dir001_skip_tests=0
