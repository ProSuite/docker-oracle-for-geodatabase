import sys
import traceback
import arcpy

arcpy.env.overwriteOutput = True

try:
    print('Creating sde connection file...')
    out_folder_path = sys.argv[1]
    sde_file_name = sys.argv[2]
    instance = sys.argv[3]
    user = sys.argv[4]
    pw = sys.argv[5]
    print(' \'{0}\\{1}\''.format(out_folder_path, sde_file_name))

    arcpy.CreateDatabaseConnection_management(out_folder_path, sde_file_name, 'ORACLE', instance, 'DATABASE_AUTH', user, pw, 'SAVE_USERNAME')

    print('Sucessfully created SDE connection file \'{0}\\{1}\''.format(out_folder_path, sde_file_name))
except:
    print(traceback.format_exc())
    print('Press enter to exit')
    input()