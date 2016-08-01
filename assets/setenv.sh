#!/bin/bash

# ignore secure linux
setenforce Permissive

# environment variables (not configurable when creating a container)
export ORACLE_HOME=/u01/app/oracle/product/12.1.0.2/dbhome
export ORACLE_BASE=/u01/app/oracle
export TERM=linux

# Prevent owner issues on mounted folders
chown -R oracle:dba /u01/app/oracle
rm -f /u01/app/oracle/product
ln -s /u01/app/oracle-product /u01/app/oracle/product

# Add Oracle to path
export PATH=${ORACLE_HOME}/bin:$PATH
if grep -q "PATH" ~/.bashrc
then
	echo "Found PATH definition in ~/.bashrc"
else
	echo "Extending PATH in ~/.bashrc"
	printf "\nPATH=${PATH}\n" >> ~/.bashrc
fi

# Create tnsnames.ora
if [ -f "${ORACLE_HOME}/network/admin/tnsnames.ora" ]
then
	echo "tnsnames.ora found."
else
	echo "Creating tnsnames.ora" 
	printf "${ORACLE_SID} =\n\
	(DESCRIPTION =\n\
	 (ADDRESS = (PROTOCOL = TCP)(HOST = $(hostname))(PORT = 1521))\n\
	 (CONNECT_DATA = (SERVICE_NAME = ${SERVICE_NAME})))\n" > ${ORACLE_HOME}/network/admin/tnsnames.ora
fi

# Create listener.ora
if [ -f "${ORACLE_HOME}/network/admin/listener.ora" ]
then
	echo "listener.ora found."
else
	echo "Creating listener.ora.ora" 
	printf "LISTENER =\n\
    (DESCRIPTION_LIST =\n\
      (DESCRIPTION =\n\
        (ADDRESS = (PROTOCOL = TCP)(HOST = $(hostname))(PORT = 1521))\n\
        (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))\n\
      )\n\
    )\n" > ${ORACLE_HOME}/network/admin/listener.ora
fi

# fix ownership and access rights
chown oracle:dba ${ORACLE_HOME}/network/admin/tnsnames.ora
chmod 664 ${ORACLE_HOME}/network/admin/tnsnames.ora
chown oracle:dba ${ORACLE_HOME}/network/admin/listener.ora
chmod 664 ${ORACLE_HOME}/network/admin/listener.ora
