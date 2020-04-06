#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

ofc004() {
	find "${shlibs_dirpath}/libs/official/headers" -type f \
		-exec ${SHLIBS_BASENAME} "{}" ";"
}

ofc004_help() {
	echo 'Outputs a list of shlibs official library codes'
}

ofc004_examples() {
	echo 'shlibs ofc004'
	echo 'Result: '
	echo 'str001 str002 str003 ...'
}
