#!/bin/bash

CURRENT_DIR=`pwd`;

. $CURRENT_DIR/tools/installODMCluster.properties
. $CURRENT_DIR/tools/lib/odmLib.sh
. $CURRENT_DIR/tools/lib/sysLib.sh

#c - center
#a - all
#s - server
#d - dmgr
#b - events
function usage(){
	echo "Usage: sh installODMCluster.sh -a / -c / -s / -b / -d"
	echo "a - all ( Installs all components => DMGR, Decision Center, Decision Server, Decision Events )"
	echo "c - center ( Installs the Decision Center component ONLY)"
	echo "s - server ( Installs the Decision Server component ONLY)"
	echo "b - events ( Installs the Decision Events component ONLY)"
	echo "d - dmgr ( Installs the Deployment Manager component ONLY)"
}



#Enable Component install flags
while getopts ":a:s:c:d:b" OPTARG; do
  case $OPTARG in
	s)
		INSTALL_DS=1
		;;
	c)
		INSTALL_DC=1
		;;
	d)
		INSTALL_DMGR=1
		;;		
	b)
		INSTALL_WBE=1
		;;
	a)
		INSTALL_DMGR=1
		INSTALL_DC=1
		INSTALL_DS=1
		INSTALL_WBE=1
		;;		
	?)
      echo "Invalid option: -$OPTARG"
	  exit 1;
      ;;
  esac
done

J2C_AUTH=""
currentTime=`date +"%Y%m%d%H%M%S"`

cd ${was_home}/bin
export ODM_HOME=${odm_home}

#Parse db type for WAS config file usage
case $db_type in 
	DB2)	DB_TYPE_MP=DB2_Universal 
			. /home/${db_username}/sqllib/db2profile
			;;
	ORACLE)	DB_TYPE_MP=Oracle 
			;;
	MSSQL)	DB_TYPE_MP=MS_SQL_Server
			;;
	DERBY)	DB_TYPE_MP=Derby_NetworkServer
			;;
	*)		DB_TYPE_MP=
esac

if [[ -z "$DB_TYPE_MP" ]]; then
	echo "---------------"
	echo "DB Type not supported. Specify the database type in the properties file with one of the following values: DB2, ORACLE, MSSQL, DERBY"
	exit 1;
fi

#If DMGR Install flag is enabled, then proceed with the install
if [[ ! -z $INSTALL_DMGR ]]; then
	echo "Creating profile ${dmgr_profileName} .."
	echo "---------------"

	#function createDmgrProfile used in the tools/odmLib.sh file
	createDmgrProfile ${was_home} ${dmgr_profileName} ${dmgr_username} ${dmgr_password} ${DB_TYPE_MP} "DMGR" ${db_username} ${db_password} ${db_rootPath}${db_jdbcPath} ${db_rootPath}${db_jdbcLicensePath} ${db_server} ${db_port}

	echo "---------------"
	echo "Profile ${dmgr_profileName} created."
fi

