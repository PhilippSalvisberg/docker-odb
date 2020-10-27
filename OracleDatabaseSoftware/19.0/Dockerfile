FROM oraclelinux:7.9

LABEL maintainer="philipp.salvisberg@gmail.com"
LABEL description="Oracle Database Enterprise Edition 19c software only"
LABEL build.command="docker build . --tag phsalvisberg/odb:19.0sw"

# copy all scripts
ADD assets /assets/

# image setup via shell script to reduce layers and optimize final disk usage
RUN /assets/db_setup.sh
