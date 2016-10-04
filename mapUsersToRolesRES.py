secItem = AdminConfig.list("Security")
aur = AdminConfig.showAttribute(secItem, "activeUserRegistry")
adminID =  AdminConfig.showAttribute(aur ,"primaryAdminId")

AdminApp.edit( "jrules-res-management", ['-MapRolesToUsers', [["resAdministrators", "No", "No", "resAdmin", "resAdministrators"], ["resAdministrators", "No", "No", adminID, "resAdministrators"], ["resDeployers", "No", "No", "resAdmin|resDeployer", "resDeployers"], ["resMonitors", "No", "No", "resAdmin|resDeployer|resMonitor", "resMonitors"]] ]) 
AdminConfig.save()