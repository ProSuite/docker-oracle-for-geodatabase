import os
import sys
import traceback
import arcpy
import ast

sde_file_path = sys.argv[1]
sde_file_name = sys.argv[2]
exceptions_list = None

try:
    if len(sys.argv) is 4:
        exceptions_list = str(sys.argv[3])
except:
    print("no exception datasets")

ws = os.path.join(sde_file_path, sde_file_name)

arcpy.env.overwriteOutput = True

print('set workspace: {}'.format(ws))
print('')
arcpy.env.workspace = ws

print('start registering data as versioned in {} ...'.format(ws))

try:
    # handle None
    if exceptions_list is None:
        exceptions_list = []
    else:
        # parse string to list, e.g. "['GENIUSDB_DKM25.DKM25_STATUSGITTER','GENIUSDB_DKM25.GN_BLOCKEINTEILUNG','GENIUSDB_DKM25.LK25_BLATTSCHNITT','GENIUSDB_DKM25.WU_PERIMETER']"
        # To handle this string representation of a list as a script parameter do not use blanks inside the string.
        # Otherwise sys.argv is going to handle the blanks like parameter separation.
        exceptions_list = [n.strip() for n in ast.literal_eval(exceptions_list)]
        print('exceptional datasets {}'.format(exceptions_list))

except:
    print(traceback.format_exc())
    input()

try:
    datasets = arcpy.ListDatasets()
    for ds in datasets:
        if ds in exceptions_list:
            print(' don\'t register as versioned: {}'.format(ds))
            continue
        else:
            print(' register as versioned: {}'.format(ds))
            try:
                arcpy.management.RegisterAsVersioned(os.path.join(ws, ds), 'NO_EDITS_TO_BASE')
            except:
                print(traceback.format_exc())
                # e.g. if there are relationships between feature classes!
                print('trying one more time...')
                arcpy.management.RegisterAsVersioned(os.path.join(ws, ds), 'NO_EDITS_TO_BASE')

    fcs = arcpy.ListFeatureClasses()
    for fc in fcs:
        if fc in exceptions_list:
            print(' don\'t register as versioned: {}'.format(fc))
            continue
        else:
            print(' register as versioned: {}'.format(fc))
            arcpy.management.RegisterAsVersioned(os.path.join(ws, fc), 'NO_EDITS_TO_BASE')

    tables = arcpy.ListTables()
    for table in tables:
        if table in exceptions_list:
            print(' don\'t register as versioned: {}'.format(table))
            continue
        else:
            print(' register as versioned: {}'.format(table))
            arcpy.management.RegisterAsVersioned(os.path.join(ws, table), 'NO_EDITS_TO_BASE')

    print('')
    print('finished registering data as versioned')

except:
    print(traceback.format_exc())
    input()
