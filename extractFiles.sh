#-----------------------------------
#INSTALL IBM ODM APPLICATION + CONFIGURATION FOR FIRST START
#
#BY: Miguel Alcantara
#DATE: 2016/09/20
#-----------------------------------

CURRENT_DIR=`pwd`;

. $CURRENT_DIR/tools/lib/errorLib.sh 
. $CURRENT_DIR/tools/lib/sysLib.sh 
. $CURRENT_DIR/tools/installODMCluster.properties

#Accessing software

if [ -d "$CURRENT_DIR/disk1" && -d "$CURRENT_DIR/disk2" && -d "$CURRENT_DIR/disk3 "]; then
	echo "Installation files already exist. Skipping step.."
else

	#Creating directory to copy the install files to the server
	#mkdir -p /mnt/fileshare
	#mkdir -p $software_folder
	#mount -t cifs //10.10.7.100/files -o username=noahc /mnt/fileshare
	
	#mount -t cifs //$softwareServer_ip/$files_folder -o username=$softwareServer_username $softwareServer_ip

	cd $CURRENT_DIR

	tar xf $software_folder/IBM_ODM_V8.5_LNX_32-64_LAUN_DISK1.tar
	tar xf $software_folder/IBM_ODM_V8.5_LNX_32-64_LAUN_DISK2.tar
	tar xf $software_folder/IBM_ODM_V8.5_LNX_32-64_LAUN_DISK3.tar
	ls

	echo "${was_server_ip} ${was_server_dns}" >> /etc/hosts
	echo "hard nofile 100000" >> /etc/security/limits.conf
	echo "soft nofile 100000" >> /etc/security/limits.conf

	
	#Comment unnecessary lines
	replaceText "com.ibm.cic.common.core.preferences.repositoryLocations.\!WAS_REPOSITORY\!.RepositoryIsOpen=true" "#com.ibm.cic.common.core.preferences.repositoryLocations.\!WAS_REPOSITORY\!.RepositoryIsOpen=true" /var/ibm/InstallationManager/.settings/com.ibm.cic.agent.core.prefs
	replaceText "com.ibm.cic.common.core.preferences.repositoryLocations_1=\!WAS_REPOSITORY\!" "#com.ibm.cic.common.core.preferences.repositoryLocations_1=\!WAS_REPOSITORY\!" /var/ibm/InstallationManager/.settings/com.ibm.cic.agent.core.prefs
	replaceText "!IM_REPOSITORY!" "${CURRENT_DIR}/disk1/IM" ${CURRENT_DIR}/disk1/responsefiles/IM_Silent.xml

	./installc -log $CURRENT_DIR/im-install.log -acceptlicense
	
	#Replace WAS Prerequisites variables for Silent install
	replaceText "!WAS_SDK_FEATURE_BIT_ 32_OR_64!" "com.ibm.sdk.6_64bit" ${CURRENT_DIR}/disk1/responsefiles/Prerequisites_WAS_Silent.xml
	replaceText "!WAS_REPOSITORY!" ${was_home} ${CURRENT_DIR}/disk1/responsefiles/Prerequisites_WAS_Silent.xml
	replaceText "!WAS_PROFILE_ID!" "WAS" ${CURRENT_DIR}/disk1/responsefiles/Prerequisites_WAS_Silent.xml
	replaceText "!BIT_64!" "<data key='user.select.64bit.image,com.ibm.websphere.ND.v85' value='true'/>" ${CURRENT_DIR}/disk1/responsefiles/Prerequisites_WAS_Silent.xml
	
	#Replace eXtreme Scale variables for Silent install
	replaceText "!WXS_REPOSITORY!" ${was_home} ${CURRENT_DIR}/disk1/responsefiles/WXS_Silent.xml
	replaceText "!WXS_PROFILE_ID!" "WAS" ${CURRENT_DIR}/disk1/responsefiles/WXS_Silent.xml
	
	#Replace Operational Decision Manager variables for Silent install
	replaceText "!WODM_PROFILE_ID!" "ODM" ${CURRENT_DIR}/disk1/responsefiles/WODM_Silent.xml
	replaceText "!WODM_HOME!" ${odm_home} ${CURRENT_DIR}/disk1/responsefiles/WODM_Silent.xml
	replaceText "!ADMIN_USERNAME!" ${dmgr_username} ${CURRENT_DIR}/disk1/responsefiles/WODM_Silent.xml
	replaceText "!ADMIN_PASSWORD!" ${dmgr_password} ${CURRENT_DIR}/disk1/responsefiles/WODM_Silent.xml
	replaceText "!EXPRESS_OPTION!" "false" ${CURRENT_DIR}/disk1/responsefiles/WODM_Silent.xml
	replaceText "!WODM_FEATURES_DECISION_CENTER!" "jdk,base,Decision Center,Rule Solutions for Office,com.ibm.wdc.rules.samples.feature,com.ibm.wbdm.dts.tomcat.feature,com.ibm.wbdm.dts.jboss.feature,com.ibm.wbdm.dts.weblogic.feature,com.ibm.wdc.event.widgets.feature"  ${CURRENT_DIR}/disk1/responsefiles/WODM_Silent.xml
	replaceText "!WODM_FEATURES_DECISION_SERVER_RULES!" "com.ibm.wds.jdk.feature,base,com.ibm.wds.updatesites.feature,com.ibm.wds.rules.studio.feature,com.ibm.wds.rules.res.feature,com.ibm.wds.rules.samples.feature,com.ibm.wds.rules.scorecard.feature,com.ibm.wds.rules.res.tomcat.feature,com.ibm.wds.rules.res.jboss.feature,com.ibm.wds.rules.res.weblogic.feature" ${CURRENT_DIR}/disk1/responsefiles/WODM_Silent.xml
	replaceText "!WODM_FEATURES_DECISION_SERVER_EVENTS!" "com.ibm.wds.jdk.feature,base,com.ibm.wds.updatesites.feature,com.ibm.wds.studio.events.feature,com.ibm.wds.events.runtime.feature,com.ibm.wds.events.connectors.feature,com.ibm.wds.events.integration.feature,com.ibm.wds.events.propertiesui.feature,com.ibm.wds.event.widgets.feature,com.ibm.wds.events.tester.feature" ${CURRENT_DIR}/disk1/responsefiles/WODM_Silent.xml
	
	cd /opt/IBM/InstallationManager/eclipse/tools
	./imcl input $CURRENT_DIR/disk1/responsefiles/Prerequisites_WAS_Silent.xml -acceptLicense
	./imcl input $CURRENT_DIR/disk1/responsefiles/WXS_Silent.xml -acceptLicense
	./imcl input $CURRENT_DIR/disk1/responsefiles/WODM_Silent.xml -acceptLicense
	./imcl input $CURRENT_DIR/disk1/responsefiles/OW_Silent.xml -acceptLicense


	cd $CURRENT_DIR
fi

