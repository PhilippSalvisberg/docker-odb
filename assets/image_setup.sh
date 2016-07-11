#!/bin/bash

# ignore secure linux
setenforce Permissive

# create oracle groups
groupadd --gid 54321 oinstall
groupadd --gid 54322 dba
groupadd --gid 54323 oper

# create oracle user
useradd --create-home --gid oinstall --groups oinstall,dba --uid 54321 oracle

# add hostname
echo "127.0.0.1 odb.oddgen.org odb" >> /etc/hosts

# environment variables (not configurable when creating a container)
echo "export ORACLE_HOME=/u01/app/oracle/product/12.1.0.2/dbhome" > /.oracle_env
echo "export ORACLE_BASE=/u01/app/oracle" >> /.oracle_env
echo "export PATH=/usr/sbin:\$PATH" >> /.oracle_env
echo "export PATH=\$ORACLE_HOME/bin:\$PATH" >> /.oracle_env
echo "export LD_LIBRARY_PATH=\$ORACLE_HOME/lib:/lib:/usr/lib" >> /.oracle_env
echo "export CLASSPATH=\$ORACLE_HOME/jlib:\$ORACLE_HOME/rdbms/jlib" >> /.oracle_env
echo "export TMP=/tmp" >> /.oracle_env
echo "export TMPDIR=\$TMP" >> /.oracle_env
chmod +x /.oracle_env

# set environment
. /.oracle_env
cat /.oracle_env >> /home/oracle/.bash_profile
cat /.oracle_env >> /root/.bash_profile

# install required OS components
yum install -y oracle-rdbms-server-12cR1-preinstall \
               perl \
               tar \
               unzip \
               wget

# create directories and separate /u01/app/oracle/product to mount ${ORACLE_BASE} as volume
mkdir -p /u01/app/oracle
mkdir -p /u01/app/oracle-product 
mkdir -p /u01/app/oraInventory
mkdir -p /tmp/oracle
chown -R oracle:oinstall /u01
chown -R oracle:oinstall /tmp/oracle
ln -s /u01/app/oracle-product /u01/app/oracle/product

# install gosu as workaround for su problems (see http://grokbase.com/t/gg/docker-user/162h4pekwa/docker-su-oracle-su-cannot-open-session-permission-denied)
wget -q --no-check-certificate "https://github.com/tianon/gosu/releases/download/1.9/gosu-amd64"  -O /usr/local/bin/gosu
chmod +x /usr/local/bin/gosu

# download and extract Oracle database software
cd /tmp/oracle
echo "downloading Oracle database software..."
wget -q --no-check-certificate https://www.salvis.com/oracle-assets/p21419221_121020_Linux-x86-64_1of10.zip -O /tmp/oracle/db1.zip
wget -q --no-check-certificate https://www.salvis.com/oracle-assets/p21419221_121020_Linux-x86-64_2of10.zip -O /tmp/oracle/db2.zip
chown oracle:oinstall /tmp/oracle/db1.zip
chown oracle:oinstall /tmp/oracle/db2.zip
echo "extracting Oracle database software..."
gosu oracle bash -c "unzip -o /tmp/oracle/db1.zip -d /tmp/oracle/" > /dev/null
gosu oracle bash -c "unzip -o /tmp/oracle/db2.zip -d /tmp/oracle/" > /dev/null
rm -f /tmp/oracle/db1.zip
rm -f /tmp/oracle/db2.zip

# install Oracle software into ${ORACLE_BASE}
chown oracle:oinstall /assets/db_install.rsp
echo "running Oracle installer to install database software only..."
gosu oracle bash -c "/tmp/oracle/database/runInstaller -silent -force -waitforcompletion -responsefile /assets/db_install.rsp -ignoresysprereqs -ignoreprereq"

# Run Oracle root scripts
echo "running Oracle root scripts..."
/u01/app/oraInventory/orainstRoot.sh > /dev/null 2>&1
echo | ${ORACLE_HOME}/root.sh > /dev/null 2>&1 || true

# download and extract Oracle sample schemas
echo "downloading Oracle sample schemas..."
wget -q --no-check-certificate https://github.com/oracle/db-sample-schemas/archive/master.zip -O /tmp/db-sample-schemas-master.zip
rm -r -f ${ORACLE_HOME}/demo/schema
echo "extracting Oracle sample schemas..."
unzip /tmp/db-sample-schemas-master.zip -d ${ORACLE_HOME}/demo/ > /dev/null
mv ${ORACLE_HOME}/demo/db-sample-schemas-master ${ORACLE_HOME}/demo/schema
cd ${ORACLE_HOME}/demo/schema
perl -p -i.bak -e 's#__SUB__CWD__#'$(pwd)'#g' *.sql */*.sql */*.dat > /dev/null
chown oracle:oinstall ${ORACLE_HOME}/demo/schema
rm -f /tmp/db-sample-schemas-master.zip

# download and exract FTLDB software
echo "downloading FTLDB..."
wget -q --no-check-certificate https://github.com/ftldb/ftldb/releases/download/v1.5.0-rc/ftldb-ora-1.5.0-RC-install-linux.tar.gz -O /tmp/ftldb.tar.gz
echo "extracting FTLDB..."
tar -zxvf /tmp/ftldb.tar.gz -C /opt > /dev/null
rm -f /tmp/ftldb.tar.gz

# download and extract tePLSQL software
mkdir -p /opt/teplsql
echo "downloading tePLSQL..."
wget -q --no-check-certificate https://raw.githubusercontent.com/osalvador/tePLSQL/master/TE_TEMPLATES.sql -O /opt/teplsql/TE_TEMPLATES.sql
wget -q --no-check-certificate https://raw.githubusercontent.com/osalvador/tePLSQL/master/tePLSQL.pks -O /opt/teplsql/tePLSQL.pks
wget -q --no-check-certificate https://raw.githubusercontent.com/osalvador/tePLSQL/master/tePLSQL.pkb -O /opt/teplsql/tePLSQL.pkb

# download and extract oddgen software
echo "downloading oddgen..."
wget -q --no-check-certificate https://github.com/oddgen/oddgen/archive/master.zip -O /tmp/oddgen-master.zip
echo "extracting oddgen..."
unzip /tmp/oddgen-master.zip -d /opt > /dev/null
rm -f /tmp/oddgen-master.zip

# download and extract APEX software
echo "downloading APEX..."
wget -q --no-check-certificate https://www.salvis.com/oracle-assets/apex_5.0.3_en.zip -O /tmp/apex.zip
rm -r -f ${ORACLE_HOME}/demo/apex
echo "extracting APEX..."
unzip -o /tmp/apex.zip -d ${ORACLE_HOME} > /dev/null
chown oracle:oinstall ${ORACLE_HOME}/apex
rm -f /tmp/apex.zip

# cleanup
rm -r -f /tmp/* 
rm -r -f /var/tmp/* \
