#-----------------------------------
#INSTALL IBM ODM APPLICATION + CONFIGURATION FOR FIRST START
#
#BY: Miguel Alcantara
#DATE: 2016/09/20
#-----------------------------------

#Accessing software

#mkdir -p /mnt/fileshare
mkdir -p $softwareFolder
#mount -t cifs //10.10.7.100/files -o username=noahc /mnt/fileshare
mount -t cifs //$serverIp/$folder -o username=$username /mnt/fileshare


mkdir $installFolder
cd $installFolder
tar xf $softwareFolder/odm/IBM_ODM_V8.5_LNX_32-64_LAUN_DISK1.tar
tar xf $softwareFolder/odm/IBM_ODM_V8.5_LNX_32-64_LAUN_DISK2.tar
tar xf $softwareFolder/odm/IBM_ODM_V8.5_LNX_32-64_LAUN_DISK3.tar
ls




echo "10.10.7.229 odm-linux.corp.coutureconsulting.com" >> /etc/hosts
echo "hard nofile 100000" >> /etc/security/limits.conf
echo "soft nofile 100000" >> /etc/security/limits.conf

./installc -log /$installFolder/odm/im-install.log -acceptlicense

cd /opt/IBM/InstallationManager/eclipse/tools
./imcl input /tmp/odm/disk1/responsefiles/Prerequisites_WAS_Silent.xml -acceptLicense
#com.ibm.cic.common.core.preferences.repositoryLocations.\!WAS_REPOSITORY\!.RepositoryIsOpen=true
#com.ibm.cic.common.core.preferences.repositoryLocations_1=\!WAS_REPOSITORY\!

#Create Decision Center Profile
./manageprofiles.sh -create -templatePath "/opt/IBM/WAS/profileTemplates/rules/default/dc" -dcHome "/opt/IBM/ODM/" -profileName DecisionCenterProfile -enableAdminSecurity "true" -adminUserName odmadmin -adminPassword odmadmin -dbType Derby_Embedded	

#Augment DC profile with RES 
./manageprofiles.sh -augment -templatePath "/opt/IBM/WAS/profileTemplates/rules/default/ds" -dsHome "/opt/IBM/ODM/" -profileName DecisionCenterProfile -enableAdminSecurity "true" -adminUserName odmadmin -adminPassword odmadmin -dbType Derby_Embedded	


#Environment variables needed to run ANT
export ANT_HOME=/opt/IBM/ODM/shared/tools/ant
export PATH=$PATH":"/opt/IBM/ODM/shared/tools/ant/bin

#Start server to execute creation schemas SQL queries
cd /opt/IBM/WAS/bin
./startServer.sh server1


#Create and populate Decision Center schemas
cd /opt/IBM/ODM/teamserver/bin/
ant upload-extensions -Dserver.url=http://localhost:9080/teamserver -Ddatasourcename=jdbc/ilogDataSource -DextensionModel=/opt/IBM/ODM/teamserver/bin/defaultExtension.brmx -DextensionData=/opt/IBM/ODM/teamserver/bin/defaultExtension.brdx
ant gen-create-schema -Dserver.url=http://localhost:9080/teamserver -Ddatasourcename=jdbc/ilogDataSource -DextensionModel=/opt/IBM/ODM/teamserver/bin/defaultExtension.brmx -DextensionData=/opt/IBM/ODM/teamserver/bin/defaultExtension.brdx -DoutputFile=/tmp/createSchemaODM.sql
ant execute-schema -Dserver.url=http://localhost:9080/teamserver -Dfile=/tmp/createSchemaODM.sql



#Environment Variables neede to run ij script
export CLASSPATH=/opt/IBM/WAS/derby/lib/derby.jar":"/opt/IBM/WAS/derby/lib/derbytools.jar

#connect 'jdbc:derby:/opt/IBM/WAS/profiles/DecisionCenterProfile/databases/derby/resdb;user=odmadmin;password=odmadmin';
#connect 'jdbc:derby:/opt/IBM/WAS/profiles/DecisionCenterProfile/databases/derby/resdb;user=derbyadmin;password=derbyadmin';


#sStop Server to execute RES creation schemas SQL queries
cd /opt/IBM/WAS/bin
./stopServer.sh server1 -username odmadmin -password odmadmin

#Create and populate RES repository/Decision Warehouse/XOM Repository schemas
java -Dij.database="jdbc:derby:/opt/IBM/WAS/profiles/DecisionCenterProfile/databases/derby/resdb;user=derbyadmin;password=derbyadmin" -Djdbc.drivers=org.apache.derby.jdbc.EmbeddedDriver org.apache.derby.tools.ij /opt/IBM/ODM/executionserver/databases/repository_derby.sql
java -Dij.database="jdbc:derby:/opt/IBM/WAS/profiles/DecisionCenterProfile/databases/derby/resdb;user=derbyadmin;password=derbyadmin" -Djdbc.drivers=org.apache.derby.jdbc.EmbeddedDriver org.apache.derby.tools.ij /opt/IBM/ODM/executionserver/databases/trace_derby.sql
java -Dij.database="jdbc:derby:/opt/IBM/WAS/profiles/DecisionCenterProfile/databases/derby/resdb;user=derbyadmin;password=derbyadmin" -Djdbc.drivers=org.apache.derby.jdbc.EmbeddedDriver org.apache.derby.tools.ij /opt/IBM/ODM/executionserver/databases/xomrepository_derby.sql

#start server
cd /opt/IBM/WAS/bin
./startServer.sh server1
