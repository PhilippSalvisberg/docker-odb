FROM sath89/oracle-12c-base

ENV WEB_CONSOLE true
ENV DBCA_TOTAL_MEMORY 2048
ENV ORACLE_SID=xe
ENV SERVICE_NAME=xe.oracle.docker
ENV APEX_PASS Oracle12c!
ENV PASS oracle

# Oracle sample schema
ADD https://github.com/oracle/db-sample-schemas/archive/master.zip /tmp/db-sample-schemas-master.zip
RUN /bin/bash -c 'rm -rf /u01/app/oracle-product/12.1.0/xe/demo/schema; \
/u01/app/oracle-product/12.1.0/xe/bin/unzip /tmp/db-sample-schemas-master.zip -d /u01/app/oracle-product/12.1.0/xe/demo/ > /dev/null; \
mv /u01/app/oracle-product/12.1.0/xe/demo/db-sample-schemas-master /u01/app/oracle-product/12.1.0/xe/demo/schema; \
cd /u01/app/oracle-product/12.1.0/xe/demo/schema; \
perl -p -i.bak -e 's#__SUB__CWD__#'$(pwd)'#g' *.sql */*.sql */*.dat > /dev/null; \
chown oracle:dba /u01/app/oracle-product/12.1.0/xe//demo/schema; \
rm /tmp/db-sample-schemas-master.zip'

# FTLDB
ADD https://github.com/ftldb/ftldb/releases/download/v1.5.0-rc/ftldb-ora-1.5.0-RC-install-linux.tar.gz /tmp/ftldb.tar.gz
RUN /bin/bash -c 'tar -zxvf /tmp/ftldb.tar.gz -C /opt > /dev/null; \
rm /tmp/ftldb.tar.gz'

# tePLSQL
ADD https://raw.githubusercontent.com/osalvador/tePLSQL/master/TE_TEMPLATES.sql /opt/teplsql/
ADD https://raw.githubusercontent.com/osalvador/tePLSQL/master/tePLSQL.pks /opt/teplsql/
ADD https://raw.githubusercontent.com/osalvador/tePLSQL/master/tePLSQL.pkb /opt/teplsql/

# oddgen
ADD https://github.com/oddgen/oddgen/archive/master.zip /tmp/oddgen-master.zip
RUN /bin/bash -c 'cd /tmp; \
/u01/app/oracle-product/12.1.0/xe/bin/unzip oddgen-master.zip -d /opt > /dev/null; \
rm /tmp/oddgen-master.zip'

# APEX
ADD assets/apex_5.0.3_en.zip /tmp/apex.zip
RUN /bin/bash -c 'rm -rf /u01/app/oracle-product/12.1.0/xe/demo/apes; \
/u01/app/oracle-product/12.1.0/xe/bin/unzip -o /tmp/apex.zip -d /u01/app/oracle-product/12.1.0/xe > /dev/null; \
chown oracle:dba /u01/app/oracle-product/12.1.0/xe/apex; \
rm /tmp/apex.zip'

ADD assets/install* /
ADD assets/upgrade_apex.sh /
ADD assets/entrypoint.sh /

EXPOSE 1521
EXPOSE 8082

VOLUME ["/u01/app/oracle"]

ENTRYPOINT ["/entrypoint.sh"]
CMD [""]
