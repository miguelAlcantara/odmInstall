#!/bin/bash

CURRENT_DIR=`pwd`

. $CURRENT_DIR/tools/lib/errorLib.sh 
. $CURRENT_DIR/tools/lib/sysLib.sh 

#Function that will create the DMGR profile using the manageprofiles.sh provided by IBM
function createDmgrProfile(){

	wasHome=${1}
	profileName=${2}
	adminUserName=${3}
	adminPassword=${4}
	dbName=${5}
	dbType=${6}
	dbUserId=${7}
	dbJDBCClasspath=${8}
	dbJDBCLicenseClasspath=${9}
	dbHostname=${10}
	dbServerPort=${11}

	cd ${wasHome}/bin
	./manageprofiles.sh -create -templatePath "${was_home}/profileTemplates/management" -wasHome "${wasHome}/" -profileName ${profileName} -enableAdminSecurity "true" -adminUserName ${adminUserName} -adminPassword ${adminPassword} -dbType ${dbType} -dbName ${dbName} -dbUserId ${dbUserId} -dbPassword ${dbPassword} -dbJDBCClasspath ${dbJDBCClasspath} -dbJDBCLicenseClasspath ${dbJDBCLicenseClasspath} -dbHostname ${dbHostname} -dbServerPort ${dbServerPort}

	validateExecution $? "Error creating profile "${profileName}". Please check the system logs. Do you wish to skip this step and continue? [y/n]"
	
}

#Function that will augment a profile using the manageprofiles.sh provided by IBM
function augmentProfile(){

	wasHome=${1}
	templatePath=${2}
	profileName=${3}
	adminUserName=${4}
	adminPassword=${5}
	dbName=${6}
	dbType=${7}
	dbUserId=${8}
	dbPassword=${9}
	dbJDBCClasspath=${10}
	dbJDBCLicenseClasspath=${11}
	dbHostname=${12}
	dbServerPort=${13}
	templateType=${14}
	
	params=""
	for var in "$@"
	do
		if [[ -z $var ]]; then
			params=$params" " 
		fi
	done
	
	sh ${wasHome}/bin/manageprofiles.sh -augment -templatePath ${templatePath} -profileName ${profileName} -adminUserName ${adminUserName} -adminPassword ${adminPassword} -dbType ${dbType} -dbName ${dbName} -dbUserId ${dbUserId} -dbPassword ${dbPassword} -dbJDBCClasspath ${dbJDBCClasspath} -dbJDBCLicenseClasspath ${dbJDBCLicenseClasspath} -dbHostname ${dbHostname} -dbServerPort ${dbServerPort}
	
	validateExecution $? "Error augmenting profile "${profileName}". Please check the system logs. Do you wish to skip this step and continue? [y/n]"
	
}

#Function that will a profile with Decision Events, using the manageprofiles.sh provided by IBM
function augmentProfileWBE(){

	wasHome=${1}
	templatePath=${2}
	profileName=${3}
	adminUserName=${4}
	adminPassword=${5}
	dbName=${6}
	dbType=${7}
	dbUserId=${8}
	dbPassword=${9}
	dbJDBCClasspath=${10}
	dbHostname=${11}
	dbServerPort=${12}
	odmHome=${13}
	
	params=""
	for var in "$@"
	do
		echo "var = "$var
	done
	
	#echo "sh ${wasHome}/bin/manageprofiles.sh -augment -templatePath ${templatePath} -profileName ${profileName} -adminUserName ${adminUserName} -adminPassword ${adminPassword} -wbeDbType ${dbType} -wbeDbName ${dbName} -wbeDbUserId ${dbUserId} -wbeDbPassword ${dbPassword} -wbeDbJDBCClasspath ${dbJDBCClasspath} -wbeDbHostname ${dbHostname} -wbeDbServerPort ${dbServerPort} -wbeHome ${odmHome}"
	echo "sh ${wasHome}/bin/manageprofiles.sh -augment -templatePath ${templatePath} -profileName ${profileName}"
	sh ${wasHome}/bin/manageprofiles.sh -augment -templatePath ${templatePath} -profileName ${profileName}
#	-adminUserName ${adminUserName} -adminPassword ${adminPassword} -wbeDbType ${dbType} -wbeDbName ${dbName} -wbeDbUserId ${dbUserId} -wbeDbPassword ${dbPassword} -wbeDbJDBCClasspath ${dbJDBCClasspath} -wbeDbHostname ${dbHostname} -wbeDbServerPort ${dbServerPort} -wbeHome ${odmHome}
	
	validateExecution $? "Error augmenting profile "${profileName}". Please check the system logs. Do you wish to skip this step and continue? [y/n]"
	
}

