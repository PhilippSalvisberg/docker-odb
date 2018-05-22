#!/bin/bash

reuse_database(){
	echo "Reuse existing database."
	if grep -q "$ORACLE_SID:" /etc/oratab ; then
		# starting an existing container
		echo "Database already registred in /etc/oratab"
	else
		# new container with an existing volume
		echo "Registering Database in /etc/oratab"
		echo "$ORACLE_SID:$ORACLE_HOME:N" >> /etc/oratab
		extend_profile
		fix_ora_27125_in_dbca
		set_timezone
	fi
	chown oracle:dba /etc/oratab
	chmod 664 /etc/oratab
	provide_data_as_single_volume
	su oracle -l -c "${ORACLE_HOME}/bin/lsnrctl start"
	su oracle -l -c 'echo startup\; | ${ORACLE_HOME}/bin/sqlplus -s -l "/ as sysdba"'
}

link_dir_to_volume(){
	LINK=${1}
	TARGET=${2}
	if  [ -d ${LINK} -a ! -d ${TARGET} ]; then
		echo "Moving original content of ${LINK} to ${TARGET}."
		mkdir -p ${TARGET}
		mv ${LINK}/* ${TARGET} || true
	fi
	rm -rf ${LINK}
	mkdir -p ${TARGET}
	chown -R oracle:dba ${TARGET} 
	echo "Link ${LINK} to ${TARGET}."
	ln -s ${TARGET} ${LINK}
	chown -R oracle:dba ${LINK}
}

provide_data_as_single_volume(){
	echo "Providing persistent data under /u02 to be used as Docker volume."
	link_dir_to_volume "/u01/app/oracle/product/9.2.0/dbhome/dbs" "/u02/app/oracle/product/9.2.0/dbhome/dbs" 
	link_dir_to_volume "/u01/app/oracle/admin" "/u02/app/oracle/admin"
	link_dir_to_volume "/u01/app/oracle/audit" "/u02/app/oracle/audit"
	link_dir_to_volume "/u01/app/oracle/cfgtoollogs" "/u02/app/oracle/cfgtoollogs"
	link_dir_to_volume "/u01/app/oracle/checkpoints" "/u02/app/oracle/checkpoints"
	link_dir_to_volume "/u01/app/oracle/diag" "/u02/app/oracle/diag"
	link_dir_to_volume "/u01/app/oracle/fast_recovery_area" "/u02/app/oracle/fast_recovery_area"
	link_dir_to_volume "/u01/app/oracle/oradata" "/u02/app/oracle/oradata"
	chown -R oracle:dba /u02
}

set_timezone(){
	echo "Change timezone to Central European Time (CET)."
	unlink /etc/localtime
	ln -s /usr/share/zoneinfo/Europe/Zurich /etc/localtime
}

remove_domain_from_resolve_conf(){
	# Workaround to improve startup time of DBCA
	# remove domain entry, see MOS Doc ID 362092.1
	cp /etc/resolv.conf /etc/resolv.conf.ori
	sed 's/domain.*//' /etc/resolv.conf.ori > /etc/resolv.conf
}

fix_ora_27125_in_dbca(){
	mv ${ORACLE_HOME}/bin/oracle ${ORACLE_HOME}/bin/oracle.bin
	cp /assets/oracle ${ORACLE_HOME}/bin/oracle
	chown oracle:oinstall ${ORACLE_HOME}/bin/oracle
	chmod +x ${ORACLE_HOME}/bin/oracle
}

