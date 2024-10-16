#
# Build a docker image from a base oracle database image. The created image
# is set up for support of direct SQL access using Esri's ST_GEOMETRY type.
# The Spatial Type still has to be installed and/or the geodatabase must
# be created in the running container. However, the shapelib (libst_shapelib)
# and the appropriate extproc.ora files will be part of the created image.
#
# Run this script from its location (i.e. the current directory is where this script is).
# 
# Usage:
# Build-Image.ps1 OracleDbImage ShapeLibDir OutputImageName
#
# Example (Oracle enterprise edition version 19.3 / shapelib from ArcGIS Server installation):
# Build-Image.ps1 container-registry-zurich.oracle.com/database/enterprise:19.3.0.0 "C:\Program Files\ArcGIS\Server\DatabaseSupport\Oracle\Linux64" oracle-ee-for-sde
#
# Example (Oracle express edition version 18.4 / shapelib from ArcGIS Desktop installation):
# Build-Image.ps1 container-registry.oracle.com/database/express:18.4.0.0 C:\Program Files (x86)\ArcGIS\Desktop10.8\DatabaseSupport\Oracle\Linux64 oracle-xe-for-sde

param (
    $OracleDbImage = "container-registry.oracle.com/database/express:18.4.0.0",
    $ShapelibDir = "C:\Program Files\ArcGIS\Server\DatabaseSupport\Oracle\Linux64",
    $OutputImageName = "oracle-ee-for-sde"
)

# Copy the shape library
cp $ShapelibDir\libst_shapelib.so .

# Rather than duplicating the oracle home for the selected oracle version, grep it from the base image:
$ohome = (docker image inspect $OracleDbImage | findstr -i ORACLE_HOME).Split("=\`"")[2]
echo $ohome

# Now build the image containing the shape lib and the correct extproc.ora
docker build --build-arg oracle_image=$OracleDbImage --build-arg orahome=$ohome -t $OutputImageName . --progress plain
