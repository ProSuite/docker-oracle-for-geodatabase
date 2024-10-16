#
# Create an enterprise geodatabase from an already running container with open database.
# The sde user's initial password is 'sde'.
#
# Review the location of the python installation and the keycodes directory. If both
# ArcGIS Pro and ArcGIS Server are installed, the default values should work.
# Run this script from its location (i.e. the current directory is where this script is).
# 
# Usage:
# .\Create-Geodatabase.ps1 -TnsName <Service name of host's client> -SysPassword <sys user password> -KeycodeFileDir <directory with Keycodes file>
#
# TnsName: The service name as defined on the host machine's oracle client's tnsnames.ora. Use IP 0.0.0.0 and the container's port.
# SysPassword: The sys user's password of the oracle instance
# KeycodeFileDirectory: # The directory that contains the keycodes file. The default works if ArcGIS Server is installed and licensed.
#
# Example:
# .\Create-Geodatabase.ps1 -TnsName EGDB -SysPassword system
param (
    [string] $TnsName = $(throw "The TNS name is required. Make sure it is in the oracle client's tnsnames.ora"),
    [string] $SysPassword = $(throw "The password of the sys user is required."),
    [string] $KeycodeFileDir = "C:\Program Files\ESRI\License10.8\sysgen"
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
mkdir -Force .\var

# Copy the authorization file from the server installation and rename it by adding .ecp (!)
Copy-Item $KeycodeFileDir\keycodes .\var\keycodes.ecp
$sdeAuthorizationFile = "$(Get-Location)\var\keycodes.ecp"

Write-Output "creating enterprise geodatabase..." | timestamp
Start-Process $python -ArgumentList ".\arcpy\create_egdb.py", $TnsName, $sdeAuthorizationFile, $SysPassword, $sdePassword -Wait

# Some follow-up scripts might require the compress_log table to exist. It is created in the
# first compress
Write-Output "initializing compress table..." | timestamp

$sdeFilesFolder = "$(Get-Location)\var\"
$sdeConnectionFileName = "${TnsName}_sde.sde"
Write-Output "create SDE connection file $sdeConnectionFileName" | timestamp
Start-Process $python -ArgumentList ".\arcpy\create_sde_file.py", $sdeFilesFolder, $sdeConnectionFileName, $TnsName, "sde", $sdePassword -Wait

Write-Output "Compressing $sdeConnectionFileName ..." | timestamp
Start-Process $python -ArgumentList ".\arcpy\compress.py", $sdeFilesFolder, $sdeConnectionFileName -Wait
Write-Output "sucessfully compressed" | timestamp

# Create log directory, if it does not exist
mkdir -Force .\var\logs

# oracle configuration parameters optimized for SDE:
sqlplus sys/${SysPassword}@${TnsName} as sysdba "@.\sql\alter_system_parameters.sql"

# Set up shapelib configuration
Write-Output "configuring shapelib for ST_GEOMETRY..." | timestamp
sqlplus sde/${sdePassword}@${TnsName} "@.\sql\configure_shapelib.sql"

Write-Output "geodatabase setup completed" | timestamp
