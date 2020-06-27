#!/bin/sh

# shlibs is Copyright (C) 2020 Nicolae Iotu, nicolae.g.iotu@gmail.com
# https://shlibs.org, https://shlibs.net
# License: Apache-2.0 modified with Convergence Terms (LICENSE-section 10)
# "Use for free. Contribute rather than diverge."

# Author Nicolae Iotu, nicolae.g.iotu@gmail.com

str058() {
	if [ ${#} -gt 0 ]; then
		isfileinput=1
		filepath=''
		str=''
		bw='-s'
		size=0
		indent=4
		
		while [ ${#} -gt 0 ]
		do
			case ${1} in
				-indent)
					test ${2} -gt 0 2>/dev/null || {
						printf "${S_ERR_1}" "${rl_dev_code}"
						exit 1
					}
					indent=${2}
					shift 2
					;;
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
					if [ -r "${2}" ]; then
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
		
		
		if [ ${size} -gt 0 ]; then
			if [ ${indent} -ge ${size} ]; then
				indent=$((size-2)) #2 experimental
			fi
		fi			
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
		{
			res=""
			if (match($0,/\036$/)>0) {
				print substr($0,1,length-1)
				next
			}
			
			sub(""cblank,"")
			sub("["ENVIRON["SHLIBS_CCLASS_BLANK"]"]*$","")
			
			if (NF>1 && size>length) {
				len=0
				for(i=1; i<=NF; i++) {
					len+=length($i)
				}
				tsize=size-len
				
				bg_index=index($0,$1)
				if(index($0,ENVIRON["indent_apnd"])==1) {
					res=ENVIRON["indent_apnd"]
					if(bg_index!=ENVIRON["indent"]+1) {
						res=res substr($0,ENVIRON["indent"],bg_index-ENVIRON["indent"])
					}
					res=res $1
					tsize-=ENVIRON["indent"]
				} else {
					if(bg_index!=1) {
						res=substr($0,1,bg_index)
					}
					res=res $1
				}
				
				base_size=int(tsize/(NF-1))
				extra_size_count=tsize-(base_size*(NF-1))
				i=base_size
				apnd=""
				while(i>0) {
					apnd=apnd " "
					i-=1
				}
				
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
				str058_update_indent
				sed "{
					s/^/${indent_apnd}/
					s/$/${IRS}/
				}" "${filepath}" | fold -b ${bw} -w $((size+1)) | \
					${SHLIBS_AWK} -v size="${size}" "${awk_script__}"
			else
				indented_file_content=$(sed " s/^/${indent_apnd}/; s/$/${IRS}/ " "${filepath}")
				
				size=$(echo "${indented_file_content}" | ${SHLIBS_AWK} "${awk_script__ml}")
				if [ ${indent} -ge ${size} ]; then
					indent=$((size-1))
				fi
				str058_update_indent
				# if requested perform fold using size minus indent (?!~)
				echo "${indented_file_content}" | \
					${SHLIBS_AWK} -v size="${size}" "${awk_script__}"
			fi
		else
			if [ ${size} -gt 0 ]; then
				str058_update_indent
				echo "${str}" | sed "{
					s/^/${indent_apnd}/
					s/$/${IRS}/
				}" | fold -b ${bw} -w $((size+1)) | \
					${SHLIBS_AWK} -v size="${size}" "${awk_script__}"
			else
				indented_str_content=$(echo "${str}" | sed " s/^/${indent_apnd}/; s/$/${IRS}/ ")
				size=$(echo "${indented_str_content}" | ${SHLIBS_AWK} "${awk_script__ml}")
				if [ ${indent} -ge ${size} ]; then
					indent=$((size-1))
				fi
				str058_update_indent
				# if requested perform fold using size minus indent (?!~)
				echo "${indented_str_content}" | ${SHLIBS_AWK} \
					-v size="${size}" "${awk_script__}"
			fi
		fi
	else
		printf "${S_ERR_1}" "${rl_dev_code}"
		return 1
	fi
}

str058_update_indent() {
	indent_apnd=''
	j=${indent}
	while [ ${j} -gt 0 ]
	do
		indent_apnd="${indent_apnd} "
		j=$((j-1))
	done
	export indent
	export indent_apnd
}

str058_help() {
	echo 'Paragraph format string/file (+-wrap to size and break words).'
	echo 'Parameters:'
	echo ' - subject string, or "-f /path/to/text/file" to process file content'
	echo ' - wrap size (optional)'
	echo ' - use -b to break words (optional, works when wrap size specified)'
	echo ' - use "-indent n" to add n spaces at the beginning of first line'
	echo '   (optional, defaults to 4)'
}

str058_examples() {
	echo 'shlibs str058 "A string used to test paragraph format text using str058" 21'
	echo 'Result: '
	echo '    A  string used to'
	echo 'test paragraph format'
	echo 'text using str058'
}

str058_tests() {
	tests__='
shlibs str058 "A string used to test paragraph format text using str058" 21
=======
    A  string used to
test paragraph format
text using str058


shlibs str058 -f "$(shlibs -p tst004)" 24 | head -n 3
=======
    Lorem   ipsum  dolor
sit  amet,  consectetuer
adipiscing   elit.  Nunc
'
	echo "${tests__}"
}
