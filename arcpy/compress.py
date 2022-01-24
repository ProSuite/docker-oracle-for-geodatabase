import os
import sys
import traceback
import arcpy

sde_file_path = sys.argv[1]
sde_file_name = sys.argv[2]

ws = os.path.join(sde_file_path, sde_file_name)

arcpy.env.overwriteOutput = True

print('set workspace: {}'.format(ws))
print('')
arcpy.env.workspace = ws

print('Compressing {} ...'.format(ws))

try:
    arcpy.management.Compress(ws)
    print('')
    print('Finished compress')

except:
    print(traceback.format_exc())
    print('Press enter to exit')
    input()
