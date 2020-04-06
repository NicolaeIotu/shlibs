#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

ofc003_changelog_header='
************************************
*         shlibs Changelog         *
************************************'
ofc003_changelog_template='
+----------------------------------+
    shlibs v%s / libs v%s
+----------------------------------+
%b'

ofc003_rls_3=$( printf "${ofc003_changelog_template}" '1.2.21' '1.0.13' \
">>> shlibs Application 1.2.21
- important addition: it is now possible to search for a precise sequence \
of words; in query/setup script mode use [\"+search sequence], or \
[\"search sequence\"] to look for a precise sequence of words; this syntax \
cancels default behavior considering space character as AND operator, and \
comma character as OR operator
- eliminated duplicated declaration of ss_psl_shlibs_ere in shlibs_setup_script.sh
- corrected highlighting of replacements of shlibs instances when processing \
scripts
- prevented display of trap errors if any occuring (detected SIGKILL on FreeBSD)
- corrected redirection by replacing tr interval values with specific values \
in order to match application strategy
 
 
>>> shlibs Official Libraries 1.0.13
- str050 - upgrade to release 2: corrected an error causing wrap at 'size-1' \
instead of 'size' as designed
- str058 - upgrade to release 2: corrected an error causing wrap at 'size-1' \
instead of 'size' as designed
- tst001 - upgrade to release 3: improved eval syntax to avoid errors on \
all implementations of this tool
- ofc001, ofc002, ofc003 - upgrade to release 3: changed version and release numbers
" )

ofc003_rls_2=$( printf "${ofc003_changelog_template}" '1.1.16' '1.0.7' \
">>> shlibs Application 1.1.16
- significant improvement: introduced option 'C' which clears (query) or \
clears and summarizes (setup script) output of terminal. Use 'C' whenever \
the output is messy due to any factors including manual or programmatic \
resize of display device/terminal; updates to structure and code to allow option 'C'
- significant improvement: when processing script, instances of shlibs and \
their replacements are additionally highlighted with bold red
- added protection of shlibs internal structure when processing scripts
- corrected an error occurring when choosing library in script setup mode \
and causing double quoted params to be omitted from generated script \
(i.e. 3+\"DQuoted text went missing\" 44 other_params)
- improved/updated help and examples texts
- prevented shlibs from being piped to others in query and script setup modes
- corrected error not showing help and examples of libs when using versions
- removed minimum number of libs in query mode
- corrected the naming of some vars to be meaningful for the values they store
- corrected wording error occurring in query mode when multiple versions of \
libs are in use and selection is complete
- minor format improvements
- format corrections to allow visualization of libs/dev and lib/community
- minor format correction to README.md
- deleted erroneous file
- created CODE_OF_CONDUCT.md, REQUESTS.md, TODO.md
- update issue templates
 
 
>>> shlibs Official Libraries 1.0.7
- trm001 - new addition: Get cursor position in terminal (u.o.m. characters)
- tst001 - upgrade to release 2: improved handling when testing versions of \
libraries
- str029 - upgrade to release 2: prevented an error occurring when using multiple \
classes which include space or blank classes
- str031 - upgrade to release 2: corrected an error causing the last character \
to remain unshuffled
- ofc001, ofc002 - upgrade to release 2: changed version and release numbers
- ofc003 - upgrade to release 2: improved handling of changelogs, updated \
changelog
" )

ofc003_rls_1=$( printf "${ofc003_changelog_template}" "1.0.0" "1.0.0" \
"The first release of shlibs and libraries" )

ofc003() {
	ofc003_log_content=''
	if [ ${#} -eq 0 ] ; then
		# latest changelog
		ofc003_log_content=''
		ofc003_i=1
		while [ ${ofc003_i} -gt 0 ]
		do
			eval ofc003_tmp=$(echo "$"ofc003_rls_${ofc003_i}"")
			if [ -n "${ofc003_tmp}" ] ; then
				ofc003_log_content="${ofc003_tmp}"
				ofc003_i=$((ofc003_i+1))
			else
				break
			fi
		done
	elif [ "${1}" = '0' ]; then
		# all the changelogs
		ofc003_log_content=''
		ofc003_i=1
		while [ ${ofc003_i} -gt 0 ]
		do
			eval ofc003_tmp=$(echo "$"ofc003_rls_${ofc003_i}"")
			if [ -n "${ofc003_tmp}" ] ; then
				ofc003_log_content="${ofc003_tmp}
${ofc003_log_content}"
				ofc003_i=$((ofc003_i+1))
			else
				break
			fi
		done
	elif [ ${1} -gt 0 ] 2>/dev/null ; then
		# specific changelog
		eval ofc003_log_content=$(echo "$"ofc003_rls_${1}"")
		if [ -z "${ofc003_log_content}" ]; then
			echo "No such release number found! (${1})"
			return 1
		fi
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
	
	printf '%s' "${ofc003_changelog_header}" | tail -n 3
	echo "${ofc003_log_content}" | fold -s -w ${SHLIBS_TERMINAL_CHAR_WIDTH}
}

ofc003_help() {
	echo 'shlibs Changelog'
	echo 'When no parameters specified shows the latest shlibs Changelog.'
	echo 'Parameters:'
	echo ' - use 0 to show the complete changelog (optional)'
	echo ' - use # to show the changelog for release (optional)'
}

ofc003_examples() {
	echo '# latest changelog'
	echo 'shlibs ofc003'
	echo '# specific changelog (for release 2 of shlibs)'
	echo 'shlibs ofc003 2'
	echo '# all the changelogs'
	echo 'shlibs ofc003 0'
}
