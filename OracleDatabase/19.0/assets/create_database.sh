#!/bin/bash

dbca(){
	if [ $DBEXPRESS == "true" ]; then
		EM_CONFIGURATION=DBEXPRESS
	else
		EM_CONFIGURATION=NONE
	fi
	if [ $MULTITENANT == "true" ]; then
		bash -c "${ORACLE_HOME}/bin/dbca \
			-silent \
			-createDatabase \
			-templateName General_Purpose.dbc \
			-gdbname ${GDBNAME} \
			-sid ${ORACLE_SID} \
            -dbOptions JSERVER:${JSERVER} \
			-createAsContainerDatabase true \
			-numberOfPDBs 1 \
            -pdbOptions JSERVER:${JSERVER} \
			-pdbName ${PDB_SERVICE_NAME} \
			-responseFile NO_VALUE \
			-characterSet ${CHARSET} \
			-totalMemory ${DBCA_TOTAL_MEMORY} \
			-emConfiguration ${EM_CONFIGURATION} \
			-sysPassword ${PASS} \
			-systemPassword ${PASS} \
			-pdbAdminUserName pdbadmin \
			-pdbAdminPassword ${PASS} \
			-initparams _exadata_feature_on=TRUE ; echo $?"
	else
		bash -c "${ORACLE_HOME}/bin/dbca \
			-silent \
			-createDatabase \
			-templateName General_Purpose.dbc \
			-gdbname ${SERVICE_NAME} \
			-sid ${ORACLE_SID} \
            -dbOptions JSERVER:${JSERVER} \
			-responseFile NO_VALUE \
			-characterSet ${CHARSET} \
			-totalMemory $DBCA_TOTAL_MEMORY \
			-emConfiguration ${EM_CONFIGURATION} \
			-sysPassword ${PASS} \
			-systemPassword ${PASS} \
			-initparams _exadata_feature_on=TRUE ; echo $?"
	fi
}

create_directories(){
    mkdir -p /u01/app/oracle/oradata/${ORACLE_SID}
    mkdir -p /u01/app/oracle/admin/${ORACLE_SID}/adump
    if [ $MULTITENANT == "true" ]; then
        mkdir -p /u01/app/oracle/oradata/${ORACLE_SID}/pdbseed
    fi
}

create_spfile() {
    # create pfile
    cat <<EOF >> ${ORACLE_HOME}/dbs/pfile${ORACLE_SID}.ora
_exadata_feature_on=TRUE
audit_file_dest='/u01/app/oracle/admin/${ORACLE_SID}/adump'
audit_trail='db'
compatible='19.0.0'
control_files='/u01/app/oracle/oradata/${ORACLE_SID}/control01.ctl','/u01/app/oracle/oradata/${ORACLE_SID}/control02.ctl'
db_block_size=8192
db_domain='docker'
db_name='odb'
diagnostic_dest='/u01/app/oracle'
dispatchers='(PROTOCOL=TCP) (SERVICE=ODBXDB)'
local_listener='(ADDRESS = (PROTOCOL = TCP)(HOST = odb190)(PORT = 1521))'
nls_language='AMERICAN'
nls_territory='AMERICA'
open_cursors=300
pga_aggregate_target=512m
plsql_optimize_level=1
processes=320
remote_login_passwordfile='EXCLUSIVE'
sga_target=1536m
undo_tablespace='UNDOTBS1'
enable_pluggable_database=${MULTITENANT}
EOF
    # convert pfile to spfile
    echo -e "create spfile from pfile = '${ORACLE_HOME}/dbs/pfile${ORACLE_SID}.ora';" | ${ORACLE_HOME}/bin/sqlplus -s -l / AS SYSDBA
}

mount(){
    echo "startup nomount;" | ${ORACLE_HOME}/bin/sqlplus -s -l / AS SYSDBA
}