#Function that configure the Decision Center cluster, using the configureDCCluster.sh provided by the ODM install files
function configureDCCluster(){

	wasHome=$1
	dmgr_profileName=$2
	dmgrAdminUsername=$3
	dmgrAdminPassword=$4
	clusterPropertiesFile=$5
	targetNodeName=$6
	dmgrHostName=$7
	dmgrPort=$8
	createNode=$9

	if [[ $createNode == "1" ]]; then
		sh ${wasHome}/profiles/${dmgr_profileName}/bin/configureDCCluster.sh -dmgrAdminUsername ${dmgrAdminUsername} -dmgrAdminPassword ${dmgrAdminPassword} -clusterPropertiesFile ${clusterPropertiesFile} -createNode -targetNodeName ${targetNodeName} -dmgrHostName ${dmgrHostName} -dmgrPort ${dmgrPort}
	else
		sh ${wasHome}/profiles/${dmgr_profileName}/bin/configureDCCluster.sh -dmgrAdminUsername ${dmgrAdminUsername} -dmgrAdminPassword ${dmgrAdminPassword} -clusterPropertiesFile ${clusterPropertiesFile} -createNode -targetNodeName ${targetNodeName} -dmgrHostName ${dmgrHostName} -dmgrPort ${dmgrPort}
	fi

	validateExecution $? "Error configuring Decision Center. Please check the system logs. Do you wish to skip this step and continue? [y/n]"
	
}

#Function that configure the Decision Server cluster, using the configureDSCluster.sh provided by the ODM install files
function configureDSCluster(){

	wasHome=$1
	dmgr_profileName=$2
	dmgrAdminUsername=$3
	dmgrAdminPassword=$4
	clusterPropertiesFile=$5
	targetNodeName=$6
	dmgrHostName=$7
	dmgrPort=$8
	createNode=$9

	if [[ $createNode == "1" ]]; then
		sh ${wasHome}/profiles/${dmgr_profileName}/bin/configureDSCluster.sh -dmgrAdminUsername ${dmgrAdminUsername} -dmgrAdminPassword ${dmgrAdminPassword} -clusterPropertiesFile ${clusterPropertiesFile} -createNode -targetNodeName ${targetNodeName} -dmgrHostName ${dmgrHostName} -dmgrPort ${dmgrPort}
	else
		sh ${wasHome}/profiles/${dmgr_profileName}/bin/configureDSCluster.sh -dmgrAdminUsername ${dmgrAdminUsername} -dmgrAdminPassword ${dmgrAdminPassword} -clusterPropertiesFile ${clusterPropertiesFile} -targetNodeName ${targetNodeName} -dmgrHostName ${dmgrHostName} -dmgrPort ${dmgrPort}
	fi
	
	validateExecution $? "Error configuring Decision Server. Please check the system logs. Do you wish to skip this step and continue? [y/n]"
	
}

#Function that will execute the wsadmin.sh script provided by IBM, using a Python script
function executeWsAdminScript(){

	wasHome=$1
	username=$2
	password=$3
	lang=$4
	scriptFile=$5

	
	sh ${wasHome}/bin/wsadmin.sh -username ${username} -password ${password} -lang ${lang} -f ${scriptFile}
	
	validateExecution $? "Error executing wsAdmin script "${scriptFile}". Please check the system logs. Do you wish to skip this step and continue? [y/n]"

}

#Function that will run a target from a build.xml file in the folderPath provided
function executeODMAntScript(){

	odmHome=$1
	folderPath=$2
	targetName=$3
	parameters=$4

	export ANT_HOME=${odmHome}/shared/tools/ant
	export PATH=$PATH":"${odmHome}/shared/tools/ant/bin

	cd ${odmHome}${folderPath}
	ant ${targetName} ${parameters}

	validateExecution $? "Error executing ant target "${targetName}". Please check the system logs. Do you wish to skip this step and continue? [y/n]"
}

function executeDBCommandsDB2(){

	db_username=$1
	sqlCommands=$2
	#echo "sudo -u ${db_username} -H sh -c ${sqlCommands}"
	sudo -u $db_username -H sh -c "${sqlCommands}"
	
}

#Function that will map the users to the roles needed in the application
function mapUsersToRoles(){

	executeWsAdminScript ${was_home} ${dmgr_username} ${dmgr_password} "jython" $CURRENT_DIR"/tools/mapUsersToRolesRES.py"
	
}

