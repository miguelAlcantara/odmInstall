#!/bin/bash

CURRENT_DIR=`pwd`

. $CURRENT_DIR/tools/lib/odmLib.sh
. $CURRENT_DIR/tools/installODMCluster.properties

sh /tmp/stopServers.sh
cd /opt/IBM/WAS/bin
./manageprofiles.sh -delete -profileName DecisionCenterNode01
./manageprofiles.sh -delete -profileName DmgrProfile

rm -rf /opt/IBM/WAS/profiles/DecisionCenterNode01 /opt/IBM/WAS/profiles/DmgrProfile

executeDBCommandsDB2 $db_username "${db_rootPath}bin/db2 connect to ODMDC; ${db_rootPath}bin/db2 connect reset; ${db_rootPath}bin/db2 drop database ODMDC; ${db_rootPath}bin/db2 connect to ODMDS; ${db_rootPath}bin/db2 connect reset; ${db_rootPath}bin/db2 drop database ODMDS; ${db_rootPath}bin/db2 connect to WBEDB; ${db_rootPath}bin/db2 connect reset; ${db_rootPath}bin/db2 drop database WBEDB;"
#sudo -u $db_username -H sh -c "${db_rootPath}bin/db2 connect to ODMDC; ${db_rootPath}bin/db2 connect reset; ${db_rootPath}bin/db2 drop database ODMDC; ${db_rootPath}bin/db2 connect to ODMDS; ${db_rootPath}bin/db2 connect reset; ${db_rootPath}bin/db2 drop database ODMDS; ${db_rootPath}bin/db2 connect to WBEDB; ${db_rootPath}bin/db2 connect reset; ${db_rootPath}bin/db2 drop database WBEDB;"


