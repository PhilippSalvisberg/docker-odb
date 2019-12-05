FROM phsalvisberg/odb:19.0sw

LABEL maintainer="philipp.salvisberg@gmail.com"
LABEL description="Oracle Database Enterprise Edition 19c"
LABEL build.command="docker build . --tag phsalvisberg/odb:19ru"
LABEL run.command="docker run -v odbru:/u02 -it -p 8090-8091:8080-8081 -p 5510:5500 -p 1531:1521 -h odbru --name odbru phsalvisberg/odb:19ru"

# environment variables (defaults for DBCA and entrypoint.sh)
ENV MULTITENANT=false \
    DBEXPRESS=false \
    APEX=false \
    ORDS=false \
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
