#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com


SHLIBS_SETUP_DIALOG_BASIC_HELP="\t${SHLIBS_MATCH_HIGHLIGHT} Usage ${SHLIBS_MATCH_HIGHLIGHT}
\t[keywords] focused search for keywords (2 characters minimum)
\t[k+keywords] unfocused search for keywords (2 characters minimum)
\t[c] Clear keywords
\t[s] Skip setup of instance
\t[l] skip setup rest of Line
\t[1,2,3...] Select lib
\t[z+1,2,3...] get lib path
\t[f] go Fwd on libs list
\t[b] go Back on libs list
\t[h] show Help
\t[q] quit
\t${SHLIBS_MATCH_HIGHLIGHT} End Usage ${SHLIBS_MATCH_HIGHLIGHT}\n\n"
export SHLIBS_SETUP_DIALOG_BASIC_HELP
