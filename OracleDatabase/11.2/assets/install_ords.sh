#!/bin/bash

mkdirs(){
    mkdir -p ${ORACLE_BASE}/ords/params
    mkdir -p ${ORACLE_BASE}/ords/conf
    mkdir -p ${ORACLE_BASE}/ords/logs
}

set_params(){
	THE_SERVICE_NAME=$SERVICE_NAME
	cat >${ORACLE_BASE}/ords/params/ords_params.properties <<EOF
config.dir=${ORACLE_BASE}/ords/conf
db.hostname=${HOSTNAME}
db.port=1521
db.servicename=${THE_SERVICE_NAME}
db.username=APEX_PUBLIC_USER
db.password=${PASS}
migrate.apex.rest=false
plsql.gateway.add=true
rest.services.apex.add=true
rest.services.ords.add=true
schema.tablespace.default=SYSAUX
schema.tablespace.temp=TEMP
standalone.mode=false
standalone.use.https=false
standalone.http.port=8081
standalone.access.log=${ORACLE_BASE}/ords/logs
standalone.context.path=/ords
standalone.doc.root=${ORACLE_HOME}/ords/docs/javadoc
standalone.scheme.do.not.prompt=true
standalone.static.context.path=/i
standalone.static.do.not.prompt=true
# path to images must not contain symbolic links
standalone.static.images=${ORACLE_HOME}/apex/images
user.apex.listener.password=${PASS}
user.apex.restpublic.password=${PASS}
user.public.password=${PASS}
user.tablespace.default=SYSAUX
user.tablespace.temp=TEMP
sys.user=SYS
sys.password=${PASS}
EOF
}

install(){
	cd ${ORACLE_HOME}/ords
	java -jar ords.war configdir ${ORACLE_BASE}/ords/conf
	java -jar ords.war install \
		--parameterFile ${ORACLE_BASE}/ords/params/ords_params.properties \
		--logDir ${ORACLE_BASE}/ords/logs simple
}

# main
mkdirs
set_params
install
