#
# Create the ST_GEOMETRY spatial type in a already running container with open database.
# The sde user's initial password is 'sde'.
#
# Review the location of the python installation. If ArcGIS Pro is installed, the default 
# values should work.
# Run this script from its location (i.e. the current directory is where this script is).
# 
# Usage:
# Create-SpatialType.ps1 TnsName SysPassword
#
# Make sure the oracle client's tnsnames.ora contains the specified entry for IP 0.0.0.0 and the container's port.
#
# Example:
# Create-SpatialType.ps1 EGDB sysPa$$word

param (
    $TnsName =  $(throw "The TNS name is required. Make sure it is in the oracle client's tnsnames.ora"),
	$SysPassword = "The password of the sys user is required."
)

# The sde user's initial password:
$sdePassword = "sde"

filter timestamp {"$(Get-Date -Format "dd.MM.yyyy HH:mm:ss"): $_"}

# Identify arcpy installation:
# Usig arcpy from the ArcGIS Pro installation:
# https://pro.arcgis.com/en/pro-app/latest/arcpy/get-started/using-conda-with-arcgis-pro.htm
$python = "C:\Progra~1\ArcGIS\Pro\bin\Python\scripts\propy.bat"

if (Test-Path -Path $python -PathType Leaf) {
    Write-Output "Using Python from $python" | timestamp
}
else {
    # No Pro installation - try server
    $python = "C:\Progra~1\ArcGIS\Server\framework\runtime\ArcGIS\bin\Python\Scripts\propy.bat"

    if (Test-Path -Path $python -PathType Leaf) {
        Write-Output "Using Python from $python" | timestamp
    }
    else {
        # Still not found -> No Python 3 installation at all -> throw
        throw "The Python path is not defined. Either ArcGIS server or ArcGIS Pro should be installed."
    }
}

# Create var directory, if it does not exist
md -Force .\var

$sdeFilesFolder = "$(Get-Location)\var\"
$sdeConnectionFileName = "${TnsName}_sys.sde"
Write-Output "create SDE connection file $sdeConnectionFileName" | timestamp
Start-Process $python -ArgumentList ".\arcpy\create_sde_file.py", $sdeFilesFolder, $sdeConnectionFileName, $TnsName, "sys", $SysPassword -Wait

$sdeFilePath = "${sdeFilesFolder}\${sdeConnectionFileName}"

Write-Output "creating spatial type..." | timestamp
Start-Process $python -ArgumentList ".\arcpy\create_spatial_type.py", $sdeFilePath, $sdePassword -Wait

# Create log directory, if it does not exist
md -Force .\var\logs

# oracle configuration parameters optimized for SDE:
sqlplus sys/${SysPassword}@${TnsName} as sysdba "@.\sql\alter_system_parameters.sql"

# Set up shapelib configuration
Write-Output "configuring shapelib for ST_GEOMETRY..." | timestamp
sqlplus sde/${sdePassword}@${TnsName} "@.\sql\configure_shapelib.sql"

Write-Output "spatial type setup completed" | timestamp