#If DMGR Install flag is enabled, then proceed with the install
if [[ ! -z $INSTALL_DC ]]; then

	echo "---------------"
	echo "Augmenting profile ${dmgr_profileName} with Decision Center..."

	#function augmentProfile used in the tools/odmLib.sh file
	augmentProfile ${was_home} "${was_home}/profileTemplates/rules/management/dc" ${dmgr_profileName} ${dmgr_username} ${dmgr_password} "ODMDC" ${DB_TYPE_MP} ${db_username} ${db_password} ${db_rootPath}${db_jdbcPath} ${db_rootPath}${db_jdbcLicensePath} ${db_server} ${db_port}

	echo "---------------"
	echo "Profile ${dmgr_profileName} augmented with Decision Center template."
	
	echo "---------------"
	echo "Creating Decision Center database..."
	
	#Execute SQL commands to create database and create the user schema
	#sudo -u ${db_username} -H sh -c "${db_rootPath}bin/db2 CREATE DATABASE ${decisioncenter_db_name}; ${db_rootPath}bin/db2 CONNECT TO ${decisioncenter_db_name}; ${db_rootPath}bin/db2 CREATE SCHEMA ${db_username}; ${db_rootPath}bin/db2 terminate"
	executeDBCommandsDB2 $db_username "${db_rootPath}bin/db2 CREATE DATABASE ${decisioncenter_db_name}; ${db_rootPath}bin/db2 CONNECT TO ${decisioncenter_db_name}; ${db_rootPath}bin/db2 CREATE SCHEMA ${db_username}; ${db_rootPath}bin/db2 terminate"
	echo "---------------"
	echo "Decision Center database created."
		
	#function replaceText to update the values in the configureDCCluster.properties file, which will be used in the next function ( configureDCCluster.sh )
	replaceText "wodm.dcrules.db.jdbcDriverPath=" "wodm.dcrules.db.jdbcDriverPath="${db_rootPath}${db_jdbcPath} ${was_home}/profiles/${dmgr_profileName}/bin/rules/configureDCCluster.properties
	replaceText "wodm.dcrules.db.name=" "wodm.dcrules.db.name="${decisioncenter_db_name} ${was_home}/profiles/${dmgr_profileName}/bin/rules/configureDCCluster.properties
	replaceText "wodm.dcrules.db.hostname=" "wodm.dcrules.db.hostname="${db_server} ${was_home}/profiles/${dmgr_profileName}/bin/rules/configureDCCluster.properties
	replaceText "wodm.dcrules.db.port=" "wodm.dcrules.db.port="${db_port} ${was_home}/profiles/${dmgr_profileName}/bin/rules/configureDCCluster.properties
	replaceText "wodm.dcrules.db.user=" "wodm.dcrules.db.user="${db_username} ${was_home}/profiles/${dmgr_profileName}/bin/rules/configureDCCluster.properties
	replaceText "wodm.dcrules.db.password=" "wodm.dcrules.db.password="${db_password} ${was_home}/profiles/${dmgr_profileName}/bin/rules/configureDCCluster.properties
	
	echo "---------------"
	echo "Configuring Decision Center..."
	
	#function configureDCCluster used in the tools/odmLib.sh file
	configureDCCluster ${was_home} ${dmgr_profileName} ${dmgr_username} ${dmgr_password} "${was_home}/profiles/${dmgr_profileName}/bin/rules/configureDCCluster.properties" ${was_nodeName} "localhost" "8879" "1"

	echo "---------------"
	echo "Decision Center successfully configured."

	echo "---------------"
	echo "Creating J2C Authentication alias in WebSphere application server ( profile = ${dmgr_profileName} ) ..."
	
	#function that will execute the createJ2CAuth python script, to create the login needed to connect to the DB
	executeWsAdminScript ${was_home} ${dmgr_username} ${dmgr_password} "jython" $CURRENT_DIR"/tools/py/createJ2CAuth.py"
	
	J2C_AUTH=1
	echo "---------------"
	echo "J2C Authentication alias successfully created."

	export ANT_HOME=${odm_home}/shared/tools/ant
	export PATH=$PATH":"${odm_home}/shared/tools/ant/bin
	
	echo "---------------"
	echo "Configuring Decision Center databases..."
		
	#function that will call the target gen-create-schema of the teamserver ANT build.xml file, to generate the SQL file needed to create the tables/populate the tables.
	executeODMAntScript ${odm_home} "/teamserver/bin" "gen-create-schema" "-Dserver.url=http://localhost:9080/teamserver -Ddatasourcename=jdbc/ilogDataSource -DextensionModel=${odm_home}/teamserver/bin/defaultExtension.brmx -DextensionData=${odm_home}/teamserver/bin/defaultExtension.brdx -DoutputFile="$CURRENT_DIR"/createSchemaODM.sql"
	#executeODMAntScript ${odm_home} "execute-schema" "-Dserver.url=http://localhost:9080/teamserver -Dfile="$CURRENT_DIR"/createSchemaODM.sql"
	
	#Execute SQL commands to create and populate the tables
	# NOTE 
	# ------------
	# According to the IBM documentation, it is recommended to use the "execute-schema" target to execute the generated SQL script. 
	# But, every time I ran it, I got a rollback exception probably due to timeout. TODO
	# ------------
	executeDBCommandsDB2 $db_username "${db_rootPath}bin/db2 CONNECT TO ${decisioncenter_db_name}; ${db_rootPath}bin/db2 -tvsf ${CURRENT_DIR}/createSchemaODM.sql; ${db_rootPath}bin/db2 terminate"
	#sudo -u ${db_username} -H sh -c "${db_rootPath}bin/db2 CONNECT TO ${decisioncenter_db_name}; ${db_rootPath}bin/db2 -tvsf ${CURRENT_DIR}/createSchemaODM.sql; ${db_rootPath}bin/db2 terminate"
	executeODMAntScript ${odm_home} "/teamserver/bin" "upload-extensions" "-Dserver.url=http://localhost:9080/teamserver -Ddatasourcename=jdbc/ilogDataSource -DextensionModel=${odm_home}/teamserver/bin/defaultExtension.brmx -DextensionData=${odm_home}/teamserver/bin/defaultExtension.brdx"
	#executeODMAntScript ${odm_home} "set-extensions" "-Dserver.url=http://localhost:9080/teamserver -Ddatasourcename=jdbc/ilogDataSource -DextensionModel=${odm_home}/teamserver/bin/defaultExtension.brmx -DextensionData=${odm_home}/teamserver/bin/defaultExtension.brdx"
	
	echo "---------------"
	echo "Decision Center databases successfully configured."
