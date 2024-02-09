---
---	Name:		alter_system_parameters.sql
---
---	Purpose:	Alter the configuration parameters for geodatabase usage 
---
--- Run as:		SDE
---	______________________________________________________

SET TERMOUT OFF
SPOOL .\var\logs\alter_system_parameters.log
SET HEADING OFF
SELECT TO_CHAR(SYSDATE, 'fmMonth DD, YYYY') TODAY FROM DUAL;
SET HEADING ON
SET TERMOUT ON

SET SERVEROUTPUT ON

--- see suggestions in https://desktop.arcgis.com/fr/arcmap/latest/extensions/maritime-charting-guide/admin-pl-oracle/creating-and-configuring-the-geodatabase-in-oracle.htm

--- in case we need to use DATAPUMP
alter system set deferred_segment_creation=false scope=both;

--- the default is exceeded even in a single-user system quite easily (requires gdb_util.update_open_cursors to run after the creation of the enterprise GDB)
alter system set open_cursors=2000 scope=both;

--- Important, because we have changed OPEN_CURSORS. See https://desktop.arcgis.com/en/arcmap/latest/manage-data/gdbs-in-oracle/update-open-cursors.htm
--- If this step is skipped, bad things will happen in the future!
GRANT INHERIT PRIVILEGES ON USER SYS TO SDE;
EXECUTE sde.gdb_util.update_open_cursors;
REVOKE INHERIT PRIVILEGES ON USER SYS FROM SDE;

quit
