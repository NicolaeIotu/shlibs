#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net       
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str050() {
	if [ ${#} -gt 0 ]; then
		isfileinput=1
		filepath=''
		str=''
		bw='-s'
		size=0
		
		while [ ${#} -gt 0 ]
		do
			case ${1} in
				-b)
					bw=''
					shift
				;;
				[1-9]|[1-9][0-9]*)
					if [ ${size} -ne 0 ]; then
						if [ -n "${str}" ]; then
							printf "${S_ERR_1}" "${rl_dev_code}"
							return 1
						else
							str="${1}"
						fi
					else
						size=${1}
					fi
					shift
				;;
				-f)
					if [ -n "${str}" ] || [ ${isfileinput} -eq 0 ]; then
						echo "${S_ERR_2}"
						return 1
					fi
					if [ -n "${2}" ] && [ -r "${2}" ]; then
						isfileinput=0
						filepath="${2}"
						shift 2
					else
						echo "Invalid file."
						return 1
					fi
				;;
				*)
					if [ -n "${str}" ]; then
						printf "${S_ERR_1}" "${rl_dev_code}"
						return 1
					fi
					str="${1}"
					shift
				;;
			esac
		done
		
		
		if [ ${isfileinput} -eq 0 ]; then
			if [ -n "${str}" ]; then
				printf "${S_ERR_1}" "${rl_dev_code}"
				return 1
			fi
		else
			if [ -z "${str}" ]; then
				printf "${S_ERR_1}" "${rl_dev_code}"
				return 1
			fi
		fi
		
		
		awk_script__ml='
		BEGIN { maxlen=0 }
		{
			if(NF>1) {
				len=NF-1
				for(i=1; i<=NF; i++) {
					len+=length($i)
				}
			} else len=length
			if (len>maxlen) maxlen=len
		}
		END { print maxlen }'
		
		awk_script__='
		BEGIN { cblank="['"${SHLIBS_CCLASS_BLANK}"']*$" }
		{
			res=""
			if (match($0,/\036$/)>0) {
				print substr($0,1,length-1)
				next
			}
			
			sub(""cblank,"")
			
			if (NF>1 && size>length) {
				len=0
				for(i=1; i<=NF; i++) {
					len+=length($i)
				}
				tsize=size-len
				base_size=int(tsize/(NF-1))
				extra_size_count=tsize-(base_size*(NF-1))
				i=base_size
				apnd=""
				while(i>0) {
					apnd=apnd " "
					i-=1
				}
				bg_index=index($0,$1)
				if(bg_index!=1) {
					res=substr($0,1,bg_index-1)
				}
				res=res $1
				for(i=2; i<=NF; i++) {
					if(i>extra_size_count+1) {
						res=res apnd $i
					} else {
						res=res apnd " " $i
					}
				}
				print res
			} else print $0
		}'
		
		if [ ${isfileinput} -eq 0 ]; then			
			if [ ${size} -gt 0 ]; then
				sed "s/$/${IRS}/" "${filepath}" | fold -b ${bw} -w ${size} | \
					${SHLIBS_AWK} -v size="${size}" "${awk_script__}"
			else
				indented_file_content=$(sed "s/$/${IRS}/" "${filepath}")
				size=$(echo "${indented_file_content}" | ${SHLIBS_AWK} "${awk_script__ml}")
				echo "${indented_file_content}" | \
					${SHLIBS_AWK} -v size="${size}" "${awk_script__}"
			fi
		else
			if [ ${size} -gt 0 ]; then
				echo "${str}" | sed "s/$/${IRS}/" | fold -b ${bw} -w ${size} | \
					${SHLIBS_AWK} -v size="${size}" "${awk_script__}"
			else
				indented_str_content=$(echo "${str}" | sed "s/$/${IRS}/")
				size=$(echo "${indented_str_content}" | ${SHLIBS_AWK} "${awk_script__ml}")
				echo "${indented_str_content}" | \
					${SHLIBS_AWK} -v size="${size}" "${awk_script__}"
			fi
		fi
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

str050_help() {
	echo 'Justify format string/file (+-wrap to size and break words).'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
	echo ' - wrap size (optional)'
	echo ' - use -b to break words (optional, works when wrap size specified)'
}

str050_examples() {
	echo 'shlibs str050 "A string used to test wrap and justify text using str050" 21'
	echo 'Result: '
	echo 'A   string   used  to'
	echo 'test     wrap     and'
	echo 'justify   text  using'
	echo 'str050'
}

str050_tests() {
	tests__='
shlibs str050 "A string used to test wrap and justify text using str050" 21
=======
A   string   used  to
test     wrap     and
justify   text  using
str050


shlibs str050 -f "$(shlibs -p tst004)" 30 | head -n 3
=======
Lorem  ipsum  dolor  sit amet,
consectetuer  adipiscing elit.
Nunc  congue  ipsum vestibulum
'
	echo "${tests__}"
}
