# Notes

## Esri ST_Shapelib

Get **st_shapelib** from **My Esri:**

- Go to <https://my.esri.com> > Downloads > ArcGIS Pro
- Scroll down to *ArcGIS Pro ST_Geometry Libraries (Oracle)*
- Click Download to get a Zip archive that contains st_shapelib for Windows, Linux, and others
- My Esri often changes, so be prepared to spend some time searching

Open Questions:

- Can download ST_Shapelib for Oracle from My Esri via ArcGIS Pro
  and via ArcGIS Enterprise. Is there any difference?

## Finding ORACLE_HOME in image

```sh
docker image inspect container-registry-zurich.oracle.com/database/enterprise:19.3.0.0 | findstr -i ORACLE_HOME
docker image inspect container-registry-zurich.oracle.com/database/enterprise:19.3.0.0 | grep ORACLE_HOME
```
