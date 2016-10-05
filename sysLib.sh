#Replaces the text in the given file name
function replaceText(){

	textToSearch=$1
	replaceText=$2
	fileToReplace=$3
	regularExpression="([^,]+)"
	
	findTextInFile "$textToSearch" "$fileToReplace" "$regularExpression"
	
	ret=$?
	
	if [[ $ret != 0 ]]; then
		echo "NOT FOUND, CHANGING"
		sed -i -e 's,'${textToSearch}','${replaceText}',g' ${fileToReplace}
	fi
	
}

#Calculates a timestamp for the current time
function currentTimestamp(){

	DELIMITER=$1
	DATEFORMAT=$2
	
	if [[ -z $DELIMITER ]]; then
		dateTime=`date +"%Y"$DELIMITER"%m"$DELIMITER"%d %H:%M:%S"`
	else
		dateTime=`date +"%Y%m%d%H%M%S"`
	fi
		
	
}

function findTextInFile(){

	textToFind=$1
	searchFile=$2
	regularExpression=$3
	
	if [[ ! -z $regularExpression ]]; then
		textFound=`grep -E -o "${textToFind}${regularExpression}" ${searchFile}`
	else
		textFound=`grep "${textToFind}" ${searchFile}`
	fi
	
}