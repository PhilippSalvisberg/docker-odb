#!/bin/bash

mkdirs(){
    mkdir -p ${ORACLE_BASE}/ords/conf
    mkdir -p ${ORACLE_BASE}/ords/logs
}

configure(){
	if [ $MULTITENANT == "true" ]; then
		THE_SERVICE_NAME=$PDB_SERVICE_NAME
	else
		THE_SERVICE_NAME=$SERVICE_NAME
	fi
	cd ${ORACLE_HOME}/ords
	./bin/ords --config ${ORACLE_BASE}/ords/conf config set db.hostname ${HOSTNAME}
	./bin/ords --config ${ORACLE_BASE}/ords/conf config set db.port 1521
	./bin/ords --config ${ORACLE_BASE}/ords/conf config set db.servicename ${THE_SERVICE_NAME}
	./bin/ords --config ${ORACLE_BASE}/ords/conf config set db.username ORDS_PUBLIC_USER
	echo ${PASS} | ./bin/ords --config ${ORACLE_BASE}/ords/conf config secret --password-stdin db.password
	./bin/ords --config ${ORACLE_BASE}/ords/conf config set standalone.http.port 8081
	./bin/ords --config ${ORACLE_BASE}/ords/conf config set standalone.context.path /ords
	./bin/ords --config ${ORACLE_BASE}/ords/conf config set standalone.static.context.path /i
	./bin/ords --config ${ORACLE_BASE}/ords/conf config set standalone.doc.root ${ORACLE_HOME}/ords/docs/javadoc
	# path to images must not contain symbolic links
	./bin/ords --config ${ORACLE_BASE}/ords/conf config set standalone.static.path ${ORACLE_HOME}/apex/images
	./bin/ords --config ${ORACLE_BASE}/ords/conf config set security.verifySSL false
	# to enable SQL Developer Web
	./bin/ords --config ${ORACLE_BASE}/ords/conf config set restEnabledSql.active true
	./bin/ords --config ${ORACLE_BASE}/ords/conf config set database.api.enabled true
	./bin/ords --config ${ORACLE_BASE}/ords/conf config set feature.sdw true
}

install(){
	cd ${ORACLE_HOME}/ords
	./bin/ords --config ${ORACLE_BASE}/ords/conf install \
		--log-folder ${ORACLE_BASE}/ords/logs \
		--admin-user SYS \
		--gateway-mode proxied \
		--gateway-user APEX_PUBLIC_USER \
		--proxy-user \
		--password-stdin <<EOF
${PASS}
${PASS}
EOF
}

create_user_admin(){
	sqlplus -s -l sys/${PASS}@${CONNECT_STRING} AS SYSDBA <<EOF
		BEGIN
		   EXECUTE IMMEDIATE 'DROP USER admin CASCADE';
		EXCEPTION
		   WHEN OTHERS THEN
		      NULL;
		END;
		/
		CREATE USER admin IDENTIFIED BY ${PASS}
		   DEFAULT TABLESPACE users
		   TEMPORARY TABLESPACE temp
		   QUOTA UNLIMITED ON users;
		-- all these roles are required to gain full access to all SQL Developer Web components
		-- see https://docs.oracle.com/en/database/oracle/sql-developer-web/19.4/sdweb/user-management-page.html#GUID-75E439E8-A25B-4E26-821A-2F0F4558AFC4
		GRANT CONNECT, RESOURCE, PDB_DBA, DBA, ORDS_ADMINISTRATOR_ROLE to admin;
EOF
	sqlplus -s -l admin/${PASS}@${CONNECT_STRING} <<EOF
		BEGIN
		   ords.drop_rest_for_schema('ADMIN');
		   ords.enable_schema(
			   p_enabled             => true,
			   p_schema              => 'ADMIN',
			   p_url_mapping_type    => 'BASE_PATH',
			   p_url_mapping_pattern => 'admin',
			   p_auto_rest_auth      => false
		   );
		   COMMIT;
		END;
		/
EOF
}

# main
export JAVA_HOME=/usr/lib/jvm/jre-11-openjdk
mkdirs
configure
install
create_user_admin
