#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

# TAG: PRE-H/O, TEST

. "${shlibs_dirpath}/var/comp/cap/2_shlibs/shlibs_test_awk.sh"
if [ -z "${SHLIBS_AWK_PATH}" ]; then
	. "${shlibs_err_path}" 
	s_err 'Cannot find a suitable version of awk.'
	exit 1	
fi
. "${shlibs_dirpath}/var/comp/cap/2_shlibs/shlibs_test_basename.sh"
if [ -z "${SHLIBS_BASENAME}" ]; then
	. "${shlibs_err_path}" 
	s_err 'Cannot find a suitable version of basename.'
	exit 1	
fi
. "${shlibs_dirpath}/var/comp/cap/2_shlibs/shlibs_test_grep.sh"
if [ -z "${SHLIBS_GREP}" ]; then
	. "${shlibs_err_path}" 
	s_err 'Cannot find a suitable version of grep, -E or -F option(s) missing.'
	exit 1	
fi
. "${shlibs_dirpath}/var/comp/cap/2_shlibs/shlibs_test_tail.sh"
if [ -z "${SHLIBS_TAIL}" ]; then
	. "${shlibs_err_path}" 
	s_err 'Cannot find a suitable version of tail, n option missing.'
	exit 1	
fi

# an impressive number of errors are triggered by character classes; use own
SHLIBS_CCLASS_DIGIT='0123456789'
SHLIBS_CCLASS_UPPER='ABCDEFGHIJKLMNOPQRSTUVWXYZ'
SHLIBS_CCLASS_LOWER='abcdefghijklmnopqrstuvwxyz'
SHLIBS_CCLASS_XDIGIT='0123456789ABCDEFabcdef'
SHLIBS_CCLASS_SPACE=`printf '%b' '\011\012\013\014\015\040'`
SHLIBS_CCLASS_BLANK=`printf '%b' '\011\040'`
SHLIBS_CCLASS_CNTRL=`printf '%b' '\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\177'`
SHLIBS_CCLASS_PUNCT=`printf '%b' '\041\042\043\044\045\046\047\050\051\052\053\054\055\056\057\072\073\074\075\076\077\100\133\134\135\136\137\140\173\174\175\176'`
SHLIBS_CCLASS_ALNUM="${SHLIBS_CCLASS_DIGIT}${SHLIBS_CCLASS_UPPER}\
${SHLIBS_CCLASS_LOWER}"
SHLIBS_CCLASS_ALPHA="${SHLIBS_CCLASS_UPPER}${SHLIBS_CCLASS_LOWER}"
SHLIBS_CCLASS_GRAPH="${SHLIBS_CCLASS_PUNCT}${SHLIBS_CCLASS_DIGIT}\
${SHLIBS_CCLASS_UPPER}${SHLIBS_CCLASS_LOWER}"
SHLIBS_CCLASS_PRINT=" ${SHLIBS_CCLASS_GRAPH}"

export SHLIBS_CCLASS_ALNUM SHLIBS_CCLASS_ALPHA SHLIBS_CCLASS_BLANK \
	SHLIBS_CCLASS_CNTRL SHLIBS_CCLASS_DIGIT SHLIBS_CCLASS_GRAPH \
	SHLIBS_CCLASS_LOWER SHLIBS_CCLASS_PRINT SHLIBS_CCLASS_PUNCT \
	SHLIBS_CCLASS_SPACE SHLIBS_CCLASS_UPPER SHLIBS_CCLASS_XDIGIT
