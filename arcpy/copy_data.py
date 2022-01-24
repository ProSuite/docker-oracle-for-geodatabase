import os
import sys
import traceback
import arcpy

sde_file_path = sys.argv[1]
sde_file_name = sys.argv[2]
source_gdb_path = sys.argv[3]
ws = os.path.join(sde_file_path, sde_file_name)

arcpy.env.overwriteOutput = True

print('set source workspace: {}'.format(source_gdb_path))
print('')
arcpy.env.workspace = source_gdb_path

print('Start copying data to {} ...'.format(ws))

try:
    datasets = arcpy.ListDatasets()
    for ds in datasets:
        source_path = os.path.join(arcpy.env.workspace, ds)
        target_path = os.path.join(ws, ds)

        if arcpy.Exists(target_path):
            print(' skipping feature dataset {0} because it already exists'.format(source_path))
        else:
            print(' copy dataset {0} to {1}'.format(source_path, target_path))
            arcpy.management.Copy(source_path, target_path)

    fcs = arcpy.ListFeatureClasses()
    for fc in fcs:
        source_path = os.path.join(arcpy.env.workspace, fc)
        target_path = os.path.join(ws, fc)

        if arcpy.Exists(target_path):
            print(' skipping feature class {0} because it already exists'.format(source_path))
        else:
            print(' copy feature class {0} to {1}'.format(source_path, target_path))
            arcpy.management.Copy(source_path, target_path)

    tables = arcpy.ListTables()
    for table in tables:
        source_path = os.path.join(arcpy.env.workspace, table)
        target_path = os.path.join(ws, table)

        if arcpy.Exists(target_path):
            print(' skipping table {0} because it already exists'.format(source_path))
        else:
            print(' copy table {0} to {1}'.format(source_path, target_path))
            arcpy.management.Copy(source_path, target_path)

    print('')
    print('Finished copying data')

except:
    print(traceback.format_exc())
    print('Press enter to exit')
    input()
    sys.exit(-1)
