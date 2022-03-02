import os
import sys
import traceback
import arcpy

sde_file_path = sys.argv[1]
sde_file_name = sys.argv[2]
version_name = sys.argv[3]

ws = os.path.join(sde_file_path, sde_file_name)

arcpy.env.overwriteOutput = True

print('set workspace: {}'.format(ws))
print('')
arcpy.env.workspace = ws

print('Creating version {} ...'.format(version_name))

try:
    arcpy.management.CreateVersion(ws, "SDE.DEFAULT", version_name, "PUBLIC")
    print('')
    print('Created version')

except:
    print(traceback.format_exc())
    print('Press enter to exit')
    input()
