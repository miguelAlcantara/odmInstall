while getopts ":r::n::s::" opt; do
  case $opt in
    r)
		case $OPTARG in
			all)
				START_DMGR=1
				STOP_DMGR=1
				START_NODE=1
				STOP_NODE=1
				START_DCENTER=1
				STOP_DCENTER=1
				START_DSERVER=1
				STOP_DSERVER=1
				;;
			dCenter)
				START_DCENTER=1
				STOP_DCENTER=1
				;;
			dServer)
				START_DSERVER=1
				STOP_DSERVER=1
				;;
			nodeagent)
				START_NODE=1
				STOP_NODE=1
				;;
			dmgr)
				START_DMGR=1
				STOP_DMGR=1
				;;
			application)
				START_DCENTER=1
				STOP_DCENTER=1
				START_DSERVER=1
				STOP_DSERVER=1
				;;
		esac
		;;
	u)
		case $OPTARG in
			all)
				START_DMGR=1
				START_NODE=1
				START_DCENTER=1
				START_DSERVER=1
				;;
			dCenter)
				START_DCENTER=1
				;;
			dServer)
				START_DSERVER=1
				;;
			nodeagent)
				START_NODE=1
				;;
			dmgr)
				START_DMGR=1
				;;
			application)
				START_DCENTER=1
				START_DSERVER=1
				;;
		esac
		;;	
	d)
		case $OPTARG in
			all)
				STOP_DMGR=1
				STOP_NODE=1
				STOP_DCENTER=1
				STOP_DSERVER=1
				;;
			dCenter)
				STOP_DCENTER=1
				;;
			dServer)
				STOP_DSERVER=1
				;;
			nodeagent)
				STOP_NODE=1
				;;
			dmgr)
				STOP_DMGR=1
				;;
			application)
				STOP_DCENTER=1
				STOP_DSERVER=1
				;;
		esac
		;;
		;;		
	\?)
      echo "Invalid option: -$OPTARG" >&2
	  exit 1;
      ;;
  esac
done

if [[ -z $STOP_DSERVER ]]; then
	echo "Stopping Decision Server.."
	sh /opt/IBM/WAS/profiles/DecisionCenterNode01/bin/stopServer.sh DecisionCenterNode01-DSServer    -username odmadmin -password odmadmin
	echo "Decision Server stopped."
	echo ""
fi

if [[ -z $STOP_DCENTER ]]; then
	echo "Stopping Decision Center.."
	sh /opt/IBM/WAS/profiles/DecisionCenterNode01/bin/stopServer.sh DecisionCenterNode01-DCServer    -username odmadmin -password odmadmin
	echo "Decision Center stopped."
	echo ""
fi

if [[ -z $STOP_NODE ]]; then
	echo "Stopping nodeagent.."
	sh /opt/IBM/WAS/profiles/DecisionCenterNode01/bin/stopNode.sh                                    -username odmadmin -password odmadmin
	echo "nodeagent stopped."
	echo ""
fi

if [[ -z $STOP_DMGR ]]; then
	echo "Stopping dmgr.."
	sh /opt/IBM/WAS/profiles/DmgrProfile/bin/stopManager.sh -profileName DmgrProfile                 -username odmadmin -password odmadmin
	echo "dmgr stopped."
	echo ""
fi

if [[ -z $START_DSERVER ]]; then
	echo "Starting Decision Server.."
	sh /opt/IBM/WAS/profiles/DecisionCenterNode01/bin/startServer.sh DecisionCenterNode01-DSServer  
	echo "Decision Server started."
	echo ""
fi

if [[ -z $START_DCENTER ]]; then
	echo "Starting Decision Center.."
	sh /opt/IBM/WAS/profiles/DecisionCenterNode01/bin/startServer.sh DecisionCenterNode01-DCServer  
	echo "Decision Center started."
	echo ""
fi

if [[ -z $START_NODE ]]; then
	echo "Starting nodeagent.."
	sh /opt/IBM/WAS/profiles/DecisionCenterNode01/bin/startNode.sh 
	echo "nodeagent started."
	echo ""
fi

if [[ -z $START_DMGR ]]; then
	echo "Starting dmgr.."
	sh /opt/IBM/WAS/profiles/DmgrProfile/bin/startManager.sh -profileName DmgrProfile  
	echo "dmgr started."
	echo ""
fi

