#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com


SHLIBS_SETUP_DIALOG_FULL_HELP="\t${SHLIBS_MATCH_HIGHLIGHT} Usage ${SHLIBS_MATCH_HIGHLIGHT}
\t  1. Searching lib:
\t[keywords] focused search for keywords (2 characters minimum)
\t[k+keywords] unfocused search for keywords (2 characters minimum)
\t[c] Clear keywords
\ti.e. 'split string', or 'k+split string'
\tSeparate words using space ' ' to match in any order all keywords.
\tSeparate words using comma ',' to match in any order, any keywords.
\tSuccessive search calls are treated as comma ',' separated sequences.
\t  2. Select lib:
\tAny libs found when using the keywords above will be displayed using 
\ta numbered list which shows a limited amount of entries as set
\tin shlibs_settings.sh.
\tPick a number to select corresponding lib: 1, 2, 3 ...
\t(SHLIBS_MATCH_PAGE_SIZE and SHLIBS_MATCH_MAX).
\tThe list can be navigated [b]ack and [f]orth.
\t  3. In setup mode:
\t[p+lib number] get lib path.
\t[s] Skip setup of instance.
\t[l] skip setup rest of Line.
\t  4. Others:
\t[h] show Help
\t[q] quit
\t${SHLIBS_MATCH_HIGHLIGHT} End Usage ${SHLIBS_MATCH_HIGHLIGHT}\n\n"
export SHLIBS_SETUP_DIALOG_FULL_HELP
