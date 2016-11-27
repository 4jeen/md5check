#!/bin/bash
#
#
#
function CHECK_FILE(){
	local _CHECKSUM=`awk '{print($1)}' "$1.md5"`
	local _LFILENAME=`awk '{print($2)}' "$1.md5"`
	echo -n "Processing file: $_LFILENAME "
	local _CALCULATED_CHECKSUM=`${PROG_NAME} "$1"|awk '{print($1)}'`
	if [[ "${_CHECKSUM}" = "${_CALCULATED_CHECKSUM}" ]]; then
		echo " OK"
		return 0
	else
		echo " BROKEN!!!"
		return 1	
	fi
}



WORK_DIR=`pwd`
PROG_NAME=`which md5`
if [[ $? -ne 0 ]];then
	PROG_NAME="md5sum"
else
	PROG_NAME=${PROG_NAME}" -r"	
fi

if [ -z $1 ];then
		echo "USAGE:"
		echo "$0 [-cd] file or directory name"
		echo "-c check file with checksum in md5 file or all files i directory"
		echo "-d create checksum file for every entry in working directory"
		echo "filename - create checksum md5 file"
		exit 0
fi

MAIN_COMMAND=$1
MAIN_COMMAND_PARAM=$2

case ${MAIN_COMMAND} in
	"-c" )
		if [[ -d "${MAIN_COMMAND_PARAM}" ]]; then
			TMP_WORK_DIR="${WORK_DIR}"
			WORK_DIR="${MAIN_COMMAND_PARAM}"
			cd "${WORK_DIR}" 
			for _file in `ls *.md5|sed 's/.md5$//'`
			do
				CHECK_FILE ${_file}	
			done
		elif [[ -e $MAIN_COMMAND_PARAM.md5 ]];then
			CHECK_FILE ${MAIN_COMMAND_PARAM}
			exit $?
		else
			echo "check sum file ${MAIN_COMMAND_PARAM} not found"	
			exit 1
		fi
	;;
	"-d" )
		if [ -z "${MAIN_COMMAND_PARAM}" ];then
			for file in `ls "${WORK_DIR}"`
			do
				${PROG_NAME} "${file}" | awk ' {print $1"  "$2} ' > "${WORK_DIR}/${file}.md5"
				cat "${WORK_DIR}/${file}.md5"
			done			
			exit 0
		elif [[ -d "${MAIN_COMMAND_PARAM}" ]]; then
			TMP_WORK_DIR="${WORK_DIR}"
			WORK_DIR="${MAIN_COMMAND_PARAM}"
			cd "${WORK_DIR}" 
			for file in `ls .`
			do
				${PROG_NAME} "${file}" | awk ' {print $1"  "$2} ' > "${file}.md5"
				cat "${file}.md5"
			done			
			WORK_DIR="${TMP_WORK_DIR}"
			cd "${WORK_DIR}"			
			exit 0

		else
			echo " ${MAIN_COMMAND_PARAM} is not a directory"
			exit 1
		fi
		exit 0	
	;;

# default action simply create md5 checksum file and add md5 extension to original name.	
	*)
	if [[ -e "${WORK_DIR}/${MAIN_COMMAND}" ]];then
			${PROG_NAME}  "${MAIN_COMMAND}" | awk ' {print $1"  "$2} ' > "${WORK_DIR}/${MAIN_COMMAND}.md5"
			cat "${WORK_DIR}/${MAIN_COMMAND}.md5"
		else
			echo "file ${MAIN_COMMAND} not found"	
		fi	
	;;	
esac	




