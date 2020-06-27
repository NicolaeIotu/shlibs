#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

ofc006() {
	if [ ${#} -lt 4 ]; then
		libs="${shlibs_dirpath}/libs"
		if [ ${#} -gt 0 ]; then
			while [ ${#} -gt 0 ]
			do
				case ${1} in
					-official)
						find "${libs}/official/headers" -type f \
							-exec ${SHLIBS_BASENAME} "{}" ";"
						shift
					;;
					-dev)
						find "${libs}/dev/headers" -type f \
							-exec ${SHLIBS_BASENAME} "{}" ";"
						shift
					;;
					-community)
						find "${libs}/community/headers" -type f \
							-exec ${SHLIBS_BASENAME} "{}" ";"
						shift
					;;
					*)
						printf "${S_ERR_1}" "${rl_dev_code}"
						return 2
					;;
				esac
			done
		else
			find "${libs}/official/headers" -type f \
				-exec ${SHLIBS_BASENAME} "{}" ";"
			find "${libs}/dev/headers" -type f \
				-exec ${SHLIBS_BASENAME} "{}" ";"
			find "${libs}/community/headers" -type f \
				-exec ${SHLIBS_BASENAME} "{}" ";"
		fi
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 2
	fi
}

ofc006_help() {
	echo 'Outputs a customizable list of all available shlibs library codes'
	echo 'Optional parameters:'
	echo ' - use "-official" to output the codes of official libraries'
	echo ' - use "-dev" to output the codes of dev libraries'
	echo ' - use "-community" to output the codes of community libraries'
}

ofc006_examples() {
	echo 'shlibs ofc006'
	echo 'Result: '
	echo 'str001 str002 str003 ...'
}
