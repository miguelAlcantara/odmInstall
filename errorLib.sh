#!/bin/bash

CURRENT_DIR=`pwd`

function validateExecution(){

	errorCode=$1
	errorText=$2

	if [ ${errorCode} != 0 ]; then 
		echo "---------------"
		echo "${errorText}"
		read input
		if [ "$input" == "n" ]; then
			exit ${errorCode};
		fi
	fi
	
	return 0;

}