#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

# TAG: PRE-H/O, TEST

# important: among others, cannot use parameter expansion expressions

shlibs_err_path='./var/comp/ptbl/shlibs_err.sh'

# important: enables support for paths containing spaces
shlibs_dirpath_esc=''
for path_part in ${shlibs_dirpath:?}
do
	if [ -n "${shlibs_dirpath_esc}" ]; then
		shlibs_dirpath_esc="${shlibs_dirpath_esc}\ "
	fi
	shlibs_dirpath_esc="${shlibs_dirpath_esc}${path_part}"
done
export shlibs_dirpath_esc


# SECTION 1_core
# test shell core capabilities
. './var/comp/cap/1_core/shlibs_test_sh.sh' 
if [ -z "${SHLIBS_SHELL_PATH}" ]; then
	. "${shlibs_err_path}" 
	s_err "No suitable shell found on this system! Tested: ${sts_allowed_shells}"
	exit 1
fi


# SECTION 2_shlibs
# 2. test tools required by shlibs
. './var/comp/cap/2_shlibs/shlibs_test_shlibs_crit.sh'


# SECTION 3_has_util
# 3. checks for existence of utilities (non-critical; assigns vars only)
te_has_util='./var/comp/cap/3_has_util/*'
for te_has_util_file in ${te_has_util}
do
	if [ -d "${te_has_util_file}" ]; then
		continue
	elif [ -r "${te_has_util_file}" ]; then
		. "${te_has_util_file}" >/dev/null 2>&1
	else
		. "${shlibs_err_path}" 
		s_err "Cannot read test: ${te_has_util_file}."
		exit 1	
	fi
done
