FROM phsalvisberg/odb:9.2sw

LABEL maintainer="philipp.salvisberg@gmail.com"
LABEL description="Oracle Database Enterprise Edition 9.2"
LABEL build.command="docker build . --tag phsalvisberg/odb:9.2"
LABEL run.command="docker run --stop-timeout 60 -v odb:/u02 -it -p 1521:1521 -h odb --name odb phsalvisberg/odb:9.2"

# environment variables (defaults for DBCA and entrypoint.sh)
ENV GDBNAME=odb.docker \
    ORACLE_SID=odb \
    SERVICE_NAME=odb.docker \
    PASS=oracle

# copy all scripts
ADD assets /assets/
RUN chmod +x /assets/entrypoint.sh /assets/image_setup.sh /assets/setenv.sh
RUN chown -R oracle:oinstall /assets

# image setup via shell script to reduce layers and optimize final disk usage
RUN /assets/image_setup.sh

# database port
EXPOSE 1521

# all data directories in /u01 are linked to this volume
VOLUME ["/u02"]

# entrypoint for database creation, startup and graceful shutdown
ENTRYPOINT ["/assets/entrypoint.sh"]
CMD [""]
