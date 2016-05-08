FROM sath89/oracle-12c-base

### This image is a build from non automated image cause of no possibility of Oracle 12c instalation in Docker container

ENV WEB_CONSOLE true
ENV DBCA_TOTAL_MEMORY 2048
ENV APEX_VERSION 5.0.3
ENV APEX_PASS Oracle12c!
ENV PASS oracle
ENV PORT 1521
ENV HTTP_PORT 8082

ADD entrypoint.sh /entrypoint.sh
ADD tnsnames.ora /tmp/ 
ADD install_oddgen.sh /install_oddgen.sh
ADD upgrade_apex.sh /upgrade_apex.sh
ADD https://github.com/oracle/db-sample-schemas/archive/master.zip /tmp/db-sample-schemas-master.zip
ADD https://github.com/ftldb/ftldb/releases/download/v1.5.0-rc/ftldb-ora-1.5.0-RC-install-linux.tar.gz /tmp/ftldb.tar.gz
ADD https://raw.githubusercontent.com/osalvador/tePLSQL/master/TE_TEMPLATES.sql /tmp/teplsql/
ADD https://raw.githubusercontent.com/osalvador/tePLSQL/master/tePLSQL.pks /tmp/teplsql/
ADD https://raw.githubusercontent.com/osalvador/tePLSQL/master/tePLSQL.pkb /tmp/teplsql/
ADD https://github.com/oddgen/oddgen/archive/master.zip /tmp/oddgen-master.zip
ADD apex_5.0.3_en.zip /tmp/apex.zip

EXPOSE 1521
EXPOSE 8082
VOLUME ["/u01/app/oracle"]

ENTRYPOINT ["/entrypoint.sh"]
CMD [""]
