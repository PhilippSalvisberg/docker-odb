FROM phsalvisberg/odb:12.1sw

LABEL maintainer="philipp.salvisberg@gmail.com"
LABEL description="Oracle Database Enterprise Edition 12.1"
LABEL build.command="docker build . --tag phsalvisberg/odb:12.1ru"
LABEL run.command="docker run -v odbru2:/u02 -it -p 8090-8091:8080-8081 -p 1531:1521 -h odb --name odbru2 phsalvisberg/odb:12.1ru"


# environment variables (defaults for DBCA and entrypoint.sh)
ENV MULTITENANT=false \
    DBEXPRESS=false \
    APEX=false \
    ORDS=false \
    DBCA_TOTAL_MEMORY=2048 \
    GDBNAME=odb.docker \
    ORACLE_SID=odb \
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
EXPOSE 1521 8080 8081

# all data directories in /u01 are linked to this volume
VOLUME ["/u02"]

# entrypoint for database creation, startup and graceful shutdown
ENTRYPOINT ["/assets/entrypoint.sh"]
CMD [""]
