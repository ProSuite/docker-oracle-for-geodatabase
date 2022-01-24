---
---	Name:		configure_shapelib.sql
---
---	Purpose:	Configures the shapelib for SQL access 
---
--- Run as:		SDE
---	______________________________________________________

SET TERMOUT OFF
SPOOL .\var\logs\configure_shapelib.log
SET HEADING OFF
SELECT TO_CHAR(SYSDATE, 'fmMonth DD, YYYY') TODAY FROM DUAL;
SET HEADING ON
SET TERMOUT ON

SET SERVEROUTPUT ON

CREATE or REPLACE LIBRARY ST_SHAPELIB AS '/opt/oracle/esrilib/libst_shapelib.so';
/

ALTER PACKAGE sde.st_geometry_shapelib_pkg COMPILE REUSE SETTINGS;

quit