fi

if [[ ! -z $INSTALL_DS ]]; then

	#Stop the running servers to augment the DMGR to include Decision Server
	sh $CURRENT_DIR/tools/runServers.sh -d dCenter
	sh $CURRENT_DIR/tools/runServers.sh -d node
	sh $CURRENT_DIR/tools/runServers.sh -d dmgr
	
	echo "---------------"
	echo "Augmenting profile ${dmgr_profileName} with Decision Server..."

	#function augmentProfile to augment the existing DMGR with the Decision Server
	augmentProfile ${was_home} "${was_home}/profileTemplates/rules/management/ds" ${dmgr_profileName} ${dmgr_username} ${dmgr_password} "ODMDS" ${DB_TYPE_MP} ${db_username} ${db_password} ${db_rootPath}${db_jdbcPath} ${db_rootPath}${db_jdbcLicensePath} ${db_server} ${db_port}
	
	echo "---------------"
	echo "Profile ${dmgr_profileName} augmented with Decision Server template."

	echo "---------------"
	echo "Creating Decision Server database..."
	
	#Execute SQL commands to create the database, the user schema, BUFFERPOOL ( for DB2 only ) and create the tables and populate them.
	#sudo -u $db_username -H sh -c "${db_rootPath}bin/db2 CREATE DATABASE ${decisionserver_db_name}; ${db_rootPath}bin/db2 CONNECT TO ${decisionserver_db_name}; CREATE BUFFERPOOL BP32K SIZE 2000 PAGESIZE 32K; ${db_rootPath}bin/db2 CREATE SCHEMA ${db_username}; ${db_rootPath}bin/db2 -tvsf ${odm_home}/executionserver/databases/repository_db2.sql; ${db_rootPath}bin/db2 -tvsf ${odm_home}/executionserver/databases/trace_db2.sql; ${db_rootPath}bin/db2 -tvsf ${odm_home}/executionserver/databases/xomrepository_db2.sql; ${db_rootPath}bin/db2 terminate"
	executeDBCommandsDB2 $db_username "${db_rootPath}bin/db2 CREATE DATABASE ${decisionserver_db_name}; ${db_rootPath}bin/db2 CONNECT TO ${decisionserver_db_name}; CREATE BUFFERPOOL BP32K SIZE 2000 PAGESIZE 32K; ${db_rootPath}bin/db2 CREATE SCHEMA ${db_username}; ${db_rootPath}bin/db2 -tvsf ${odm_home}/executionserver/databases/repository_db2.sql; ${db_rootPath}bin/db2 -tvsf ${odm_home}/executionserver/databases/trace_db2.sql; ${db_rootPath}bin/db2 -tvsf ${odm_home}/executionserver/databases/xomrepository_db2.sql; ${db_rootPath}bin/db2 terminate"
	
	echo "---------------"
	echo "Decision Server database created."
	
	#Copy the MBean descriptors needed to configure the Decision Server cluster
	mkdir ${was_home}/profiles/${was_nodeName}/lib
	cp ${odm_home}/executionserver/lib/jrules-mbean-descriptors.jar ${was_home}/profiles/${was_nodeName}/lib
 
	#function replaceText to update the values in the configureDCCluster.properties file, which will be used in the next function ( configureDCCluster.sh )
	replaceText "wodm.dsrules.db.jdbcDriverPath=" "wodm.dsrules.db.jdbcDriverPath="${db_rootPath}${db_jdbcPath} ${was_home}/profiles/${dmgr_profileName}/bin/rules/configureDSCluster.properties
	replaceText "wodm.dsrules.db.name=" "wodm.dsrules.db.name="${decisionserver_db_name} ${was_home}/profiles/${dmgr_profileName}/bin/rules/configureDSCluster.properties
	replaceText "wodm.dsrules.db.hostname=" "wodm.dsrules.db.hostname="${db_server} ${was_home}/profiles/${dmgr_profileName}/bin/rules/configureDSCluster.properties
	replaceText "wodm.dsrules.db.port=" "wodm.dsrules.db.port="${db_port} ${was_home}/profiles/${dmgr_profileName}/bin/rules/configureDSCluster.properties
	replaceText "wodm.dsrules.db.user=" "wodm.dsrules.db.user="${db_username} ${was_home}/profiles/${dmgr_profileName}/bin/rules/configureDSCluster.properties
	replaceText "wodm.dsrules.db.password=" "wodm.dsrules.db.password="${db_password} ${was_home}/profiles/${dmgr_profileName}/bin/rules/configureDSCluster.properties
	
	echo "---------------"
	echo "Starting servers.."
	
	#Starting the servers in order to execute the configureDSCluster.sh script, to configure all the components needed to use the Decision Server
	sh $CURRENT_DIR/tools/runServers.sh -u dCenter
	sh $CURRENT_DIR/tools/runServers.sh -u node
	sh $CURRENT_DIR/tools/runServers.sh -u dmgr
	
	echo "---------------"
	echo "Servers started."
	
	#If J2C Authentication alias has already been created, we skip the step to create it
	if [[ -z $J2C_AUTH ]]; then
		echo "---------------"
		echo "J2C Authentication alias already exists in WebSphere application server ( profile = ${dmgr_profileName} ). Skipping step."
	else 
		echo "---------------"
		echo "Creating J2C Authentication alias in WebSphere application server ( profile = ${dmgr_profileName} ) ..."

		executeWsAdminScript ${was_home} ${dmgr_username} ${dmgr_password} "jython" $CURRENT_DIR"/tools/py/createJ2CAuth.py"
		
	fi
	
	echo "---------------"
	echo "Configuring Decision Server..."
	
	#function configureDSCluster used in the tools/odmLib.sh file
	configureDSCluster ${was_home} ${dmgr_profileName} ${dmgr_username} ${dmgr_password} "${was_home}/profiles/${dmgr_profileName}/bin/rules/configureDSCluster.properties" ${was_nodeName} "localhost" "8879" "0"
	
	echo "---------------"
	echo "Decision Server successfully configured."
	
	echo "---------------"
	echo "Editing role mapping for RES ..."
	
	#Python script that will be executed using the wsadmin.sh to configure the role mapping for RES
	executeWsAdminScript ${was_home} ${dmgr_username} ${dmgr_password} "jython" $CURRENT_DIR"/tools/py/mapUsersToRolesRES.py"
	
	echo "---------------"
	echo "Editing successfully done."

