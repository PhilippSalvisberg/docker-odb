FROM phsalvisberg/odb:18.0sw

LABEL maintainer="philipp.salvisberg@gmail.com"
LABEL description="Oracle Database Enterprise Edition 18.0"
LABEL build.command="docker build . --tag phsalvisberg/odb:18.0"
LABEL run.command="docker run -v odb:/u02 -it -p 8080-8081:8080-8081 -p 1521:1521 -h odb --name odb phsalvisberg/odb:18.0"

# environment variables (defaults for DBCA and entrypoint.sh)
ENV MULTITENANT=false \
    DBEXPRESS=true \
    APEX=true \
    ORDS=true \
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
EXPOSE 1521 8080 8081

# all data directories in /u01 are linked to this volume
VOLUME ["/u02"]

# entrypoint for database creation, startup and graceful shutdown
ENTRYPOINT ["/assets/entrypoint.sh"]
CMD [""]