change_passwords(){
	su oracle -l -c 'echo -e "ALTER USER sys IDENTIFIED by ${PASS};\n EXIT" | ${ORACLE_HOME}/bin/sqlplus -s -l "/ as sysdba"'
	su oracle -l -c 'echo -e "ALTER USER system IDENTIFIED by ${PASS};\n EXIT" | ${ORACLE_HOME}/bin/sqlplus -s -l "/ as sysdba"'
	su oracle -l -c 'echo -e "ALTER USER hr IDENTIFIED by hr ACCOUNT UNLOCK;\n EXIT" | ${ORACLE_HOME}/bin/sqlplus -s -l "/ as sysdba"'
	su oracle -l -c 'echo -e "ALTER USER oe IDENTIFIED by oe ACCOUNT UNLOCK;\n EXIT" | ${ORACLE_HOME}/bin/sqlplus -s -l "/ as sysdba"'
	su oracle -l -c 'echo -e "ALTER USER pm IDENTIFIED by pm ACCOUNT UNLOCK;\n EXIT" | ${ORACLE_HOME}/bin/sqlplus -s -l "/ as sysdba"'
	su oracle -l -c 'echo -e "ALTER USER sh IDENTIFIED by sh ACCOUNT UNLOCK;\n EXIT" | ${ORACLE_HOME}/bin/sqlplus -s -l "/ as sysdba"'
}

install_patch(){
	su oracle -l -c 'echo -e "SHUTDOWN IMMEDIATE\nSTARTUP MIGRATE\nEXIT" | ${ORACLE_HOME}/bin/sqlplus -s -l "/ as sysdba"'
	su oracle -l -c 'echo -e "@?/rdbms/admin/catpatch.sql\nEXIT" | ${ORACLE_HOME}/bin/sqlplus -s -l "/ as sysdba"'
	su oracle -l -c 'echo -e "SHUTDOWN IMMEDIATE\nSTARTUP\nEXIT" | ${ORACLE_HOME}/bin/sqlplus -s -l "/ as sysdba"'
}

extend_profile(){
	echo "export GDBNAME=${GDBNAME}" >> /home/oracle/.bash_profile
	echo "export ORACLE_SID=${ORACLE_SID}" >> /home/oracle/.bash_profile
	echo "export SERVICE_NAME=${SERVICE_NAME}" >> /home/oracle/.bash_profile
	echo "export PASS=${PASS}" >> /home/oracle/.bash_profile
}

create_database(){
	echo "Creating database."
	extend_profile
	provide_data_as_single_volume
	remove_domain_from_resolve_conf
	fix_ora_27125_in_dbca
	su oracle -l -c "${ORACLE_HOME}/bin/lsnrctl start"
	# use dbca.headless with "-Djava.awt.headless=true" to make it work without valid DISPLAY variable in silent mode
	su oracle -l -c "/assets/dbca.headless \
		-silent \
		-createDatabase \
		-templateName General_Purpose.dbc \
		-gdbname ${SERVICE_NAME} \
		-sid ${ORACLE_SID} \
		-responseFile NO_VALUE \
		-characterSet AL32UTF8 \
		-listeners LISTENER"
	change_passwords
	install_patch
}

start_database(){
	# Startup database if oradata directory is found otherwise create a database
	if [ -d /u02/app/oracle/oradata ]; then
		reuse_database
	else
		set_timezone
		create_database
	fi

	# Successful installation/startup
	echo ""
	echo "Database ready to use. Enjoy! ;-)"

	# trap interrupt/terminate signal for graceful termination
	trap "su oracle -l -c 'echo Starting graceful shutdown... && echo shutdown immediate\; | ${ORACLE_HOME}/bin/sqlplus -s -l \"/ as sysdba\" && ${ORACLE_HOME}/bin/lsnrctl stop'" INT TERM

	# waiting for termination of tns listener
	PID=`ps -e | grep tnslsnr | awk '{print $1}'`
	while test -d /proc/$PID; do sleep 1; done
	echo "Graceful shutdown completed."
}

# set environment
. /assets/setenv.sh

# Exit script on non-zero command exit status
set -e

case "$1" in
	'')
		# default behaviour when no parameters are passed to the container
		start_database
		;;
	*)
		# use parameters passed to the container
		echo ""
		echo "Overridden default behaviour. Run /assets/entrypoint.sh when ready."
		$@
		;;
esac
