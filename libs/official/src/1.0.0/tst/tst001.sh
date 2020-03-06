#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com


tst001_skips='ofc tst'
tst001_total_libs=0
tst001_total_tests=0
tst001_total_tests_passed=0
tst001_total_tests_skipped=0
tst001_sep='======================================================================'

tst001() {
	shlibs_path_esc="$(echo "${shlibs_dirpath}/shlibs" | sed 's/[\/]/\\\//g')"
	shlibs_path_esc="$(echo "${shlibs_path_esc}" | sed 's/ /\\\\ /g')"
	
	if [ ${#} -eq 0 ]; then
		libs_list="$("${shlibs_dirpath}"/shlibs ofc004)"
		
		IFS=${nl}
		for lib in ${libs_list}
		do
			if tst001_check_skips "${lib}" ; then :
			else
				tst001_test_lib "${lib}"
			fi
		done
		IFS=${o_ifs}
	else
		for prm in "${@}"
		do
			if tst001_check_skips "${prm}" ; then
				echo "Testing of '${tst001_skips}' is forbidden."
				return 1
			else
				tst001_test_lib "${prm}"
			fi
		done
	fi
	

	if [ ${tst001_total_tests} -eq 0 ]; then
		perc_passed=0
	else
		pcalc="${tst001_total_tests_passed}*100/${tst001_total_tests}"
		perc_passed="$( ${SHLIBS_AWK} -v CONVFMT='%.2f' -v OFMT='%.2f' \
			'BEGIN { printf '"${pcalc}"' }' )"
		
	fi
	printf "%s\nTested %s lib(s). Tests passed %s%s (%s). Libs skipped: %s.\n" \
		 "${tst001_sep}" "${tst001_total_libs}" "${perc_passed}" '%' \
		"${tst001_total_tests_passed}/${tst001_total_tests}" \
		"${tst001_total_tests_skipped}"
		
	if [ ${#} -eq 0 ]; then
		echo "${tst001_sep}"
		uname -a
	fi
	
	if [ ${tst001_total_tests_passed} -ne ${tst001_total_tests} ] || \
		[ ${tst001_total_tests} -eq 0 ] ; then
		return 1
	fi
}

tst001_check_skips() {
	p_ifs=${IFS}
	IFS=${o_ifs}
	for skip in ${tst001_skips}
	do
		if echo "${1}" | grep "${skip}" >/dev/null ; then
			IFS=${p_ifs}
			return 0
		fi
	done
	IFS=${p_ifs}
	return 1
}

tst001_test_lib() {
	tst001_total_libs=$((tst001_total_libs+1))
	tst001_lib_tests_total=0
	tst001_lib_tests_passed=0
	if lib_path=$( "${shlibs_dirpath}"/shlibs -p "${1}" ); then
		. "${lib_path}"
		
		# i.e. str040_skip_tests=0
		eval skip_tests="$"${1}_skip_tests""
		if [ "${skip_tests}" = '0' ]; then
			echo "Skipping tests of '${1}'."
			tst001_total_tests_skipped=$((tst001_total_tests_skipped+1))
			return
		fi
		
		if lib_tests="$(eval ${1}_tests 2>/dev/null)" 2>/dev/null ; then
			printf '** Testing %s. ' "${1}"
		else
			tst001_total_tests=$((tst001_total_tests+1))
			printf '** Missing %s_tests function.\n' "${1}"
			return 1
		fi
		lib_tests=$( echo "${lib_tests}" | sed 's/^$/++++/' )
		
		test_line=0
		result_line=1
		test_result=''
		expected_result=''
		test_command=''
		
		IFS=${nl}
		for test_seq in ${lib_tests}
		do
			l_def=$(expr "${test_seq}" : "\(.\{4\}\)" 2>/dev/null)
			if [ "${l_def}" = '++++' ]; then
				tst001_test_wording "${1}"
				test_line=0
				result_line=1
				test_result=''
				expected_result=''
				test_command=''
			elif [ "${l_def}" = '====' ]; then
				result_line=0
				test_line=1
			else
				if [ ${test_line} -eq 0 ]; then
					test_command="${test_seq}"
					test_seq="$(echo "${test_seq}" | \
						sed 's/shlibs /'"${shlibs_path_esc}"' /g' )"
					
					int_tr="$( eval "${test_seq}" )"
					if [ -n "${int_tr}" ]; then
						if [ -n "${test_result}" ]; then
#important
							test_result="${test_result}
${int_tr}"
						else
							test_result="${int_tr}"
						fi
					fi
				elif [ ${result_line} -eq 0 ]; then
					if [ -n "${expected_result}" ]; then
#important
						expected_result="${expected_result}
${test_seq}"
					else
						expected_result="${test_seq}"
					fi
				fi
			fi
		done
		IFS=${o_ifs}
		
		tst001_test_wording "${1}"
		
		printf 'Results: %s/%s (passed/total).\n' \
			"${tst001_lib_tests_passed}" "${tst001_lib_tests_total}"
	else
		tst001_total_tests=$((tst001_total_tests+1))
		printf '** Missing library %s.\n' "${1}"
		return 1
	fi
}

tst001_test_wording() {
	if [ -n "${test_result}" ] && [ -n "${expected_result}" ]; then
		if test "${test_result}" = "${expected_result}" ; then
			tst001_lib_tests_passed=$((tst001_lib_tests_passed+1))
			tst001_total_tests_passed=$((tst001_total_tests_passed+1))
		else
			printf '\nTest failed:\n%b\n' "'${test_command}'"
			printf 'See "shlibs -h %s" for details.\n' "${1}"
		fi
		tst001_lib_tests_total=$((tst001_lib_tests_total+1))
		tst001_total_tests=$((tst001_total_tests+1))
		test_result=''
		expected_result=''
	fi
}

tst001_help() {
	echo 'Development utility used to test shlibs libraries.'
	echo 'By default only the official libs are tested.'
	echo 'Use library codes as arguments to test specific libraries from any category.'
	echo 'If your OS is not listed on https://shlibs.org, https://shlibs.net, or'
	echo 'if some tests fail, please send the results to the contact above.'
}

tst001_examples() {
	echo 'shlibs tst001 str015'
	echo 'Result:'
	echo 'Testing str015. Results: 2/2 (passed/total).'
	echo "${tst001_sep}"
	echo 'Tested 1 libs. Tests passed 100% (2/2).'
}
