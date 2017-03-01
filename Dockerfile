FROM phsalvisberg/oracle12ee:v2.0.0

MAINTAINER philipp.salvisberg@gmail.com

# environment variables (defaults for DBCA and entrypoint.sh)
ENV WEB_CONSOLE=true \
    DBCA_TOTAL_MEMORY=2048 \
    ORACLE_SID=odb \
    SERVICE_NAME=odb.docker \
    APEX_PASS=Oracle12c! \
    PASS=oracle

# copy all scripts
ADD assets /assets/

# image setup via shell script to reduce layers and optimize final disk usage
RUN /assets/image_setup.sh

# database port and web console port
EXPOSE 1521 8082

# use ${ORACLE_BASE} without product subdirectory as data volume
VOLUME ["/u01/app/oracle"]

# entrypoint for database creation, startup and graceful shutdown
ENTRYPOINT ["/assets/entrypoint.sh"]
CMD [""]
