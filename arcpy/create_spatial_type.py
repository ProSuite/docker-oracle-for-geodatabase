import sys
import traceback
import arcpy

# As it has been set up in the image:
shapelib_path = "/opt/oracle/esrilib/libst_shapelib.so"

try:
    print("Creating ST_GEOMETRY spatial type...")
    connection_file = sys.argv[1]
    print('with sys user connection file: \'{}\''.format(connection_file))
    sde_password = sys.argv[2]

    # https://pro.arcgis.com/en/pro-app/2.8/tool-reference/data-management/create-enterprise-geodatabase.htm
    print('...in tablespace SDE_TBS.')
    tablespace = "SDE_TBS"
    arcpy.CreateSpatialType_management(connection_file,sde_password,tablespace,shapelib_path)
    
    print('Sucessfully created ST spatial type')
except:
    print(traceback.format_exc())
    print('Press enter to exit')
    input()
    sys.exit(-1)
