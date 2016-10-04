echo "Stopping Decision Center.."
sh /opt/IBM/WAS/profiles/DecisionCenterNode01/bin/stopServer.sh DecisionCenterNode01-DCServer    -username odmadmin -password odmadmin
echo "Decision Center stopped."
echo ""
echo "Stopping Decision Server.."
sh /opt/IBM/WAS/profiles/DecisionCenterNode01/bin/stopServer.sh DecisionCenterNode01-DSServer    -username odmadmin -password odmadmin
echo "Decision Server stopped."
echo ""
echo "Stopping nodeagent.."
sh /opt/IBM/WAS/profiles/DecisionCenterNode01/bin/stopNode.sh                                    -username odmadmin -password odmadmin
echo "nodeagent stopped."
echo ""
echo "Stopping dmgr.."
sh /opt/IBM/WAS/profiles/DmgrProfile/bin/stopManager.sh -profileName DmgrProfile                 -username odmadmin -password odmadmin
echo "dmgr stopped."
