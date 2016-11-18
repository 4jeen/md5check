#!/bin/bash
PROG_NAME=`which md5`
WORK_DIR=`pwd`
if [[ $? -ne 0 ]];then
	PROG_NAME="md5sum"
fi

if [ -z $1 ];then
		echo "USAGE:"
		echo "$0 [-cd] file or directory name"
		echo "-c check file with checksum in md5 file"
		echo "-d create checksum file for every entry in working directory"
		echo "filename - create checksum md5 file"
		exit
fi

case $1 in
	"-c" )
		if [[ -e ${WORK_DIR}/$2.md5 ]];then
			CHECKSUM=`awk '{print($1)}' "${WORK_DIR}/$2.md5"`
			CALCULATED_CHECKSUM=`${PROG_NAME} -r "$2"|awk '{print($1)}'`
			if [[ "${CHECKSUM}" = "${CALCULATED_CHECKSUM}" ]]; then
				#echo $CHECKSUM
				#echo $CALCULATED_CHECKSUM
				echo "$2 OK"
				exit 0
			else
				echo "$2 BROKEN!!!"
				exit 1	
			fi
		else
			echo "check sum file $2 not found"	
		fi
	;;
	"-d" )
		if [ -z "$2" ];then
			for file in `ls "${WORK_DIR}"`
			do
				${PROG_NAME} -r "${file}" | sed 's/ /  /' > "${WORK_DIR}/${file}.md5"
				cat "${WORK_DIR}/${file}.md5"
			done			
			exit 0
		elif [[ -d "$2" ]]; then
			TMP_WORK_DIR="${WORK_DIR}"
			WORK_DIR="$2"
			cd "${WORK_DIR}" 
			for file in `ls .`
			do
				${PROG_NAME} -r "${file}" | sed 's/ /  /' > "${file}.md5"
				cat "${file}.md5"
			done			
			WORK_DIR="${TMP_WORK_DIR}"
			cd "${WORK_DIR}"			
			exit 0

		else
			echo " $2 is not a directory"
			exit 1
		fi
		exit 0	
	;;

# default action simply create md5 checksum file and add md5 extension to original name.	
	*)
	if [[ -e "${WORK_DIR}/$1" ]];then
			${PROG_NAME} -r "$1" | sed 's/ /  /' > "${WORK_DIR}/$1.md5"
			cat "${WORK_DIR}/$1.md5"
		else
			echo "file $1 not found"	
		fi	
	;;	
esac	





