#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

# TAGS: PORTABLE

# critical var
esc_shlibs_dirpath=$(echo "${shlibs_dirpath:?}" | sed 's/\//\\\\\//g')

# a newline
nl=$(printf '%b' '\n\r')
export nl

# shlibs version
SHLIBS_VERSION=1.0.0
export SHLIBS_VERSION
# shlibs release
SHLIBS_RELEASE=1
export SHLIBS_RELEASE

# the email for requests
SHLIBS_REQUESTS='contact@shlibs.net'
export SHLIBS_REQUESTS
