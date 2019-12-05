#!/bin/bash

# create directories
mkdir -p /u01/app/oracle/oradata/ODB
mkdir -p /u01/app/oracle/admin/odb/adump

# create database
${ORACLE_HOME}/bin/sqlplus -s -l / as sysdba <<EOF
create spfile from pfile = '/assets/initodb.ora';
startup nomount;
create database
    user sys identified by ${PASS}
    user system identified by ${PASS}
    character set CL8ISO8859P5
    national character set AL16UTF16
    extent management local
    datafile '/u01/app/oracle/oradata/ODB/system01.dbf' 
        size 400m reuse autoextend on maxsize unlimited
    sysaux datafile '/u01/app/oracle/oradata/ODB/sysaux01.dbf' 
        size 400m reuse autoextend on maxsize unlimited
    default tablespace users datafile '/u01/app/oracle/oradata/ODB/users01.dbf' 
        size 50m reuse autoextend on maxsize unlimited
    default temporary tablespace temp tempfile '/u01/app/oracle/oradata/ODB/temp01.dbf' 
        size 30m reuse
    undo tablespace undotbs datafile '/u01/app/oracle/oradata/ODB/undotbs01.dbf' 
        size 200m reuse autoextend on maxsize unlimited
;
@?/rdbms/admin/catalog.sql
@?/rdbms/admin/catproc.sql
@?/rdbms/admin/utlrp.sql
@?/sqlplus/admin/pupbld.sql
@?/javavm/install/initjvm.sql
exit
EOF

# create password file
orapwd file=$ORACLE_HOME/dbs/orapw$ORACLE_SID format=12 password=${PASS}
