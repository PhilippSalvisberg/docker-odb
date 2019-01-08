#!/bin/bash

# add hostname
echo "127.0.0.1 odb.oddgen.org odb" >> /etc/hosts

# download and exract FTLDB software
echo "downloading FTLDB."
wget -q --no-check-certificate https://github.com/ftldb/ftldb/releases/download/v1.5.0/ftldb-ora-1.5.0-install-linux.tar.gz -O /tmp/ftldb.tar.gz
echo "extracting FTLDB."
tar -zxvf /tmp/ftldb.tar.gz -C /opt > /dev/null
rm -f /tmp/ftldb.tar.gz

# download and extract tePLSQL software
mkdir -p /opt/teplsql
echo "downloading tePLSQL."
wget -q --no-check-certificate https://raw.githubusercontent.com/osalvador/tePLSQL/master/TE_TEMPLATES.sql -O /opt/teplsql/TE_TEMPLATES.sql
wget -q --no-check-certificate https://raw.githubusercontent.com/osalvador/tePLSQL/master/tePLSQL.pks -O /opt/teplsql/tePLSQL.pks
wget -q --no-check-certificate https://raw.githubusercontent.com/osalvador/tePLSQL/master/tePLSQL.pkb -O /opt/teplsql/tePLSQL.pkb

# download and extract oddgen software
echo "downloading oddgen."
wget -q --no-check-certificate https://github.com/oddgen/oddgen/archive/master.zip -O /tmp/oddgen-master.zip
echo "extracting oddgen."
unzip /tmp/oddgen-master.zip -d /opt > /dev/null
rm -f /tmp/oddgen-master.zip

# cleanup
rm -r -f /tmp/* 
rm -r -f /var/tmp/* \
