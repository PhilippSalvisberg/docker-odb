#!/bin/bash

# ignore secure linux
setenforce Permissive

# Set environment variables
. ~/.bashrc

# Create tnsnames.ora
if [ -f "${ORACLE_HOME}/network/admin/tnsnames.ora" ]
then
	echo "tnsnames.ora found."
else
	echo "Creating tnsnames.ora"
	if [ $MULTITENANT == "true" ]; then
		printf "${ORACLE_SID} =\n\
		(DESCRIPTION =\n\
		 (ADDRESS = (PROTOCOL = TCP)(HOST = $(hostname))(PORT = 1521))\n\
		 (CONNECT_DATA = (SERVICE_NAME = ${GDBNAME})))\n" > ${ORACLE_HOME}/network/admin/tnsnames.ora
		printf "${PDB_NAME} =\n\
		(DESCRIPTION =\n\
		 (ADDRESS = (PROTOCOL = TCP)(HOST = $(hostname))(PORT = 1521))\n\
		 (CONNECT_DATA = (SERVICE_NAME = ${PDB_SERVICE_NAME})))\n" >> ${ORACLE_HOME}/network/admin/tnsnames.ora
	else
		printf "${ORACLE_SID} =\n\
		(DESCRIPTION =\n\
		 (ADDRESS = (PROTOCOL = TCP)(HOST = $(hostname))(PORT = 1521))\n\
		 (CONNECT_DATA = (SERVICE_NAME = ${SERVICE_NAME})))\n" > ${ORACLE_HOME}/network/admin/tnsnames.ora
	fi
fi

# Create listener.ora
if [ -f "${ORACLE_HOME}/network/admin/listener.ora" ]
then
	echo "listener.ora found."
else
	echo "Creating listener.ora"
	printf "LISTENER =\n\
    (DESCRIPTION_LIST =\n\
      (DESCRIPTION =\n\
        (ADDRESS = (PROTOCOL = TCP)(HOST = $(hostname))(PORT = 1521))\n\
        (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))\n\
      )\n\
    )\n" > ${ORACLE_HOME}/network/admin/listener.ora
    if [ $MULTITENANT == "true" ]; then
    	echo "USE_SID_AS_SERVICE_LISTENER=ON" >> ${ORACLE_HOME}/network/admin/listener.ora
    fi
fi

# fix ownership and access rights
chown oracle:dba ${ORACLE_HOME}/network/admin/tnsnames.ora
chmod 664 ${ORACLE_HOME}/network/admin/tnsnames.ora
chown oracle:dba ${ORACLE_HOME}/network/admin/listener.ora
chmod 664 ${ORACLE_HOME}/network/admin/listener.ora