fi


if [[ ! -z $INSTALL_WBE ]]; then

	
	echo "---------------"
	echo "Editing setenv files..."
	
	echo "currentTime = "${currentTime}
	
	#Edit the DB and WAS config files to include all the properties needed to configure the WAS server and Database
	editSetEnvDBFiles ${odm_home} $DB_TYPE_MP ${db_server} ${db_port} ${decisionevents_db_name} ${db_rootPath}${db_jdbcPath} ${currentTime}
	editSetEnvWASFiles ${odm_home} ${was_home}/profiles/${dmgr_profileName} ${dmgr_bootstrapAddress} ${dmgr_profileName} ${was_nodeName} "9080" ${dmgr_username} ${dmgr_password} ${was_nodeName}"-"${decisionserver_server_name} ${currentTime}
	#editSetEnvWBEFiles

	echo "---------------"
	echo "setenv files edited."
	
	echo "---------------"
	echo "Augmenting profile ${dmgr_profileName} with Decision Events..."
	
	#Stop all servers to augment the existing profile to include the Decision Events
	sh $CURRENT_DIR/tools/runServers.sh -d all
	#function augmentProfile to augment the existing profile to install the Decision Events components
	echo "augmentProfileWBE ${was_home} ${was_home}/profileTemplates/wbe/managed ${app_profileName} ${dmgr_username} ${dmgr_password} ${decisionevents_db_name} ${DB_TYPE_MP} ${db_username} ${db_password} ${db_rootPath}${db_jdbcPath} ${db_server} ${db_port} ${odm_home}"
	augmentProfileWBE ${was_home} "${was_home}/profileTemplates/wbe/managed" ${app_profileName} ${dmgr_username} ${dmgr_password} ${decisionevents_db_name} ${DB_TYPE_MP} ${db_username} ${db_password} ${db_rootPath}${db_jdbcPath} ${db_server} ${db_port} ${odm_home}
    
	echo "---------------"
	echo "Profile ${dmgr_profileName} augmented with Decision Events template."
	
	#mv ${odm_home}/config/db/setenv.sh.${currentTime}.ori ${odm_home}/config/db/setenv.sh
	#mv ${odm_home}/config/was/setenv.sh.${currentTime}.ori ${odm_home}/config/was/setenv.sh
	
	echo "---------------"
	echo "Creating Decision Events database..."
	
	#Backup the DB2 sql file
	cp ${odm_home}/config/db/db2.sql $CURRENT_DIR/db2.sql
	
	#Execute SQL commands to create the database, the user schema and create the tables and populate them.
	#sudo -u ${db_username} -H sh -c "${db_rootPath}bin/db2 CREATE DATABASE ${decisionevents_db_name}; ${db_rootPath}bin/db2 CONNECT TO ${decisionevents_db_name}; ${db_rootPath}bin/db2 CREATE SCHEMA ${db_username}; ${db_rootPath}bin/db2 -tvsf ${CURRENT_DIR}/db2.sql; ${db_rootPath}bin/db2 terminate"
    executeDBCommandsDB2 $db_username "${db_rootPath}bin/db2 CREATE DATABASE ${decisionevents_db_name}; ${db_rootPath}bin/db2 CONNECT TO ${decisionevents_db_name}; ${db_rootPath}bin/db2 CREATE SCHEMA ${db_username}; ${db_rootPath}bin/db2 -tvsf ${CURRENT_DIR}/db2.sql; ${db_rootPath}bin/db2 terminate"
	
	echo "---------------"
	echo "Decision Events database created."
	
	#echo "---------------"
	#echo "Configuring Decision Events message bus..."
	#
	#sh ${odm_home}/config/was
	#s
	#echo "---------------"
	#echo "Decision Events message bus configured."
fi

echo "---------------"
echo "Restarting servers.."

#Restart all servers so all properties can be correctly taken into account
sh $CURRENT_DIR/tools/runServers.sh -r all