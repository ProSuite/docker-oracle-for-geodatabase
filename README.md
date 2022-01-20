# docker-oracle-for-geodatabase
Create an Esri geodatabase in Docker based on an oracle docker image using PowerShell.

The created geodatabases support SQL access using Esri's ST_Geometry SQL functions (ST_SHAPELIB library via exproc).

Using Docker for hosting the enterprise geodatabase is very useful in a development environment where a new or predefined state of the geodatabase is important. The main advantages are

- The time-consuming setup of the project database on each developer's machine turns into a few lines of PowerShell code.
- Unit tests can run against a pre-defined image/container that guarantee a stable state of the geodatabase.
- If something goes wrong during the set-up you have not botched your machine and have to set up your environment again. Just delete the container and start afresh. That's the beauty of docker!

