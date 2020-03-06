#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

# TAG: PRE-H/O, TEST

. './var/comp/cap/2_shlibs/shlibs_test_awk.sh'
if [ -z "${SHLIBS_AWK_PATH}" ]; then
	. "${shlibs_err_path}" 
	s_err 'Cannot find a suitable version of awk.'
	exit 1	
fi
. './var/comp/cap/2_shlibs/shlibs_test_basename.sh'
if [ -z "${SHLIBS_BASENAME}" ]; then
	. "${shlibs_err_path}" 
	s_err 'Cannot find a suitable version of basename.'
	exit 1	
fi
. './var/comp/cap/2_shlibs/shlibs_test_grep.sh'
if [ -z "${SHLIBS_GREP}" ]; then
	. "${shlibs_err_path}" 
	s_err 'Cannot find a suitable version of grep, -E or -F option(s) missing.'
	exit 1	
fi
. './var/comp/cap/2_shlibs/shlibs_test_tail.sh'
if [ -z "${SHLIBS_TAIL}" ]; then
	. "${shlibs_err_path}" 
	s_err 'Cannot find a suitable version of tail, n option missing.'
	exit 1	
fi


if . './var/comp/cap/2_shlibs/awk/refine/shlibs_awk_has_char_classes.sh' && \
	. './var/comp/cap/2_shlibs/sed/shlibs_sed_has_char_classes.sh' ; then
	SHLIBS_CCLASS_ALNUM='[:alnum:]'
	SHLIBS_CCLASS_ALPHA='[:alpha:]'
	SHLIBS_CCLASS_BLANK='[:blank:]'
	SHLIBS_CCLASS_CNTRL='[:cntrl:]'
	SHLIBS_CCLASS_DIGIT='[:digit:]'
	SHLIBS_CCLASS_GRAPH='[:graph:]'
	SHLIBS_CCLASS_LOWER='[:lower:]'
	SHLIBS_CCLASS_PRINT='[:print:]'
	SHLIBS_CCLASS_PUNCT='[:punct:]'
	SHLIBS_CCLASS_SPACE='[:space:]'
	SHLIBS_CCLASS_UPPER='[:upper:]'
	SHLIBS_CCLASS_XDIGIT='[:xdigit:]'
else
	# instead of making additional capabilities tests of tool 'tr'
	# declare classes of interest char by char mainly because Solaris default 'tr' 
	# fails to understand a format like a-z, A-Z or 0-9
	SHLIBS_CCLASS_DIGIT='0123456789'
	SHLIBS_CCLASS_UPPER='ABCDEFGHIJKLMNOPQRSTUVWXYZ'
	SHLIBS_CCLASS_LOWER='abcdefghijklmnopqrstuvwxyz'
	SHLIBS_CCLASS_XDIGIT='0123456789ABCDEFabcdef'
	SHLIBS_CCLASS_SPACE=`printf '\011-\015\040'`
	SHLIBS_CCLASS_BLANK=`printf '\011\040'`
	SHLIBS_CCLASS_CNTRL=`printf '\000-\037\177'`
	SHLIBS_CCLASS_PUNCT=`printf '\041-\057\072-\100\133-\140\172-\176'`
	SHLIBS_CCLASS_ALNUM="${SHLIBS_CCLASS_DIGIT}${SHLIBS_CCLASS_UPPER}\
		${SHLIBS_CCLASS_LOWER}"
	SHLIBS_CCLASS_ALPHA="${SHLIBS_CCLASS_UPPER}${SHLIBS_CCLASS_LOWER}"
	SHLIBS_CCLASS_GRAPH="${SHLIBS_CCLASS_PUNCT}${SHLIBS_CCLASS_DIGIT}\
		${SHLIBS_CCLASS_UPPER}${SHLIBS_CCLASS_LOWER}"
	SHLIBS_CCLASS_PRINT=" ${SHLIBS_CCLASS_GRAPH}"
fi	
export SHLIBS_CCLASS_ALNUM
export SHLIBS_CCLASS_ALPHA
export SHLIBS_CCLASS_BLANK
export SHLIBS_CCLASS_CNTRL
export SHLIBS_CCLASS_DIGIT
export SHLIBS_CCLASS_GRAPH
export SHLIBS_CCLASS_LOWER
export SHLIBS_CCLASS_PRINT
export SHLIBS_CCLASS_PUNCT
export SHLIBS_CCLASS_SPACE
export SHLIBS_CCLASS_UPPER
export SHLIBS_CCLASS_XDIGIT