#Wrapper function that will edit all the setenv.sh files needed to configure WBE ( Business Events )
function editSetEnvFiles(){

	odmHome=$1
	changeDB=$2
	changeWAS=$3
	changeWBE=$4
	currentTime=$5
	
	currentTime=currentTimestamp;
	
	if [[ -z $changeDB ]]; then
		editSetEnvDBFiles $odmHome
	fi
	if [[ -z $changeWAS ]]; then
		editSetEnvWASFiles $odmHome
	fi
	if [[ -z $changeWBE ]]; then
		editSetEnvWBEFiles $odmHome
	fi
}

#Function that will edit the setenv.sh files needed to configure WBE ( Business Events ), specifically for the DB
function editSetEnvDBFiles(){
	odmHome=${1}
	dbType=${2}
	dbHostname=${3}
	dbPort=${4}
	dbName=${5}
	jdbcPath=${6}
	currentTime=${7}
	
	for var in "$@"
	do
		echo "var = "$var
	done
	
	#currentTime=`date +"%Y%m%d%H%M%S"`;
	
	fileName=setenv.sh.${currentTime}.ori
	
	#echo "cp ${odmHome}/config/db/setenv.sh ${odmHome}/config/db/setenv.sh."${currentTime}".ori"
	cp ${odmHome}/config/db/setenv.sh ${odmHome}/config/db/setenv.sh."${currentTime}".ori
	
	
	
	replaceText "DBTYPE=Derby_Embedded" "DBTYPE="$dbType ${odmHome}/config/db/setenv.sh
	replaceText "DBHOST=" "DBHOST="$dbHostname ${odmHome}/config/db/setenv.sh
	replaceText "DBPORT=" "DBPORT="$dbPort ${odmHome}/config/db/setenv.sh
	replaceText "DBNAME=" "DBNAME="$dbName ${odmHome}/config/db/setenv.sh
	replaceText "JDBCDRIVERPATH=" "JDBCDRIVERPATH="$jdbcPath ${odmHome}/config/db/setenv.sh
	
}

#Function that will edit the setenv.sh files needed to configure WBE ( Business Events ), specifically for the WAS
function editSetEnvWASFiles(){

	odmHome=${1}
	dmgrHome=${2}
	bootstrapAddress=${3}
	profileName=${4}
	nodeName=${5}
	wasPort=${6}
	username=${7}
	password=${8}
	serverName=${9}
	currentTime=${10}
	
	#currentTime=`date +"%Y%m%d%H%M%S"`;
	#echo "cp ${odmHome}/config/was/setenv.sh ${odmHome}/config/was/setenv.sh.${currentTime}.ori"
	cp ${odmHome}/config/was/setenv.sh ${odmHome}/config/was/setenv.sh.${currentTime}.ori
	
	replaceText "WASDMGRHOME=" "WASDMGRHOME="$dmgrHome ${odmHome}/config/was/setenv.sh
	replaceText "WASBOOTSTRAPPORT=--BOOTSTRAP_ADDRESS--" "WASBOOTSTRAPPORT="$bootstrapAddress ${odmHome}/config/was/setenv.sh
	replaceText "WASPROFILE=ODMSample8500" "WASPROFILE="$profileName ${odmHome}/config/was/setenv.sh
	replaceText "WASSERVERNODE=" "WASSERVERNODE="$nodeName ${odmHome}/config/was/setenv.sh
	replaceText "WASWCPORT=--WC_defaulthost--" "WASWCPORT="$wasPort ${odmHome}/config/was/setenv.sh
	replaceText "WASUSERNAME=" "WASUSERNAME="$username ${odmHome}/config/was/setenv.sh
	replaceText "WASPASSWORD=" "WASPASSWORD="$password ${odmHome}/config/was/setenv.sh
	replaceText "WASSERVER=SamplesServer" "WASSERVER="$serverName ${odmHome}/config/was/setenv.sh
	
}

#Function that will edit the setenv.sh files needed to configure WBE ( Business Events ), specifically for the WBE
function editSetEnvWBEFiles(){
	
	odmHome=$1
	wbeHome=$2
	
	currentTime=`date +"%Y%m%d%H%M%S"`;
	cp ${odmHome}/config/wbe/setenv.sh $CURRENT_DIR/config/wbe/setenv.sh.$currentTime
	
	replaceText "WASDMGRHOME=" "WASDMGRHOME="$dmgrHome ${odmHome}/config/was/setenv.sh
	replaceText "WASBOOTSTRAPPORT=--BOOTSTRAP_ADDRESS--" "WASBOOTSTRAPPORT="$dmgrHome ${odmHome}/config/was/setenv.sh
	
}