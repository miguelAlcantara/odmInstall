security = AdminConfig.getid('/Security:/')
print security
print AdminConfig.required('JAASAuthData')

alias = ['alias', 'DB2 Login']
userid = ['userId', 'db2inst1']
password = ['password', 'db2inst1']
jaasAttrs = [alias, userid, password]
print jaasAttrs

print AdminConfig.create('JAASAuthData', security, jaasAttrs)

print AdminConfig.getid('/Node:DecisionCenterNode01/JDBCProvider:DecisionCenter - DB2 Universal JDBC Driver Provider /')

AdminConfig.save()