create_database(){
    if [ $MULTITENANT == "true" ]; then
        # create CDB - root and seed database
        ${ORACLE_HOME}/bin/sqlplus -s -l / as sysdba <<EOF
create database
    controlfile reuse
    user sys identified by ${PASS}
    user system identified by ${PASS}
    character set ${CHARSET}
    national character set AL16UTF16
    extent management local
    datafile '/u01/app/oracle/oradata/${ORACLE_SID}/system01.dbf' 
        size 500m reuse autoextend on maxsize unlimited
    sysaux datafile '/u01/app/oracle/oradata/${ORACLE_SID}/sysaux01.dbf' 
        size 300m reuse autoextend on maxsize unlimited
    default tablespace users datafile '/u01/app/oracle/oradata/${ORACLE_SID}/users01.dbf' 
        size 50m reuse autoextend on maxsize unlimited
    default temporary tablespace temp tempfile '/u01/app/oracle/oradata/${ORACLE_SID}/temp01.dbf' 
        size 30m reuse
    undo tablespace undotbs1 datafile '/u01/app/oracle/oradata/${ORACLE_SID}/undotbs01.dbf' 
        size 200m reuse autoextend on maxsize unlimited
    enable pluggable database
        seed
        file_name_convert=(
            '/u01/app/oracle/oradata/${ORACLE_SID}/',
            '/u01/app/oracle/oradata/${ORACLE_SID}/pdbseed/'
        )
        system datafiles size 125m autoextend on next 10m maxsize unlimited
        sysaux datafiles size 100m;
EOF
    else
        ${ORACLE_HOME}/bin/sqlplus -s -l / as sysdba <<EOF
create database
    controlfile reuse
    user sys identified by ${PASS}
    user system identified by ${PASS}
    character set ${CHARSET}
    national character set AL16UTF16
    extent management local
    datafile '/u01/app/oracle/oradata/${ORACLE_SID}/system01.dbf' 
        size 500m reuse autoextend on maxsize unlimited
    sysaux datafile '/u01/app/oracle/oradata/${ORACLE_SID}/sysaux01.dbf' 
        size 300m reuse autoextend on maxsize unlimited
    default tablespace users datafile '/u01/app/oracle/oradata/${ORACLE_SID}/users01.dbf' 
        size 50m reuse autoextend on maxsize unlimited
    default temporary tablespace temp tempfile '/u01/app/oracle/oradata/${ORACLE_SID}/temp01.dbf' 
        size 30m reuse
    undo tablespace undotbs1 datafile '/u01/app/oracle/oradata/${ORACLE_SID}/undotbs01.dbf' 
        size 200m reuse autoextend on maxsize unlimited;
EOF
    fi
}

create_password_file(){
    orapwd file=$ORACLE_HOME/dbs/orapw$ORACLE_SID format=12 password=${PASS}
}

create_catalog(){
    export PATH=$ORACLE_HOME/perl/bin:$PATH
    cd
    if [ $MULTITENANT == "true" ]; then
        export CATCDB_SYS_PASSWD=${PASS}
        export CATCDB_SYSTEM_PASSWD=${PASS}
        echo "@?/rdbms/admin/catcdb.sql /tmp create_cdb.log" | ${ORACLE_HOME}/bin/sqlplus -s -l / AS SYSDBA
        $ORACLE_HOME/perl/bin/perl $ORACLE_HOME/rdbms/admin/catctl.pl -d $ORACLE_HOME/rdbms/admin -l /tmp catpcat.sql -c 'CDB$ROOT PDB$SEED'
    else
        $ORACLE_HOME/perl/bin/perl $ORACLE_HOME/rdbms/admin/catctl.pl -d $ORACLE_HOME/rdbms/admin -l /tmp catpcat.sql
    fi
    echo "@?/rdbms/admin/utlrp.sql" | ${ORACLE_HOME}/bin/sqlplus -s -l / AS SYSDBA
    echo "@?/sqlplus/admin/pupbld.sql" | ${ORACLE_HOME}/bin/sqlplus -s -l system/${PASS}
    if [ $JSERVER == "true" ]; then
        $ORACLE_HOME/perl/bin/perl $ORACLE_HOME/rdbms/admin/catcon.pl -l /tmp -b initjvm $ORACLE_HOME/javavm/install/initjvm.sql
    fi
}

create_pdb() {
    if [ $MULTITENANT == "true" ]; then
        ${ORACLE_HOME}/bin/sqlplus -s -l / as sysdba <<EOF
create pluggable database ${PDB_NAME} admin user pdbadmin identified by ${PASS}
    storage unlimited tempfile reuse
    file_name_convert=(
        '/u01/app/oracle/oradata/${ORACLE_SID}/pdbseed/', 
        '/u01/app/oracle/oradata/${ORACLE_SID}/${PDB_NAME}/'
    );
EOF
    fi
}

# run as OS user oracle
if [ $DBCA == "true" ]; then
    # simple, based on template databases, hence not all charactersets are feasible
    dbca
else 
    # smaller steps, more options
    create_directories
    create_spfile
    mount
    create_database
    create_password_file
    create_catalog
    create_pdb
fi
