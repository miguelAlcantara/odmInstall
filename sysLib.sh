#Replaces the text in the given file name
function replaceText(){

	textToSearch=$1
	replaceText=$2
	fileToReplace=$3
	sed -i -e 's,'${textToSearch}','${replaceText}',g' ${fileToReplace}

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