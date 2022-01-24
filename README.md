# docker-oracle-for-geodatabase
Create an Esri geodatabase in Docker based on an oracle docker image using PowerShell. The created geodatabases support SQL access using Esri's ST_Geometry SQL functions thanks to the ST_SHAPELIB library included in the created image.

Use the scripts in this repo to create a Docker image, start the oracle database and create the geodatabase. Once you're happy with the result they could be combined into just 3 PowerShell commands to create a running geodatabase in oracle.

## Contents

- A docker file and script to create an image from an oracle image, that includes the shapelib and the exproc.ora file
- PowerShell scripts to create and configure the enterprise geodatabase once the container is up and running
- Example scripts that show how to run the docker container such that the geodatabase and it's content survive container restarts

## Getting Started

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- The [ST_SHAPELIB](https://desktop.arcgis.com/en/arcmap/latest/manage-data/using-sql-with-gdbs/configure-oracle-extproc.htm) (libst_shapelib.so) library from Esri. It is included in ArcGIS Desktop or ArcGIS Server installations.
- An sde authorization file. If ArcGIS Server is installed, the Create-Geodatabase script will grab it from the right place.
- An arcpy / Python 3 installation. If ArcGIS Pro or ArcGIS Server is installed, the Create-Geodatabase script knows how to run the right python environment.

### Build the image

The image contains the oracle database together with the st_shapelib and the extroc.ora file.
First, pull the oracle image of your choice. This improves performance of subsequent steps and allows to test it on its own and work out your preferred setup/startup options. So far we have only tried the ones from the Oracle registry. We like the enterprise edition as shown below. Make sure whatever oracle image you pull works according to the oracle documentation before proceeding.

See https://container-registry.oracle.com/ or https://github.com/oracle/docker-images

```sh
# Run these commands in PowerShell
# Pull the image of your choice from your preferred registry first:
# Note that the enterpise edition requires to login first (see oracle docs) and it's about 8GB:
$oracleImage = "container-registry-zurich.oracle.com/database/enterprise:19.3.0.0"
docker pull $oracleImage

# Clone this repository:
git clone https://github.com/ProSuite/docker-oracle-for-geodatabase.git
cd docker-oracle-for-geodatabase

# This builds the image with name oracle-for-sde. The shapelib is fetched from the ArcGIS Server installation. Change the path if you take it from elsewhere.
.\Build-Image.ps1 `
     $oracleImage `
     "C:\Program Files\ArcGIS\Server\DatabaseSupport\Oracle\Linux64" `
     oracle-for-sde
```

### Run the container

The container can be run using the parameters and variables described in the [oracle registry](https://container-registry.oracle.com/).

If you would like to keep the changes between restarts, map oradata to a directory in the host system. Example:

```sh
# Name of the Docker container:
$container = "egdb-dev"
# Name of the pluggable database in Oracle (define the service name in tnsnames.ora for this PDB)
$pdb = "EGDB"
# The Oracle SID and the PDB
$oracle_sid = "ORCL19EGDB"
$pdb = "EGDB"
# The mapped directory on the host machine that contains the actual datafiles of the DB 
# and ensures that the data is not lost if the container is stopped and restarted:
$ora_data="C:\bin\oracle\oradata"

# This creates the database with a PDB called EGDB and sys password 'system'.
# Data files are in C:\bin\oracle\oradata\ORCL19EGDB (delete them too, if you remove the container!)
# The database's address from the host's perspective is localhost:1521
docker run -d `
    --name ${container} `
    -p 1521:1521 `
    -p 5500:5500 `
    -e ORACLE_PWD=system `
    -e ORACLE_SID=${oracle_sid} `
    -e ORACLE_PDB=${pdb} `
    -v ${ora_data}\${oracle_sid}:/opt/oracle/oradata `
    --restart unless-stopped `
    oracle-for-sde

```

All the parameters and options of the oracle image are still available. For example, you can map a directory on the host system containing some setup scripts if you need to configure the database in a specific way, such as changing initialization parameters or creating extra tablespaces and users. See the oracle documentation for further information.

### Create the Geodatabase

Make sure to add the tnsnames.ora entry that points to the pluggalbe database ($pdb or EGDB in our example):

`EGDB =`
`(DESCRIPTION =`
  `(ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521))`
  `(CONNECT_DATA =`
    `(SERVER = DEDICATED)`
    `(SERVICE_NAME = EGDB)`
  `)`
`)`

Once the database is up and running (it will take a few minutes) the geodatabase can be created. If ArcGIS Server is installed the following statement should work directly. Otherwise review the location of the python installation and the keycodes directory in the Create-Geodatabase script.

```sh
# Check if the database is up and the TNS Names entry of the host's Oracle client works:
sqlplus sys/system@$pdb as sysdba
# Create the enterprise geodatabase (if ArcGIS Server is installed):
.\Create-Geodatabase.ps1 -TnsName $pdb -SysPassword system
# Alternatively, without ArcGIS server installation (but ArcGIS Pro) and the Keycodes file in C:\Temp:
.\Create-Geodatabase.ps1 -TnsName $pdb -SysPassword system -KeycodeFileDir C:\Temp
```

Now the geodatabase is ready and additional data loading scripts could be started. There are some bonus scripts in the arcpy folder that help with setting up test or development content for your database (e.g. data copying or registering datasets as versioned).

## Spatial Type without Geodatabase

In case only the ST_Geometry functions are used and no full geodatabase functionality is required, the following script sets up the spatial type:

```sh
# Check if the database is up and the TNS Names entry of the host's Oracle client works:
sqlplus sys/system@$pdb as sysdba
# Create the enterprise geodatabase (if ArcGIS Server is installed):
.\Create-SpatialType.ps1 -TnsName $pdb -SysPassword system
```

## Contributions and Acknowledgements

A big thanks goes to Daniel Roth who started this initiative and worked through most of the technical challenges!
