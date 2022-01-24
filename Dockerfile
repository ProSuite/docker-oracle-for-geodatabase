# syntax=docker/dockerfile:1
ARG oracle_image=container-registry-zurich.oracle.com/database/enterprise
FROM $oracle_image
ARG orahome=/opt/oracle/product/19c/dbhome_1
RUN echo Copying extproc.ora ...
COPY ./extproc.ora $orahome/hs/admin
RUN echo Copying libst_shapelib.so...
COPY ./libst_shapelib.so /opt/oracle/esrilib/
