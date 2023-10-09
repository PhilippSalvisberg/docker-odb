FROM phsalvisberg/odb:19.0sw-arm

LABEL maintainer="philipp.salvisberg@gmail.com"
LABEL description="Oracle Database Enterprise Edition 19c (ARM)"
LABEL build.command="docker build . --platform linux/arm64 --progress plain --tag phsalvisberg/odb:19.0-arm"
LABEL run.command="docker run -v odb:/u02 -it -p 8080-8081:8080-8081 -p 5500:5500 -p 1521:1521 -h odb --name odb phsalvisberg/odb:19.0-arm"
LABEL run.minimal.command="docker run -e MULTITENANT=false -e DBCA=true -e CHARSET=AL32UTF8 -e JSERVER=false -e DBEXPRESS=false -e APEX=false -e ORDS=false -e FTLDB=false -e TEPLSQL=false -e ODDGEN=false -e SCOTT=false -e SAMPLE_SCHEMAS=false -v odb:/u02 -it -p 8080-8081:8080-8081 -p 5500:5500 -p 1521:1521 -h odb --name odb phsalvisberg/odb:19.0-arm"

# environment variables (defaults for entrypoint.sh)
ENV MULTITENANT=false \
    DBCA=true \
    CHARSET=AL32UTF8 \
    JSERVER=true \
    DBEXPRESS=true \
    APEX=true \
    ORDS=true \
    FTLDB=true \
    TEPLSQL=true \
    ODDGEN=true \
    SCOTT=true \
    SAMPLE_SCHEMAS=true \
    DBCA_TOTAL_MEMORY=2048 \
    GDBNAME=odb.docker \
    ORACLE_SID=ODB \
    SERVICE_NAME=odb.docker \
    PDB_NAME=opdb1 \
    PDB_SERVICE_NAME=opdb1.docker \
    PASS=oracle \
    APEX_PASS=Oracle12c!

# copy all scripts
ADD assets /assets/

# image setup via shell script to reduce layers and optimize final disk usage
RUN /assets/image_setup.sh

# database port, Enterprise Manager Database Express port, ORDS port
EXPOSE 1521 8080 8081 5500

# all data directories in /u01 are linked to this volume
VOLUME ["/u02"]

# entrypoint for database creation, startup and graceful shutdown
ENTRYPOINT ["/assets/entrypoint.sh"]
CMD [""]
