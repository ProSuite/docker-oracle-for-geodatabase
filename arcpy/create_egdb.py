import sys
import traceback
import arcpy

try:
    print("Create enterprise geodatabase:")
    instance = sys.argv[1]
    print(' instance \'{}\''.format(instance))
    authorization = sys.argv[2]
    print(' authorization file \'{}\''.format(authorization))
    sys_password = sys.argv[3]
    sde_password = sys.argv[4]
except:
    print(traceback.format_exc())
    print('Press enter to exit')
    input()
    sys.exit(-1)

try:
    # https://pro.arcgis.com/en/pro-app/2.8/tool-reference/data-management/create-enterprise-geodatabase.htm
    print('creating sde:')
    tablespace = "SDE_TBS"
    arcpy.CreateEnterpriseGeodatabase_management("Oracle",instance,"#","DATABASE_AUTH","sys",sys_password,"SDE_SCHEMA","sde",sde_password,tablespace,authorization)
    
    print('Sucessfully created SDE instance \'{}\''.format(instance))
except:
    print(traceback.format_exc())
    print('Press enter to exit')
    input()
    sys.exit(-1)
    