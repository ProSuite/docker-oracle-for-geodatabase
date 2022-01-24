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

print('start registering data as versioned in {} ...'.format(ws))

try:
    datasets = arcpy.ListDatasets()
    for ds in datasets:
        path = os.path.join(arcpy.env.workspace, ds)
        print(' register as versioned: {}'.format(ds))
        try:
            arcpy.management.RegisterAsVersioned(os.path.join(ws, ds), 'NO_EDITS_TO_BASE')
        except:
            print(traceback.format_exc())
            # e.g. if there are relationships between feature classes!
            print ('trying one more time...')
            arcpy.management.RegisterAsVersioned(os.path.join(ws, ds), 'NO_EDITS_TO_BASE')

    fcs = arcpy.ListFeatureClasses()
    for fc in fcs:
        path = os.path.join(arcpy.env.workspace, fc)
        print(' register as versioned: {}'.format(fc))
        arcpy.management.RegisterAsVersioned(os.path.join(ws, fc), 'NO_EDITS_TO_BASE')

    tables = arcpy.ListTables()
    for table in tables:
        path = os.path.join(arcpy.env.workspace, table)
        print(' register as versioned: {}'.format(table))
        arcpy.management.RegisterAsVersioned(os.path.join(ws, table), 'NO_EDITS_TO_BASE')

    print('')
    print('finished registering data as versioned')

except:
    print(traceback.format_exc())
    input()

